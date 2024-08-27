const express = require('express');
const bodyParser = require('body-parser');
const jwt =require('jsonwebtoken');
const { mongoose } = require('./db/mongoose');
const bcrypt = require('bcryptjs');


const { Project } = require('./db/models/project.model');
const { Task } = require('./db/models/task.model');
const { User } = require('./db/models/user.model');

const app = express();
app.use(bodyParser.json());
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS, PUT, PATCH, DELETE");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept, x-access-token, x-refresh-token, _id");
    res.header('Access-Control-Expose-Headers', 'x-access-token, x-refresh-token');
    next();
});


let authenticate = (req, res, next) => {
    let token = req.header('x-access-token');
    console.log('Token received:', token);
  
    jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
      if (err) {
        console.error('Token verification failed:', err);
        return res.status(401).send({ message: 'Unauthorized access' });
      }
  
      req.user_id = decoded._id;
      next();
    });
  };
  


// Verify Refresh Token Middleware (verify the session)
let verifySession = (req, res, next) => {
    // grab the refresh token and _id from the request header
    let refreshToken = req.header('x-refresh-token');
    let _id = req.header('_id');
  
    User.findByIdAndToken(_id, refreshToken).then((user) => {
        if (!user) {
            // user not found
            return Promise.reject({
                'error': 'User not found. Make sure that the refresh token and user id are correct'
            });
        }
        //user found
        req.user_id = user._id;
        req.userObject = user;
        req.refreshToken = refreshToken;
  
        let isSessionValid = false;
        user.sessions.forEach((session) => {
            if (session.token === refreshToken) {
                // check if the session has expired
                if (User.hasRefreshTokenExpired(session.expiresAt) === false) {
                    // refresh token has not expired
                    isSessionValid = true;
                }
            }
        });
        if (isSessionValid) {
            //continue with processing this web request
            next();
        } else {
            return Promise.reject({
                'error': 'Refresh token has expired or the session is invalid'
            })
        }
  
    }).catch((e) => {
        res.status(401).send(e);
    })
  }
  

app.get('/projects', authenticate, async (req, res) => {
    //get all the projects belonging to the authentificated user
    Project.find({
       _userId: req.user_id
    }).then((projects)=>{
        res.send(projects);
    }).catch((e)=>{
        res.send(e);
    });

  });
  
  app.post('/projects',authenticate, async (req, res) => {
    //create a new project and return it to the user
    let title = req.body.title;

    let newProject = new Project({
        title,
        _userId: req.user_id
    });
    newProject.save().then((ProjectDoc) => {
        res.send(ProjectDoc);
    })
  });

  app.patch('/projects/:id',authenticate,(req,res)=>{
    //update the specified Project
    Project.findOneAndUpdate({_id:req.params.id, _userId: req.user_id},{
        $set:req.body
    }).then(()=>{
        res.sendStatus(200);//ok message
    });
});

app.delete('/projects/:id',authenticate,(req,res)=>{
    //delete the specified Project
    Project.findByIdAndDelete({
        _id:req.params.id, _userId: req.user_id
    }).then((removedProjectDoc)=>{
        res.send(removedProjectDoc);
        // delete all the tasks that are in the deleted list
        deleteTasksFromList(removedProjectDoc._id);
    });
});



