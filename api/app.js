const express = require('express');
const bodyParser = require('body-parser');
const { mongoose } = require('./db/mongoose');

const { Project } = require('./db/models/project.model');
const { Task } = require('./db/models/task.model');

const app = express();
app.use(bodyParser.json());
app.use((req, res, next) => {
    res.header("Access-Control-Allow-Origin", "*");
    res.header("Access-Control-Allow-Headers", "GET,POST,OPTIONS,PUT,PATCH,DELETE");
    res.header("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
    next();
  });

app.get('/projects', async (req, res) => {
    //get all the projects in the database
    Project.find().then((projects)=>{
        res.send(projects);
    }).catch((e)=>{
        res.send(e);
    });

  });
  
  app.post('/projects', async (req, res) => {
    //create a new project and return it to the user
    try {
      const newProject = new Project(req.body);
      const savedProject = await newProject.save();
      res.status(201).send(savedProject);
    } catch (error) {
      res.status(400).send(error);
    }
  });

  app.patch('/projects/:id',(req,res)=>{
    //update the specified Project
    Project.findOneAndUpdate({_id:req.params.id},{
        $set:req.body
    }).then(()=>{
        res.sendStatus(200);//ok message
    });
});

app.delete('/projects/:id',(req,res)=>{
    //delete the specified Project
    Project.findByIdAndDelete({
        _id:req.params.id
    }).then((removedProjectDoc)=>{
        res.send(removedProjectDoc);
    });
});

app.get('/projects/:projectId/tasks', (req, res) => {
    Task.find({ projectId: req.params.projectId }).then((tasks) => {
      res.send(tasks);
    }).catch((error) => {
      res.status(500).send(error);
    });
  });
  
  app.post('/projects/:projectId/tasks', (req, res) => {
    let newTask = new Task({
        title: req.body.title,
        projectId: req.params.projectId
    });
    newTask.save().then((newTaskDoc) => {
        res.send(newTaskDoc);
    }).catch((e) => {
        res.status(400).send(e);
    });
  });
  
  app.patch('/projects/:projectId/tasks/:taskId',(req,res)=>{
      //update the specified list
      Task.findOneAndUpdate({
          _id:req.params.taskId,
          projectId:req.params.projectId
      },{
          $set:req.body
      }).then(()=>{
          res.send({message:'updated successfully'});//ok message
      });
  });
  
  app.delete('/projects/:projectId/tasks/:taskId',(req,res)=>{
      //delete the specified list
      Task.findByIdAndDelete({
          _id:req.params.taskId,
          projectId:req.params.projectId
      }).then((removedTaskDoc)=>{
          res.send(removedTaskDoc);
      });
  });
  

app.listen(3000, () => {
    console.log(`Server is running on port 3000!`);
  });