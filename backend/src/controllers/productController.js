const Product = require('../models/Product');

/**
 * Create a new product (Admin only)
 * POST /api/products
 */
const createProduct = async (req, res, next) => {
  try {
    const { name, price } = req.body;

    // Validate required fields
    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'اسم المنتج مطلوب',
          details: {},
        },
      });
    }

    if (price === undefined || price === null) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'السعر مطلوب',
          details: {},
        },
      });
    }

    if (typeof price !== 'number' || price < 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'السعر يجب أن يكون رقم موجب',
          details: {},
        },
      });
    }

    // Create new product
    const product = new Product({
      name: name.trim(),
      price,
    });

    await product.save();

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        id: product.id,
        name: product.name,
        price: product.price,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Get all products
 * GET /api/products
 */
const getProducts = async (req, res, next) => {
  try {
    const products = await Product.find({}, 'id name price');

    res.json({
      success: true,
      data: products.map(product => ({
        id: product.id,
        name: product.name,
        price: product.price,
      })),
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Update a product (Admin only)
 * PUT /api/products/:id
 */
const updateProduct = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { name, price } = req.body;

    // Find the product
    const product = await Product.findOne({ id });

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

    // Validate and update fields
    if (name !== undefined) {
      if (!name || name.trim() === '') {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'اسم المنتج مطلوب',
            details: {},
          },
        });
      }
      product.name = name.trim();
    }

    if (price !== undefined) {
      if (typeof price !== 'number' || price < 0) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: 'السعر يجب أن يكون رقم موجب',
            details: {},
          },
        });
      }
      product.price = price;
    }

    product.updatedAt = Date.now();
    await product.save();

    // Return success response
    res.json({
      success: true,
      data: {
        id: product.id,
        name: product.name,
        price: product.price,
      },
    });
  } catch (error) {
    next(error);
  }
};

/**
 * Delete a product (Admin only)
 * DELETE /api/products/:id
 */
const deleteProduct = async (req, res, next) => {
  try {
    const { id } = req.params;

    const product = await Product.findOne({ id });

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

    await Product.deleteOne({ id });

    res.json({
      success: true,
      data: {
        message: 'تم حذف المنتج بنجاح',
      },
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  createProduct,
  getProducts,
  updateProduct,
  deleteProduct,
};
