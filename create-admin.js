const https = require('https');

const BACKEND_URL = 'https://factory-production-d0af.up.railway.app';

console.log('🔧 Creating admin user on Railway backend...\n');

// First, check if backend is alive
https.get(`${BACKEND_URL}/health`, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('✅ Backend is online!');
    console.log(`Response: ${data}\n`);
    
    // Now create admin user
    const postData = JSON.stringify({});
    
    const options = {
      hostname: 'factory-production-d0af.up.railway.app',
      port: 443,
      path: '/setup-admin',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': postData.length
      }
    };
    
    console.log('📝 Creating admin user...\n');
    
    const req = https.request(options, (res) => {
      let responseData = '';
      
      res.on('data', (chunk) => {
        responseData += chunk;
      });
      
      res.on('end', () => {
        try {
          const result = JSON.parse(responseData);
          
          if (result.success) {
            console.log('✅ SUCCESS!\n');
            if (result.alreadyExists) {
              console.log('ℹ️  Admin user already exists');
            } else {
              console.log('🎉 Admin user created successfully!');
            }
            console.log('\n📋 Login Credentials:');
            console.log('   Username: admin');
            console.log('   Password: admin123');
            console.log('\n✨ You can now login to your mobile app!');
          } else {
            console.log('❌ ERROR:', result.error);
            console.log('\nThis might mean the /setup-admin endpoint is not deployed yet.');
            console.log('Please run: cd backend && railway up');
          }
        } catch (e) {
          console.log('❌ Failed to parse response:', responseData);
        }
      });
    });
    
    req.on('error', (error) => {
      console.error('❌ Error creating admin:', error.message);
    });
    
    req.write(postData);
    req.end();
  });
}).on('error', (error) => {
  console.error('❌ Backend is not responding:', error.message);
  console.log('\nPossible issues:');
  console.log('1. Railway deployment is still starting up (wait 1-2 minutes)');
  console.log('2. Backend URL has changed');
  console.log('3. Network connectivity issue');
});
