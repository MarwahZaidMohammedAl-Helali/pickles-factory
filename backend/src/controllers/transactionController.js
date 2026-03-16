const Transaction = require('../models/Transaction');
const Restaurant = require('../models/Restaurant');
const Product = require('../models/Product');

/**
 * Create a new transaction
 * POST /api/transactions
 */
const createTransaction = async (req, res, next) => {
  try {
    const { restaurantId, productId, date, jarsSold, jarsReturned } = req.body;

    // Validate all required fields are provided
    if (!restaurantId) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'معرف المطعم مطلوب',
          details: {},
        },
      });
    }

    if (!productId) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'معرف المنتج مطلوب',
          details: {},
        },
      });
    }

    if (!date) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'التاريخ مطلوب',
          details: {},
        },
      });
    }

    if (jarsSold === undefined || jarsSold === null) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'عدد البرطمانات المباعة مطلوب',
          details: {},
        },
      });
    }

    if (jarsReturned === undefined || jarsReturned === null) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'عدد البرطمانات المرتجعة مطلوب',
          details: {},
        },
      });
    }

    // Validate jar counts are non-negative integers
    if (!Number.isInteger(jarsSold) || jarsSold < 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'عدد البرطمانات المباعة يجب أن يكون عدد صحيح غير سالب',
          details: {},
        },
      });
    }

    if (!Number.isInteger(jarsReturned) || jarsReturned < 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'عدد البرطمانات المرتجعة يجب أن يكون عدد صحيح غير سالب',
          details: {},
        },
      });
    }

    // Verify restaurant exists
    const restaurant = await Restaurant.findOne({ id: restaurantId });
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

    // Verify product exists
    const product = await Product.findOne({ id: productId });
    if (!product) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المنتج غير موجود',
          details: {},
        },
      });
    }

    // Create new transaction
    const transaction = new Transaction({
      restaurantId,
      productId,
      date: new Date(date),
      jarsSold,
      jarsReturned,
      createdBy: req.user.id, // Save who created this transaction
    });

    await transaction.save();

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        id: transaction.id,
        restaurantId: transaction.restaurantId,
        productId: transaction.productId,
        date: transaction.date,
        jarsSold: transaction.jarsSold,
        jarsReturned: transaction.jarsReturned,
        createdBy: transaction.createdBy,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get transactions with optional filtering
 * GET /api/transactions?restaurantId=:id&startDate=:start&endDate=:end
 */
const getTransactions = async (req, res, next) => {
  try {
    const { restaurantId, startDate, endDate } = req.query;

    // Build query filter
    const filter = {};

    if (restaurantId) {
      filter.restaurantId = restaurantId;
    }

    // Add date range filtering if provided
    if (startDate || endDate) {
      filter.date = {};
      if (startDate) {
        filter.date.$gte = new Date(startDate);
      }
      if (endDate) {
        filter.date.$lte = new Date(endDate);
      }
    }

    // Fetch transactions with product information
    const transactions = await Transaction.find(filter)
      .sort({ date: -1 }) // Most recent first
      .lean();

    // Populate product and user information for each transaction
    const transactionsWithDetails = await Promise.all(
      transactions.map(async (transaction) => {
        const product = await Product.findOne({ id: transaction.productId });
        let createdByUser = null;
        
        if (transaction.createdBy) {
          const User = require('../models/User');
          createdByUser = await User.findOne({ id: transaction.createdBy });
        }
        
        return {
          id: transaction.id,
          restaurantId: transaction.restaurantId,
          productId: transaction.productId,
          productName: product ? product.name : null,
          productPrice: product ? product.price : null,
          date: transaction.date,
          jarsSold: transaction.jarsSold,
          jarsReturned: transaction.jarsReturned,
          createdBy: transaction.createdBy,
          createdByUsername: createdByUser ? createdByUser.username : null,
        };
      })
    );

    res.json({
      success: true,
      data: transactionsWithDetails,
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a transaction
 * PUT /api/transactions/:id
 */
const updateTransaction = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { date, jarsSold, jarsReturned } = req.body;

    // Find transaction
    const transaction = await Transaction.findOne({ id });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المعاملة غير موجودة',
          details: {},
        },
      });
    }

    // Update fields if provided
    if (date !== undefined) {
      transaction.date = new Date(date);
    }

    if (jarsSold !== undefined) {
      if (!Number.isInteger(jarsSold) || jarsSold < 0) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'عدد البرطمانات المباعة يجب أن يكون عدد صحيح غير سالب',
            details: {},
          },
        });
      }
      transaction.jarsSold = jarsSold;
    }

    if (jarsReturned !== undefined) {
      if (!Number.isInteger(jarsReturned) || jarsReturned < 0) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'عدد البرطمانات المرتجعة يجب أن يكون عدد صحيح غير سالب',
            details: {},
          },
        });
      }
      transaction.jarsReturned = jarsReturned;
    }

    await transaction.save();

    res.json({
      success: true,
      data: {
        id: transaction.id,
        restaurantId: transaction.restaurantId,
        productId: transaction.productId,
        date: transaction.date,
        jarsSold: transaction.jarsSold,
        jarsReturned: transaction.jarsReturned,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a transaction
 * DELETE /api/transactions/:id
 */
const deleteTransaction = async (req, res, next) => {
  try {
    const { id } = req.params;

    const transaction = await Transaction.findOne({ id });

    if (!transaction) {
      return res.status(404).json({
        success: false,
        error: {
          code: 'NOT_FOUND',
          message: 'المعاملة غير موجودة',
          details: {},
        },
      });
    }

    await Transaction.deleteOne({ id });

    res.json({
      success: true,
      data: {
        message: 'تم حذف المعاملة بنجاح',
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createTransaction,
  getTransactions,
  updateTransaction,
  deleteTransaction,
};
