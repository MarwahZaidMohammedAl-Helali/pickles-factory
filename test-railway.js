// Simple script to test Railway deployment
const https = require('https');

const baseUrl = 'https://factory-production-d0af.up.railway.app';

console.log('🧪 Testing Railway Deployment...\n');
console.log('Base URL:', baseUrl);
console.log('=' .repeat(50));

// Test 1: Health check or root endpoint
function testEndpoint(path, description) {
  return new Promise((resolve) => {
    console.log(`\n📍 Testing: ${description}`);
    console.log(`   URL: ${baseUrl}${path}`);
    
    https.get(`${baseUrl}${path}`, (res) => {
      let data = '';
      
      res.on('data', (chunk) => {
        data += chunk;
      });
      
      res.on('end', () => {
        console.log(`   Status: ${res.statusCode}`);
        if (res.statusCode === 200) {
          console.log('   ✅ SUCCESS');
          try {
            const json = JSON.parse(data);
            console.log('   Response:', JSON.stringify(json, null, 2).substring(0, 200));
          } catch (e) {
            console.log('   Response:', data.substring(0, 200));
          }
        } else {
          console.log('   ❌ FAILED');
          console.log('   Response:', data.substring(0, 200));
        }
        resolve();
      });
    }).on('error', (err) => {
      console.log('   ❌ ERROR:', err.message);
      resolve();
    });
  });
}

async function runTests() {
  await testEndpoint('/api/products', 'Products Endpoint');
  await testEndpoint('/api/restaurants', 'Restaurants Endpoint');
  await testEndpoint('/', 'Root Endpoint');
  
  console.log('\n' + '='.repeat(50));
  console.log('✅ Testing Complete!');
  console.log('\nIf you see 200 status codes, your Railway is working! 🎉');
  console.log('If you see errors, your Railway deployment needs attention.');
}

runTests();
