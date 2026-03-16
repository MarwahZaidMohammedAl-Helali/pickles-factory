const request = require('supertest');
const mongoose = require('mongoose');
const app = require('../src/server');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const bcrypt = require('bcrypt');

describe('Product CRUD Operations', () => {
  let adminToken;
  let staffToken;

  beforeAll(async () => {
    // Connect to test database
    if (mongoose.connection.readyState === 0) {
      await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/pickles-factory-test');
    }

    // Clear existing data
    await User.deleteMany({});
    await Product.deleteMany({});

    // Create admin user
    const adminPassword = await bcrypt.hash('admin123', 10);
    const admin = await User.create({
      username: 'admin',
      passwordHash: adminPassword,
      role: 'admin',
    });

    // Create staff user
    const staffPassword = await bcrypt.hash('staff123', 10);
    const staff = await User.create({
      username: 'staff',
      passwordHash: staffPassword,
      role: 'staff',
    });

    // Login as admin
    const adminLoginRes = await request(app)
      .post('/api/auth/login')
      .send({ username: 'admin', password: 'admin123' });
    adminToken = adminLoginRes.body.data.token;

    // Login as staff
    const staffLoginRes = await request(app)
      .post('/api/auth/login')
      .send({ username: 'staff', password: 'staff123' });
    staffToken = staffLoginRes.body.data.token;
  });

  afterAll(async () => {
    await User.deleteMany({});
    await Product.deleteMany({});
    await mongoose.connection.close();
  });

  describe('POST /api/products', () => {
    it('should create a product when admin is authenticated', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'مخلل خيار',
          price: 25.5,
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data).toHaveProperty('id');
      expect(res.body.data.name).toBe('مخلل خيار');
      expect(res.body.data.price).toBe(25.5);
    });

    it('should reject product creation when staff tries to create', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${staffToken}`)
        .send({
          name: 'مخلل زيتون',
          price: 30,
        });

      expect(res.status).toBe(403);
      expect(res.body.success).toBe(false);
    });

    it('should reject product creation without name', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          price: 25,
        });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it('should reject product creation without price', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'مخلل جزر',
        });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });

    it('should reject product creation with negative price', async () => {
      const res = await request(app)
        .post('/api/products')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'مخلل فلفل',
          price: -10,
        });

      expect(res.status).toBe(400);
      expect(res.body.success).toBe(false);
    });
  });

  describe('GET /api/products', () => {
    it('should return all products for admin', async () => {
      const res = await request(app)
        .get('/api/products')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should return all products for staff', async () => {
      const res = await request(app)
        .get('/api/products')
        .set('Authorization', `Bearer ${staffToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(Array.isArray(res.body.data)).toBe(true);
    });
  });

  describe('PUT /api/products/:id', () => {
    let productId;

    beforeAll(async () => {
      const product = await Product.create({
        name: 'مخلل لفت',
        price: 20,
      });
      productId = product.id;
    });

    it('should update product when admin is authenticated', async () => {
      const res = await request(app)
        .put(`/api/products/${productId}`)
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'مخلل لفت محدث',
          price: 22,
        });

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);
      expect(res.body.data.name).toBe('مخلل لفت محدث');
      expect(res.body.data.price).toBe(22);
    });

    it('should reject update when staff tries to update', async () => {
      const res = await request(app)
        .put(`/api/products/${productId}`)
        .set('Authorization', `Bearer ${staffToken}`)
        .send({
          name: 'محاولة تحديث',
          price: 25,
        });

      expect(res.status).toBe(403);
      expect(res.body.success).toBe(false);
    });

    it('should return 404 for non-existent product', async () => {
      const res = await request(app)
        .put('/api/products/non-existent-id')
        .set('Authorization', `Bearer ${adminToken}`)
        .send({
          name: 'منتج',
          price: 20,
        });

      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });

  describe('DELETE /api/products/:id', () => {
    let productId;

    beforeEach(async () => {
      const product = await Product.create({
        name: 'مخلل للحذف',
        price: 15,
      });
      productId = product.id;
    });

    it('should delete product when admin is authenticated', async () => {
      const res = await request(app)
        .delete(`/api/products/${productId}`)
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(200);
      expect(res.body.success).toBe(true);

      // Verify product is deleted
      const product = await Product.findOne({ id: productId });
      expect(product).toBeNull();
    });

    it('should reject delete when staff tries to delete', async () => {
      const res = await request(app)
        .delete(`/api/products/${productId}`)
        .set('Authorization', `Bearer ${staffToken}`);

      expect(res.status).toBe(403);
      expect(res.body.success).toBe(false);
    });

    it('should return 404 for non-existent product', async () => {
      const res = await request(app)
        .delete('/api/products/non-existent-id')
        .set('Authorization', `Bearer ${adminToken}`);

      expect(res.status).toBe(404);
      expect(res.body.success).toBe(false);
    });
  });
});
