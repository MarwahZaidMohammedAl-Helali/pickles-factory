const express = require('express');
const router = express.Router();
const {
  createProduct,
  getProducts,
  updateProduct,
  deleteProduct,
} = require('../controllers/productController');
const { authenticate, authorize } = require('../middleware/auth');

// All product routes require authentication
router.use(authenticate);

// GET /api/products - List all products (accessible to both admin and staff)
router.get('/', authorize('admin', 'staff'), getProducts);

// POST /api/products - Create new product (admin only)
router.post('/', authorize('admin'), createProduct);

// PUT /api/products/:id - Update product (admin only)
router.put('/:id', authorize('admin'), updateProduct);

// DELETE /api/products/:id - Delete product (admin only)
router.delete('/:id', authorize('admin'), deleteProduct);

module.exports = router;
