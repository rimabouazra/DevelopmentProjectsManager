const mongoose = require('mongoose');
const { TaskSchema } = require('./task.model');


const ProjectSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    minlength: 1,
    trim: true
  },
  description: {
    type: String,
    trim: true
  },
  tasks: [{
    type: mongoose.Types.ObjectId, 
    ref: 'Task' 
  }],
  developers: [{
    type: mongoose.Types.ObjectId, 
    ref: 'User' // References developers
  }],
  manager: {
    type: mongoose.Types.ObjectId,
    ref: 'User',
    required: true,
  },
   // with auth
   _userId: {
    type: mongoose.Types.ObjectId,
    required: true
},
createdAt: {
  type: Date,
  default: Date.now
},
status: {
  type: String,
  enum: ['assigned', 'in-progress', 'completed'],
  default: 'assigned',
},
});

const Project = mongoose.model('Project', ProjectSchema);

module.exports = { Project };
