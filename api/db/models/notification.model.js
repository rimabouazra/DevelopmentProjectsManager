const mongoose = require('mongoose');

const NotificationSchema = new mongoose.Schema({
  message: {
    type: String,
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  timestamp: {
    type: Date,
    default: Date.now
  },
});

const Notification = mongoose.model('Notification', NotificationSchema);
module.exports = Notification;
