const mongoose = require('mongoose');
const _ = require('lodash');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const bcrypt = require('bcryptjs');

const jwtSecret = "42078558166243957505uefkfjza8474524076";

const UserSchema = new mongoose.Schema({
  name: {
    required: true,
    type: String,
    trim: true,
  },
  email: {
    type: String,
    required: true,
    minlength: 1,
    trim: true,
    unique: true,
    validate: {
      validator: (value) => {
        const re =
          /^(([^<>()[\]\.,;:\s@\"]+(\.[^<>()[\]\.,;:\s@\"]+)*)|(\".+\"))@(([^<>()[\]\.,;:\s@\"]+\.)+[^<>()[\]\.,;:\s@\"]{2,})$/i;
        return value.match(re);
      },
      message: "Please enter a valid email address",
    },
  },
  password: {
    type: String,
    required: true,
    minlength: 8,
  },
  role: { 
    type: String, 
    enum: ['developer', 'manager', 'administrator'], 
    required: true 
  },
  isApproved: {
    type: Boolean,
    default: false, 
  },
  sessions: [{
    token: {
      type: String,
      required: true,
    },
    expireAt: {
      type: Number,
      required: true,
    }
  }],
});

// Instance methods
UserSchema.methods.toJSON = function() {
  const user = this;
  const userObject = user.toObject();
  return _.omit(userObject, ['password', 'sessions']);
}

UserSchema.methods.generateAccessAuthToken = function() {
  const user = this;
  return new Promise((resolve, reject) => {
    jwt.sign(
      { _id: user._id.toHexString() },
      jwtSecret,
      { expiresIn: "15m" },
      (err, token) => {
        if (!err) {
          resolve(token);
        } else {
          reject(err);
        }
      }
    );
  });
}

UserSchema.methods.generateRefreshAuthToken = function() {
  return new Promise((resolve, reject) => {
    crypto.randomBytes(64, (err, buf) => {
      if (!err) {
        let token = buf.toString('hex');
        return resolve(token);
      } else {
        reject(err); // Handle error
      }
    });
  });
}

UserSchema.methods.createSession = function() {
  const user = this;
  return user.generateRefreshAuthToken().then((refreshToken) => {
    return saveSessionToDatabase(user, refreshToken);
  }).then((refreshToken) => {
    return refreshToken;
  }).catch((e) => {
    return Promise.reject('Failed to save session to database. \n' + e);
  });
}

UserSchema.methods.canCreateProject = function () {
  return this.role === 'manager' || this.role === 'administrator';
};

UserSchema.methods.canCreateTask = function () {
  return this.role === 'developer' || this.role === 'manager';
};


// Static methods
UserSchema.statics.getJWTSecret = () =>  {
  return jwtSecret;
};

UserSchema.statics.findByIdAndToken = function(_id, token) {
  const User = this;
  return User.findOne({
    _id,
    'sessions.token': token
  });
}

UserSchema.statics.findByCredentials = function (email, password) {
  let User = this;
  return User.findOne({ email }).then((user) => {
      if (!user) return Promise.reject({ msg: 'Login failed! Check authentication credentials' });

      return new Promise((resolve, reject) => {
          bcrypt.compare(password, user.password, (err, res) => {
              if (res) {
                console.log("Password matches!");
                resolve(user);
              } else {
                console.log("Password does not match!");
                reject({ msg: 'Invalid credentials' });
              }
          });
      });
  });
};


UserSchema.statics.hasRefreshTokenExpired = (expiresAt) => {
  let secondsSinceEpoch = Date.now() / 1000;
  return expiresAt <= secondsSinceEpoch;
}

UserSchema.statics.deleteUserById = function (userId) {
  const User = this;

  return User.findByIdAndDelete(userId)
    .then((deletedUser) => {
      if (!deletedUser) {
        return Promise.reject({ msg: 'User not found' });
      }
      return deletedUser;
    })
    .catch((error) => {
      return Promise.reject(error);
    });
};
UserSchema.statics.findManagers = function() {
  return this.find({ role: 'manager' }).select('name email role');
};
UserSchema.statics.findPendingUsers = function() {
  return this.find({ isApproved: false }).select('name email role');
};
// Middleware
UserSchema.pre('save', function (next) {
  let user = this;

  if (user.isModified('password')) {
    bcrypt.genSalt(10, (err, salt) => {
      bcrypt.hash(user.password, salt, (err, hash) => {
        if (err) return next(err);
        user.password = hash;
        next();
      });
    });
  } else {
    next();
  }
});


// Helper methods
let saveSessionToDatabase = (user, refreshToken) => {
  return new Promise((resolve, reject) => {
    let expireAt = generateRefreshTokenExpiryTime();
    user.sessions.push({ 'token': refreshToken, expireAt });

    user.save().then(() => {
      return resolve(refreshToken);
    }).catch((e) => {
      reject(e);
    });
  });
}

UserSchema.statics.findDevelopers = function() {
  return this.find({ role: 'developer' }).select('name email role');
};

let generateRefreshTokenExpiryTime = () => {
  let daysUntilExpire = 10;
  let secondsUntilExpire = ((daysUntilExpire * 24) * 60) * 60;
  return (Date.now() / 1000) + secondsUntilExpire;
}

const User = mongoose.model('User', UserSchema);

module.exports = { User };
