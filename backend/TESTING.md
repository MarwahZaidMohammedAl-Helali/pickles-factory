# Testing Guide

## Manual Testing for Authentication

### Prerequisites

1. Make sure MongoDB is running
2. Install dependencies: `npm install`
3. Seed an admin user: `npm run seed:admin`
4. Start the server: `npm run dev`

### Test 1: Health Check

```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "status": "ok",
  "message": "Server is running"
}
```

### Test 2: Login with Valid Credentials

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "admin123"}'
```

Expected response (200 OK):
```json
{
  "success": true,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": "uuid-here",
      "username": "admin",
      "role": "admin"
    }
  }
}
```

### Test 3: Login with Invalid Credentials

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "wrongpassword"}'
```

Expected response (401 Unauthorized):
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "اسم المستخدم أو كلمة المرور غير صحيحة",
    "details": {}
  }
}
```

### Test 4: Login with Missing Fields

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin"}'
```

Expected response (400 Bad Request):
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "اسم المستخدم وكلمة المرور مطلوبان",
    "details": {}
  }
}
```

### Test 5: Access Protected Route Without Token

Once we have protected routes, test:

```bash
curl http://localhost:3000/api/users
```

Expected response (401 Unauthorized):
```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "الرجاء تسجيل الدخول للوصول إلى هذا المورد",
    "details": {}
  }
}
```

### Test 6: Access Protected Route With Valid Token

First, login and copy the token, then:

```bash
curl http://localhost:3000/api/users \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Automated Tests

Run automated tests with:

```bash
npm test
```

## Notes

- All error messages are in Arabic as per requirements
- JWT tokens expire after 7 days (configurable in .env)
- Passwords are hashed using bcrypt with 10 salt rounds
