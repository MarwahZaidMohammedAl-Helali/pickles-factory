const express = require('express');
const router = express.Router();
const {
  createRestaurant,
  getRestaurants,
  getRestaurantById,
  updateRestaurant,
  deleteRestaurant,
} = require('../controllers/restaurantController');
const { authenticate, authorize } = require('../middleware/auth');

// All restaurant routes require authentication
router.use(authenticate);

// Both admin and staff can access restaurant endpoints
router.use(authorize('admin', 'staff'));

// GET /api/restaurants - List all restaurants
router.get('/', getRestaurants);

// POST /api/restaurants - Create new restaurant
router.post('/', createRestaurant);

// GET /api/restaurants/:id - Get restaurant details
router.get('/:id', getRestaurantById);

// PUT /api/restaurants/:id - Update restaurant
router.put('/:id', updateRestaurant);

// DELETE /api/restaurants/:id - Delete restaurant
router.delete('/:id', deleteRestaurant);

module.exports = router;
