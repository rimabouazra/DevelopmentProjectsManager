const mongoose = require('mongoose');

const SubtaskSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  isCompleted: {
    type: Boolean,
    default: false
  }
});

const TaskSchema = new mongoose.Schema({
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
  dueDate: {
    type: Date,
    required: true
  },
  projectId: {
    type: mongoose.Types.ObjectId,
    required: true
  },
  completed:{
    type :Boolean,
    default:false
  },
  developerNames: {
    type: [String],
    default: []
  },
  subtasks: {
    type: [SubtaskSchema], 
    default: []
  }
});

const Task = mongoose.model('Task', TaskSchema);

module.exports = { Task };
