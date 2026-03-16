const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const userSchema = new mongoose.Schema({
  id: {
    type: String,
    default: uuidv4,
    unique: true,
    required: true,
  },
  username: {
    type: String,
    required: [true, 'اسم المستخدم مطلوب'],
    unique: true,
    trim: true,
  },
  passwordHash: {
    type: String,
    required: [true, 'كلمة المرور مطلوبة'],
  },
  role: {
    type: String,
    enum: {
      values: ['admin', 'staff'],
      message: 'الدور يجب أن يكون admin أو staff',
    },
    required: [true, 'الدور مطلوب'],
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for faster queries
userSchema.index({ username: 1 });
userSchema.index({ id: 1 });

const User = mongoose.model('User', userSchema);

module.exports = User;
