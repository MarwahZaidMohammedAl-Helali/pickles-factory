const express = require('express');
const router = express.Router();
const { createUser, getUsers, updateUser, deleteUser } = require('../controllers/userController');
const { authenticate, authorize } = require('../middleware/auth');

// All user management routes require authentication and admin role
router.use(authenticate);
router.use(authorize('admin'));

// GET /api/users - List all users
router.get('/', getUsers);

// POST /api/users - Create new staff member
router.post('/', createUser);

// PUT /api/users/:id - Update user
router.put('/:id', updateUser);

// DELETE /api/users/:id - Delete user
router.delete('/:id', deleteUser);

module.exports = router;
