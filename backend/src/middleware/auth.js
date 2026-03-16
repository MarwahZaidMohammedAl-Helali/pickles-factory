const { verifyToken } = require('../utils/auth');

/**
 * Middleware to verify JWT token and attach user info to request
 */
const authenticate = (req, res, next) => {
  try {
    // Get token from Authorization header
    const authHeader = req.headers.authorization;
    
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'الرجاء تسجيل الدخول للوصول إلى هذا المورد',
          details: {},
        },
      });
    }

    // Extract token
    const token = authHeader.substring(7); // Remove 'Bearer ' prefix
    
    // Verify token
    const decoded = verifyToken(token);
    
    // Attach user info to request
    req.user = {
      id: decoded.id,
      username: decoded.username,
      role: decoded.role,
    };
    
    next();
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({
        success: false,
        error: {
          code: 'INVALID_TOKEN',
          message: 'رمز المصادقة غير صالح',
          details: {},
        },
      });
    }
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({
        success: false,
        error: {
          code: 'TOKEN_EXPIRED',
          message: 'انتهت صلاحية رمز المصادقة، الرجاء تسجيل الدخول مرة أخرى',
          details: {},
        },
      });
    }
    
    next(error);
  }
};

/**
 * Middleware to check if user has required role
 * @param {...string} roles - Allowed roles
 */
const authorize = (...roles) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: 'الرجاء تسجيل الدخول للوصول إلى هذا المورد',
          details: {},
        },
      });
    }
    
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: 'ليس لديك صلاحية للوصول إلى هذا المورد',
          details: {},
        },
      });
    }
    
    next();
  };
};

module.exports = {
  authenticate,
  authorize,
};
