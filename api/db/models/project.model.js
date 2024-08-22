const mongoose = require('mongoose');

const ProjectSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true,
    minlength: 1,
    trim: true
  },
   // with auth
   _userId: {
    type: mongoose.Types.ObjectId,
    required: true
}
});

const Project = mongoose.model('Project', ProjectSchema);

module.exports = { Project };
