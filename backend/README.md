# Pickles Factory Management System - Backend

Backend API for the Pickles Factory Management System.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

3. Make sure MongoDB is running locally or update MONGODB_URI in .env

4. Start the server:
```bash
# Development mode with auto-reload
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- POST /api/auth/login - Login with username and password

### Users (Admin only)
- GET /api/users - List all staff members
- POST /api/users - Create new staff member

### Restaurants
- GET /api/restaurants - List all restaurants
- POST /api/restaurants - Create new restaurant
- GET /api/restaurants/:id - Get restaurant details with balance

### Products (Admin only for create/update/delete)
- GET /api/products - List all products
- POST /api/products - Create new product
- PUT /api/products/:id - Update product
- DELETE /api/products/:id - Delete product

### Transactions
- GET /api/transactions?restaurantId=:id - Get transactions for a restaurant
- POST /api/transactions - Create new transaction

## Testing

```bash
npm test
```

## Project Structure

```
backend/
├── src/
│   ├── config/         # Configuration files
│   ├── controllers/    # Request handlers
│   ├── middleware/     # Custom middleware
│   ├── models/         # Database models
│   ├── routes/         # API routes
│   └── server.js       # Entry point
├── tests/              # Test files
├── .env                # Environment variables
└── package.json        # Dependencies
```
