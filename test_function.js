const { initializeApp } = require('firebase/app');
const { getFunctions, httpsCallable } = require('firebase/functions');

// Your Firebase config
const firebaseConfig = {
  projectId: "math-homework-ai",
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const functions = getFunctions(app);

// Test the function
async function testFunction() {
  const checkAppleUserExists = httpsCallable(functions, 'checkAppleUserExists');
  
  try {
    console.log('Calling function with data:', { appleId: 'test123' });
    const result = await checkAppleUserExists({ appleId: 'test123' });
    console.log('Result:', result.data);
  } catch (error) {
    console.error('Error:', error.code, error.message);
  }
}

testFunction();