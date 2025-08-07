const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Initialize Firebase Admin
admin.initializeApp();

// Cloud Function to check if an Apple user exists
exports.checkAppleUserExists = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Only accept POST requests
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const { appleId } = req.body;

    // Validate input
    if (!appleId) {
      return res.status(400).json({
        error: 'Apple ID is required',
      });
    }

    console.log('Checking for Apple ID:', appleId);

    // Query Firestore for user with this Apple ID
    const usersRef = admin.firestore().collection('users');
    const querySnapshot = await usersRef
      .where('appleId', '==', appleId)
      .limit(1)
      .get();

    // Return whether user exists
    res.status(200).json({
      exists: !querySnapshot.empty,
      message: querySnapshot.empty ? 'User not found' : 'User exists',
    });
  } catch (error) {
    console.error('Error checking Apple user:', error);
    res.status(500).json({
      error: 'An error occurred while checking user existence',
    });
  }
});

// Cloud Function to check if a Google user exists
exports.checkGoogleUserExists = functions.https.onRequest(async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  // Only accept POST requests
  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const { email } = req.body;

    // Validate input
    if (!email) {
      return res.status(400).json({
        error: 'Email is required',
      });
    }

    console.log('Checking for email:', email);

    // Query Firestore for user with this email
    const usersRef = admin.firestore().collection('users');
    const querySnapshot = await usersRef
      .where('email', '==', email)
      .limit(1)
      .get();

    // Return whether user exists
    res.status(200).json({
      exists: !querySnapshot.empty,
      message: querySnapshot.empty ? 'User not found' : 'User exists',
    });
  } catch (error) {
    console.error('Error checking Google user:', error);
    res.status(500).json({
      error: 'An error occurred while checking user existence',
    });
  }
});
