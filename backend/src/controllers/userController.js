const User = require('../models/User');
const { hashPassword } = require('../utils/auth');

/**
 * Create a new staff member (Admin only)
 * POST /api/users
 */
const createUser = async (req, res, next) => {
  try {
    const { username, password } = req.body;

    // Validate required fields
    if (!username || !password) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'اسم المستخدم وكلمة المرور مطلوبان',
          details: {},
        },
      });
    }

    // Check if username already exists
    const existingUser = await User.findOne({ username });
    
    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'USERNAME_EXISTS',
          message: 'اسم المستخدم موجود بالفعل',
          details: {},
        },
      });
    }

    // Hash password
    const passwordHash = await hashPassword(password);

    // Create new user with 'staff' role
    const user = new User({
      username,
      passwordHash,
      plainPassword: password, // Store plain password (insecure but requested)
      role: 'staff',
    });

    await user.save();

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        id: user.id,
        username: user.username,
        role: user.role,
        plainPassword: user.plainPassword,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all users (Admin only)
 * GET /api/users
 */
const getUsers = async (req, res, next) => {
  try {
    const users = await User.find({}, 'id username role plainPassword createdAt');

    res.json({
      success: true,
      data: users.map(user => ({
        id: user.id,
        username: user.username,
        role: user.role,
        plainPassword: user.plainPassword,
        createdAt: user.createdAt,
      })),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a user (Admin only)
 * PUT /api/users/:id
 */
const updateUser = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { username, password } = req.body;

    const user = await User.findOne({ id });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المستخدم غير موجود',
          details: {},
        },
      });
    }

    // Update username if provided
    if (username && username.trim() !== '') {
      // Check if new username already exists (excluding current user)
      const existingUser = await User.findOne({ 
        username: username.trim(),
        id: { $ne: id }
      });
      
      if (existingUser) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'USERNAME_EXISTS',
            message: 'اسم المستخدم موجود بالفعل',
            details: {},
          },
        });
      }

      user.username = username.trim();
    }

    // Update password if provided
    if (password && password.trim() !== '') {
      const passwordHash = await hashPassword(password);
      user.passwordHash = passwordHash;
      user.plainPassword = password; // Store plain password
    }

    await user.save();

    res.json({
      success: true,
      data: {
        id: user.id,
        username: user.username,
        role: user.role,
        plainPassword: user.plainPassword,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a user (Admin only)
 * DELETE /api/users/:id
 */
const deleteUser = async (req, res, next) => {
  try {
    const { id } = req.params;

    const user = await User.findOne({ id });

    if (!user) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المستخدم غير موجود',
          details: {},
        },
      });
    }

    // Prevent deleting admin users
    if (user.role === 'admin') {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'لا يمكن حذف حساب المدير',
          details: {},
        },
      });
    }

    await User.deleteOne({ id });

    res.json({
      success: true,
      data: {
        message: 'تم حذف المستخدم بنجاح',
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createUser,
  getUsers,
  updateUser,
  deleteUser,
};
