/**
 * Input validation middleware
 * Provides reusable validation functions for request data
 */

/**
 * Validate required fields in request body
 * @param {Array} fields - Array of required field names
 */
const validateRequiredFields = (fields) => {
  return (req, res, next) => {
    const missingFields = [];

    for (const field of fields) {
      if (req.body[field] === undefined || req.body[field] === null) {
        missingFields.push(field);
      }
    }

    if (missingFields.length > 0) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: 'حقول مطلوبة مفقودة',
          details: { missingFields },
        },
      });
    }

    next();
  };
};

/**
 * Validate that a field is a non-empty string
 * @param {String} fieldName - Name of the field to validate
 * @param {String} errorMessage - Custom error message in Arabic
 */
const validateNonEmptyString = (fieldName, errorMessage) => {
  return (req, res, next) => {
    const value = req.body[fieldName];

    if (value !== undefined && (typeof value !== 'string' || value.trim() === '')) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: errorMessage,
          details: { field: fieldName },
        },
      });
    }

    next();
  };
};

/**
 * Validate that a field is a positive number
 * @param {String} fieldName - Name of the field to validate
 * @param {String} errorMessage - Custom error message in Arabic
 */
const validatePositiveNumber = (fieldName, errorMessage) => {
  return (req, res, next) => {
    const value = req.body[fieldName];

    if (value !== undefined && (typeof value !== 'number' || value < 0)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: errorMessage,
          details: { field: fieldName },
        },
      });
    }

    next();
  };
};

/**
 * Validate that a field is a non-negative integer
 * @param {String} fieldName - Name of the field to validate
 * @param {String} errorMessage - Custom error message in Arabic
 */
const validateNonNegativeInteger = (fieldName, errorMessage) => {
  return (req, res, next) => {
    const value = req.body[fieldName];

    if (value !== undefined && (!Number.isInteger(value) || value < 0)) {
      return res.status(400).json({
        success: false,
        error: {
          code: 'VALIDATION_ERROR',
          message: errorMessage,
          details: { field: fieldName },
        },
      });
    }

    next();
  };
};

/**
 * Validate that a field is a valid date
 * @param {String} fieldName - Name of the field to validate
 * @param {String} errorMessage - Custom error message in Arabic
 */
const validateDate = (fieldName, errorMessage) => {
  return (req, res, next) => {
    const value = req.body[fieldName];

    if (value !== undefined) {
      const date = new Date(value);
      if (isNaN(date.getTime())) {
        return res.status(400).json({
          success: false,
          error: {
            code: 'VALIDATION_ERROR',
            message: errorMessage,
            details: { field: fieldName },
          },
        });
      }
    }

    next();
  };
};

/**
 * Sanitize string inputs by trimming whitespace
 * @param {Array} fields - Array of field names to sanitize
 */
const sanitizeStrings = (fields) => {
  return (req, res, next) => {
    for (const field of fields) {
      if (req.body[field] && typeof req.body[field] === 'string') {
        req.body[field] = req.body[field].trim();
      }
    }
    next();
  };
};

module.exports = {
  validateRequiredFields,
  validateNonEmptyString,
  validatePositiveNumber,
  validateNonNegativeInteger,
  validateDate,
  sanitizeStrings,
};
