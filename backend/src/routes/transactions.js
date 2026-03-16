const express = require('express');
const router = express.Router();
const {
  createTransaction,
  getTransactions,
  updateTransaction,
  deleteTransaction,
} = require('../controllers/transactionController');
const { authenticate, authorize } = require('../middleware/auth');

// All transaction routes require authentication
router.use(authenticate);

// Both admin and staff can access transaction endpoints
router.use(authorize('admin', 'staff'));

// GET /api/transactions - Get transactions with optional filtering
router.get('/', getTransactions);

// POST /api/transactions - Create new transaction
router.post('/', createTransaction);

// PUT /api/transactions/:id - Update transaction (for returns)
router.put('/:id', updateTransaction);

// DELETE /api/transactions/:id - Delete transaction
router.delete('/:id', deleteTransaction);

module.exports = router;
