const mongoose = require('mongoose');
const { v4: uuidv4 } = require('uuid');

const transactionSchema = new mongoose.Schema({
  id: {
    type: String,
    default: uuidv4,
    unique: true,
    required: true,
  },
  restaurantId: {
    type: String,
    required: [true, 'معرف المطعم مطلوب'],
    ref: 'Restaurant',
  },
  productId: {
    type: String,
    required: [true, 'معرف المنتج مطلوب'],
    ref: 'Product',
  },
  date: {
    type: Date,
    required: [true, 'التاريخ مطلوب'],
  },
  jarsSold: {
    type: Number,
    required: [true, 'عدد البرطمانات المباعة مطلوب'],
    min: [0, 'عدد البرطمانات المباعة يجب أن يكون صفر أو أكثر'],
    validate: {
      validator: Number.isInteger,
      message: 'عدد البرطمانات المباعة يجب أن يكون عدد صحيح',
    },
  },
  jarsReturned: {
    type: Number,
    required: [true, 'عدد البرطمانات المرتجعة مطلوب'],
    min: [0, 'عدد البرطمانات المرتجعة يجب أن يكون صفر أو أكثر'],
    validate: {
      validator: Number.isInteger,
      message: 'عدد البرطمانات المرتجعة يجب أن يكون عدد صحيح',
    },
  },
  createdBy: {
    type: String,
    required: false,
    ref: 'User',
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
});

// Index for faster queries
transactionSchema.index({ id: 1 });
transactionSchema.index({ restaurantId: 1 });
transactionSchema.index({ productId: 1 });
transactionSchema.index({ date: -1 }); // Descending order for most recent first
transactionSchema.index({ createdBy: 1 });

const Transaction = mongoose.model('Transaction', transactionSchema);

module.exports = Transaction;
