const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const restaurantSchema = new mongoose.Schema({
  id: {
    type: String,
    default: uuidv4,
    unique: true,
    required: true,
  },
  name: {
    type: String,
    required: [true, 'اسم المطعم مطلوب'],
    trim: true,
  },
  photoUrl: {
    type: String,
    default: null,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for faster queries
restaurantSchema.index({ id: 1 });
restaurantSchema.index({ name: 1 });

const Restaurant = mongoose.model('Restaurant', restaurantSchema);

module.exports = Restaurant;
