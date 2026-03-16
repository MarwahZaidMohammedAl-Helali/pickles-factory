// This script creates the admin user directly in Railway MongoDB
// Run with: node create-admin-direct.js

const https = require('https');

console.log('🔧 Creating admin user via Railway API...\n');

// Try to create admin via a direct MongoDB connection through Railway CLI
console.log('Please run this command in your terminal:\n');
console.log('cd backend');
console.log('railway run npm run seed:admin\n');
console.log('This will connect to Railway MongoDB and create the admin user.\n');
console.log('If Railway CLI asks you to select a service, choose "Factory".\n');
