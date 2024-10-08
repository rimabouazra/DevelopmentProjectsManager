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
    
    if (req.method === 'OPTIONS') {
        return res.status(200).json({});
    }

    next();
});


let authenticate = (req, res, next) => {
    let token = req.header('x-access-token');
    console.log('Token received:', token);
    if (!token) {
        return res.status(401).send({ message: 'No token provided.' });
    }
    jwt.verify(token,  User.getJWTSecret(), (err, decoded) => {
      if (err) {
        console.error('Token verification failed:', err);
        return res.status(401).send({ message: 'Unauthorized access' });
      }
      console.log('Decoded token:', decoded);
      req.user_id = decoded._id;
      User.findById(req.user_id).then((user) => {
        if (!user) {
          return res.status(404).send({ msg: 'User not found' });
        }
        req.user = user;
        next();
      }).catch((error) => {
        res.status(500).send({ msg: 'Failed to fetch user details' });
      });
    });
  };
  
  const authenticateAdmin = (req, res, next) => {
    const token = req.header('x-access-token');
    console.log(`Token received: ${token}`);
  
    if (!token) {
      return res.status(401).send({ error: 'No token provided' });
    }
  
    jwt.verify(token, User.getJWTSecret(), (err, decoded) => {
      if (err) {
        return res.status(401).send({ error: 'Invalid token' });
      } else if (decoded.role !== 'administrator') {
        return res.status(403).send({ error: 'Unauthorized role' });
      }
  
      req.user_id = decoded._id;
      req.role = decoded.role;
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
    try {
        let projects = await Project.find({ _userId: req.user_id });
        res.send(projects);
    } catch (e) {
        res.status(500).send(e);
    }

  });
  
  app.post('/projects',authenticate, async (req, res) => {
    //create a new project and return it to the user
    try {
        let user = await User.findById(req.user_id);
        if (!user || !user.canCreateProject()) {
            return res.status(403).send({ message: 'User does not have the permission to create projects' });
        }
        const { title, description, developers, managerId } = req.body;

        // If the user is an administrator, ensure a manager is assigned
        let manager = null;
        if (managerId) {
            manager = await User.findById(managerId);
            if (!manager || manager.role !== 'manager') {
                return res.status(400).send({ message: 'Invalid manager selected' });
            }
        }

        let newProject = new Project({
            title,
            description,
            developers,
            manager: manager ? manager._id : user._id, 
            _userId: req.user_id
        });

        let projectDoc = await newProject.save();
        res.send(projectDoc);
        /*res.status(201).send(projectDoc);*/
    } catch (e) {
        res.status(500).send(e);
    }
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
    const projectId = req.params.projectId;
    console.log('Received projectId:', projectId); // Debugging
    Project.findOne({
        _id: req.params.projectId,
        _userId: req.user_id
    }).then((project) => {
        if (project) {
            console.log('Project found:', project.title); // Debugging
            // project object found-the currently authenticated user can create new tasks
            return true;
        }
        console.log('Project not found or unauthorized access.'); // Debugging
        return false;
    }).then((canCreateTask) => {
        if (canCreateTask) {
            console.log('Creating task with title:', req.body.title); // Debugging
            let newTask = new Task({
                title: req.body.title,
                projectId: req.params.projectId,
                dueDate: req.body.dueDate,
                completed: false
            });
            newTask.save().then((newTaskDoc) => {
                console.log('Task created successfully:', newTaskDoc); // Debugging
                res.status(201).send(newTaskDoc);
            }).catch((error) => {
                console.error('Failed to save new task:', error); // Debugging
                res.status(500).send({ message: 'Failed to create task.' });
            });
        } else {
            console.log('Failed to create task: Project not found or unauthorized'); // Debugging
            res.sendStatus(404);
        }
    }).catch((error) => {
        console.error('Error in finding project or creating task:', error); // Debugging
        res.status(500).send({ message: 'Server error while creating task.' });
    });
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

 app.post('/users', async(req, res) => {
    // User sign up

    let body = req.body;
    if (!body.email || !body.password || !body.name || !body.role) {
        return res.status(400).send({ msg: 'All fields are required' });
    }
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

 
app.post("/users/login", async (req, res) => {
    try {
        const { email, password } = req.body;
    
        const user = await User.findOne({ email });
        if (!user) {
          return res
            .status(400)
            .json({ msg: "User with this email does not exist!" });
        }

         // Debugging:
         //console.log("Entered Password:", password);
         //console.log("Stored Hashed Password:", user.password);
         console.log("Stored role in database for the user: ", user.role);
         console.log("User role before sending response: ", user.role);
    
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
          return res.status(400).json({ msg: "Incorrect password." });
        }
    
        const refreshToken = await user.createSession();
        const accessToken = await user.generateAccessAuthToken();

        if (!refreshToken || !accessToken) {
            return res.status(500).json({ msg: 'Failed to generate tokens' });
          }

        res
        .header('x-refresh-token', refreshToken)
        .header('x-access-token', accessToken)
        .json({
            token: accessToken,
            user: {
                _id: user._id,
                name: user.name,
                email: user.email,
                role: user.role,
                sessions: user.sessions,
            },
        });

      } catch (e) {
        res.status(500).json({ error: e.message });
      }
});



// Sign Up
app.post("/users/signup", async (req, res) => {
    try {
        const { name, email, password, role } = req.body;
        if (!name || !email || !password || role === undefined) {
            return res.status(400).json({ msg: 'All fields including role are required' });
        }

        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res
                .status(400)
                .json({ msg: "User with the same email already exists!" });
        }

        const hashedPassword = await bcrypt.hash(password, 8);

        let user = new User({
            email,
            password: hashedPassword,
            name,
            role
        });
        user = await user.save();

        const refreshToken = await user.createSession();
        const accessToken = await user.generateAccessAuthToken();

        res
            .header('x-refresh-token', refreshToken)
            .header('x-access-token', accessToken)
            .json(user);
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
    }).catch((e) => {
        console.error("Error deleting tasks from project " + projectId, e);
    });
}

app.get('/developers', (req, res) => {
    User.findDevelopers()
      .then(developers => 
        {console.log("Developers found:", developers);
        res.send(developers);})
      .catch(err => res.status(500).send(err));
  });

  app.delete('/users/:id', authenticateAdmin, async (req, res) => {
    try {
      const userId = req.params.id;
        const user = await User.findById(userId);
      if (!user) {
        return res.status(404).send({ msg: 'User not found' });
      }
      // Delete the user
      await User.findByIdAndDelete(userId);
      res.status(200).send({ msg: 'User deleted successfully' });
    } catch (error) {
      res.status(500).send({ error: 'An error occurred while trying to delete the user' });
    }
  });
  
app.post('/notifications', (req, res) => {
    const newNotification = new Notification(req.body);
    newNotification.save()
      .then(() => res.status(201).send(newNotification))
      .catch(err => res.status(500).send(err));
  });
  
app.get('/notifications/:userId', (req, res) => {
    Notification.find({ userId: req.params.userId })
      .then(notifications => res.send(notifications))
      .catch(err => res.status(500).send(err));
  });

app.get('/users/pending-approval', authenticateAdmin, async (req, res) => {
    try {
      const pendingUsers = await User.findPendingUsers();
      res.status(200).send(pendingUsers);
    } catch (e) {
      res.status(500).send({ msg: 'Error fetching pending users' });
    }
});

app.patch('/users/approve/:userId', authenticateAdmin, async (req, res) => {
    try {
      const userId = req.params.userId;
      const updatedUser = await User.findByIdAndUpdate(userId, { isApproved: true }, { new: true });
  
      if (!updatedUser) {
        return res.status(404).send({ msg: 'User not found' });
      }
  
      res.status(200).send({ msg: 'User approved', user: updatedUser });
    } catch (error) {
      res.status(500).send({ msg: 'Error approving user' });
    }
  });
  

app.post('/projects/request', authenticate, async (req, res) => {
    try {
      const { managerId, title, description } = req.body;
      const manager = await User.findById(managerId);
      
      if (!manager || manager.role !== 'manager') {
        return res.status(400).send({ msg: 'Invalid manager selected' });
      }
  
      const newProjectRequest = new ProjectRequest({
        managerId,
        title,
        description,
        status: 'pending',
      });
  
      await newProjectRequest.save();
      res.status(201).send({ msg: 'Project request sent' });
    } catch (error) {
      res.status(500).send({ msg: 'Error sending project request' });
    }
});
  
app.get('/dashboard/projects', authenticateAdmin, async (req, res) => {
    try {
      const projects = await Project.aggregate([
        { $group: { _id: '$status', count: { $sum: 1 } } }
      ]);
      res.status(200).send(projects);
    } catch (error) {
      res.status(500).send({ msg: 'Error fetching project dashboard' });
    }
  });
  
app.get('/managers', async (req, res) => {
    try {
        const managers = await User.find({ role: 'manager' }).select('name email');
        res.status(200).send(managers);
      } catch (error) {
        res.status(500).send({ msg: 'Error fetching managers' });
      }
});

  
app.listen(3000, () => {
    console.log("Server is running on port 3000!");
  });