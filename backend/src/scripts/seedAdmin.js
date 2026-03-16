const mongoose = require('mongoose');
const User = require('../models/User');
const { hashPassword } = require('../utils/auth');
const config = require('../config/env');

/**
 * Seed an admin user for testing
 */
const seedAdmin = async () => {
  try {
    // Connect to database
    await mongoose.connect(config.mongodbUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ username: 'admin' });
    
    if (existingAdmin) {
      console.log('Admin user already exists');
      process.exit(0);
    }

    // Create admin user
    const passwordHash = await hashPassword('admin123');
    
    const admin = new User({
      username: 'admin',
      passwordHash,
      role: 'admin',
    });

    await admin.save();
    
    console.log('Admin user created successfully');
    console.log('Username: admin');
    console.log('Password: admin123');
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding admin:', error);
    process.exit(1);
  }
};

seedAdmin();
