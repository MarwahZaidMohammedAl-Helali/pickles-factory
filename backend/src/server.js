const express = require('express');
const cors = require('cors');
const config = require('./config/env');
const connectDB = require('./config/database');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();

// Connect to database and setup admin if needed
const initializeApp = async () => {
  await connectDB();
  
  // Auto-create admin user if environment variable is set
  if (process.env.CREATE_ADMIN_ON_START === 'true') {
    try {
      const User = require('./models/User');
      const { hashPassword } = require('./utils/auth');
      
      const existingAdmin = await User.findOne({ username: 'admin' });
      
      if (!existingAdmin) {
        const passwordHash = await hashPassword('admin123');
        const admin = new User({
          username: 'admin',
          passwordHash,
          plainPassword: 'admin123',
          role: 'admin',
        });
        await admin.save();
        console.log('✅ Admin user created automatically (username: admin, password: admin123)');
      } else {
        console.log('ℹ️  Admin user already exists');
      }
    } catch (error) {
      console.error('❌ Error creating admin user:', error.message);
    }
  }
};

initializeApp();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// One-time setup endpoint to create admin user
app.post('/setup-admin', async (req, res) => {
  try {
    const User = require('./models/User');
    const { hashPassword } = require('./utils/auth');
    
    // Check if admin already exists
    const existingAdmin = await User.findOne({ username: 'admin' });
    
    if (existingAdmin) {
      return res.json({ 
        success: true, 
        message: 'Admin user already exists',
        alreadyExists: true 
      });
    }

    // Create admin user
    const passwordHash = await hashPassword('admin123');
    
    const admin = new User({
      username: 'admin',
      passwordHash,
      plainPassword: 'admin123',
      role: 'admin',
    });

    await admin.save();
    
    res.json({ 
      success: true, 
      message: 'Admin user created successfully',
      username: 'admin',
      password: 'admin123'
    });
  } catch (error) {
    console.error('Error creating admin:', error);
    res.status(500).json({ 
      success: false, 
      error: 'Failed to create admin user',
      details: error.message 
    });
  }
});

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/users', require('./routes/users'));
app.use('/api/restaurants', require('./routes/restaurants'));
app.use('/api/products', require('./routes/products'));
app.use('/api/transactions', require('./routes/transactions'));

// 404 handler
app.use(notFoundHandler);

// Error handling middleware (must be last)
app.use(errorHandler);

const PORT = config.port;

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});

module.exports = app;
