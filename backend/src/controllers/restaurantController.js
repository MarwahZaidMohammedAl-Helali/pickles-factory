const Restaurant = require('../models/Restaurant');
const Transaction = require('../models/Transaction');
const Product = require('../models/Product');
const { calculateBalance } = require('../utils/balanceCalculator');

/**
 * Create a new restaurant
 * POST /api/restaurants
 */
const createRestaurant = async (req, res, next) => {
  try {
    const { name } = req.body;

    // Validate required fields
    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'اسم المطعم مطلوب',
          details: {},
        },
      });
    }

    // Create new restaurant
    const restaurant = new Restaurant({
      name: name.trim(),
    });

    await restaurant.save();

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        id: restaurant.id,
        name: restaurant.name,
        photoUrl: restaurant.photoUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all restaurants
 * GET /api/restaurants
 */
const getRestaurants = async (req, res, next) => {
  try {
    const restaurants = await Restaurant.find({}, 'id name photoUrl createdAt');

    // Calculate balance for each restaurant
    const restaurantsWithBalance = await Promise.all(
      restaurants.map(async (restaurant) => {
        // Fetch all transactions for this restaurant
        const transactions = await Transaction.find({ restaurantId: restaurant.id }).lean();

        // Populate product prices for each transaction
        const transactionsWithPrices = await Promise.all(
          transactions.map(async (transaction) => {
            const product = await Product.findOne({ id: transaction.productId });
            return {
              jarsSold: transaction.jarsSold,
              jarsReturned: transaction.jarsReturned,
              productPrice: product ? product.price : 0,
            };
          })
        );

        // Calculate balance
        const balance = calculateBalance(transactionsWithPrices);

        return {
          id: restaurant.id,
          name: restaurant.name,
          photoUrl: restaurant.photoUrl,
          balance,
        };
      })
    );

    res.json({
      success: true,
      data: restaurantsWithBalance,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get restaurant by ID with balance and transactions
 * GET /api/restaurants/:id
 */
const getRestaurantById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ id });

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المطعم غير موجود',
          details: {},
        },
      });
    }

    // Fetch all transactions for this restaurant
    const transactions = await Transaction.find({ restaurantId: id })
      .sort({ date: -1 })
      .lean();

    // Populate product information and prepare for balance calculation
    const transactionsWithProducts = await Promise.all(
      transactions.map(async (transaction) => {
        const product = await Product.findOne({ id: transaction.productId });
        return {
          id: transaction.id,
          productId: transaction.productId,
          productName: product ? product.name : null,
          productPrice: product ? product.price : 0,
          date: transaction.date,
          jarsSold: transaction.jarsSold,
          jarsReturned: transaction.jarsReturned,
        };
      })
    );

    // Calculate balance
    const balance = calculateBalance(transactionsWithProducts);

    res.json({
      success: true,
      data: {
        id: restaurant.id,
        name: restaurant.name,
        photoUrl: restaurant.photoUrl,
        balance,
        transactions: transactionsWithProducts,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a restaurant
 * PUT /api/restaurants/:id
 */
const updateRestaurant = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, photoUrl } = req.body;

    const restaurant = await Restaurant.findOne({ id });

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المطعم غير موجود',
          details: {},
        },
      });
    }

    // Update fields if provided
    if (name !== undefined && name.trim() !== '') {
      restaurant.name = name.trim();
    }

    if (photoUrl !== undefined) {
      restaurant.photoUrl = photoUrl;
    }

    await restaurant.save();

    res.json({
      success: true,
      data: {
        id: restaurant.id,
        name: restaurant.name,
        photoUrl: restaurant.photoUrl,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a restaurant
 * DELETE /api/restaurants/:id
 */
const deleteRestaurant = async (req, res, next) => {
  try {
    const { id } = req.params;

    const restaurant = await Restaurant.findOne({ id });

    if (!restaurant) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المطعم غير موجود',
          details: {},
        },
      });
    }

    // Delete all transactions for this restaurant
    await Transaction.deleteMany({ restaurantId: id });

    // Delete the restaurant
    await Restaurant.deleteOne({ id });

    res.json({
      success: true,
      data: {
        message: 'تم حذف المطعم بنجاح',
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createRestaurant,
  getRestaurants,
  getRestaurantById,
  updateRestaurant,
  deleteRestaurant,
};