app.get('/projects/:projectId/tasks',authenticate, (req, res) => {
    Task.find({ projectId: req.params.projectId }).then((tasks) => {
      res.send(tasks);
    }).catch((error) => {
      res.status(500).send(error);
    });
  });
  
  app.post('/projects/:projectId/tasks',authenticate, (req, res) => {
    Project.findOne({
        _id: req.params.projectId,
        _userId: req.user_id
    }).then((project) => {
        if (project) {
            // project object found-the currently authenticated user can create new tasks
            return true;
        }
        return false;
    }).then((canCreateTask) => {
        if (canCreateTask) {
            let newTask = new Task({
                title: req.body.title,
                projectId: req.params.projectId
            });
            newTask.save().then((newTaskDoc) => {
                res.send(newTaskDoc);
            })
        } else {
            res.sendStatus(404);
        }
    })
  });
  
  app.patch('/projects/:projectId/tasks/:taskId',authenticate,(req,res)=>{
      //update the specified list
      Project.findOne({
        _id: req.params.projectId,
        _userId: req.user_id
    }).then((project) => {
        if (project) {
            // project object found-the currently authenticated user can update tasks
            return true;
        }
        return false;
    }).then((canUpdateTasks) => {
        if (canUpdateTasks) {
            Task.findOneAndUpdate({
                _id: req.params.taskId,
                projectId: req.params.projectId
            }, {
                    $set: req.body
                }
            ).then(() => {
                res.send({ message: 'Updated successfully.' })
            })
        } else {
            res.sendStatus(404);
        }
    })
  });
  
  app.delete('/projects/:projectId/tasks/:taskId',authenticate,(req,res)=>{
      //delete the specified list
      Project.findOne({
        _id: req.params.projectId,
        _userId: req.user_id
    }).then((project) => {
        if (project) {
            // project object found-the currently authenticated user can delete tasks
            return true;
        }
        return false;
    }).then((canDeleteTasks) => {
        
        if (canDeleteTasks) {
            Task.findOneAndRemove({
                _id: req.params.taskId,
                projectId: req.params.projectId
            }).then((removedTaskDoc) => {
                res.send(removedTaskDoc);
            })
        } else {
            res.sendStatus(404);
        }
    });
  });


  //USER ROUTES

  app.post('/users', (req, res) => {
    // User sign up

    let body = req.body;
    let newUser = new User(body);

    newUser.save().then(() => {
        return newUser.createSession();
    }).then((refreshToken) => {
        // Session created successfully - refreshToken returned.
        //geneate an access auth token for the user

        return newUser.generateAccessAuthToken().then((accessToken) => {
            //return an object containing the auth tokens
            return { accessToken, refreshToken }
        });
    }).then((authTokens) => {
        //construct and send the response to the user with their auth tokens in the header and the user object in the body
        res
            .header('x-refresh-token', authTokens.refreshToken)
            .header('x-access-token', authTokens.accessToken)
            .send(newUser);
    }).catch((e) => {
        res.status(400).send(e);
    })
})

  
app.post('/users/login', (req, res) => {
    const { email, password } = req.body;
    if (!email || !password) {
        return res.status(400).json({ error: 'Email and password are required' });
    }
    User.findByCredentials(email, password).then((user) => {
        return user.createSession().then((refreshToken) => {
            return user.generateAccessAuthToken().then((accessToken) => {
                return { refreshToken, accessToken };
            });
        }).then((authTokens) => {
            res.header('x-refresh-token', authTokens.refreshToken);
            res.header('x-access-token', authTokens.accessToken);
            res.json(user);
        });
    }).catch((err) => {
        res.status(400).json({ error: err.message || 'Invalid login credentials' });
    });
});


// Sign Up
app.post("/users/signup", async (req, res) => {
    try {
      const { name, email, password , role} = req.body;
      if (!name || !email || !password || role === undefined) {
        return res.status(400).json({ msg: 'All fields including role are required' });
      }
  
      const existingUser = await User.findOne({ email });
      if (existingUser) {
        return res
          .status(400)
          .json({ msg: "User with same email already exists!" });
      }
  
      const hashedPassword = await bcrypt.hash(password, 8);
  
      let user = new User({
        email,
        password: hashedPassword,
        name,
        role
      });
      user = await user.save();
      res.json(user);
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
  

app.get('/users/me/access-token', verifySession, (req, res) => {
    req.userObject.generateAccessAuthToken().then((accessToken) => {
        res.header('x-access-token', accessToken).send({ accessToken });
    }).catch((e) => {
        res.status(400).send(e);
    });
});

app.get("/", authenticate, async (req, res) => {
    const user = await User.findById(req.user);
    res.json({ ...user._doc, token: req.token });
  });
  
let deleteTasksFromList = (projectId) => {
    Task.deleteMany({
        projectId
    }).then(() => {
        console.log("Tasks from " + projectId + " were deleted!");
    })
}

app.get('/developers', (req, res) => {
    User.findDevelopers()
      .then(developers => res.send(developers))
      .catch(err => res.status(500).send(err));
  });
  

app.listen(3000, () => {
    console.log(`Server is running on port 3000!`);
  });