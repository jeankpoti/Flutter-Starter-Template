const { onRequest } = require('firebase-functions/v2/https');
const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const { defineSecret } = require('firebase-functions/params');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore, FieldValue, Timestamp } = require('firebase-admin/firestore');
const { Resend } = require('resend');

// Initialize Firebase Admin
initializeApp();

// Define secrets
const resendApiKey = defineSecret('RESEND_API_KEY');

// Initialize Resend lazily (inside functions that need it)
let resendInstance = null;
function getResend() {
  if (!resendInstance) {
    resendInstance = new Resend(resendApiKey.value() || process.env.RESEND_API_KEY);
  }
  return resendInstance;
}

// Firestore reference
const db = getFirestore();

// =============================================================================
// EMAIL TEMPLATES
// =============================================================================

const emailTemplates = {
  welcome: (userName) => ({
    subject: 'Welcome to MathGenie AI! 🎓 Here\'s how to get started',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">Welcome to MathGenie AI! 🎓</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Thanks for joining MathGenie AI! Here's how to get started:</p>

        <div style="background: #f3f4f6; padding: 20px; border-radius: 12px; margin: 20px 0;">
          <h3 style="margin-top: 0;">📸 Scan Any Math Problem</h3>
          <p>Take a photo of handwritten or typed math problems and get instant step-by-step solutions.</p>

          <h3>📚 Create Flashcards</h3>
          <p>Turn your study materials into interactive flashcards with spaced repetition.</p>

          <h3>📝 AI-Powered Quizzes</h3>
          <p>Generate quizzes from your notes to test your knowledge.</p>
        </div>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Open MathGenie AI</a>

        <p style="margin-top: 30px; color: #6b7280;">Happy studying!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  trialStarted: (userName, trialEndDate) => ({
    subject: 'Your 7-day free trial is active! 🚀',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">Your Free Trial is Active! 🚀</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Great news! Your 7-day free trial of MathGenie AI Premium is now active.</p>

        <div style="background: #ecfdf5; padding: 20px; border-radius: 12px; margin: 20px 0; border-left: 4px solid #10b981;">
          <h3 style="margin-top: 0; color: #059669;">✅ What's Unlocked:</h3>
          <ul style="color: #047857;">
            <li>Unlimited math problem scans</li>
            <li>All AI-powered features</li>
            <li>Unlimited flashcards & quizzes</li>
            <li>Priority support</li>
          </ul>
        </div>

        <p><strong>Trial ends:</strong> ${trialEndDate || 'in 7 days'}</p>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Start Learning Now</a>

        <p style="margin-top: 30px; color: #6b7280;">Make the most of your trial!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  trialWinback: (userName, discountCode) => ({
    subject: 'We noticed you didn\'t subscribe - here\'s 20% off',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">We Miss You! 💙</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>We noticed your trial ended and you haven't subscribed yet. Was something missing?</p>

        <p>We'd love to hear your feedback - just reply to this email!</p>

        <div style="background: #fef3c7; padding: 20px; border-radius: 12px; margin: 20px 0; border-left: 4px solid #f59e0b;">
          <h3 style="margin-top: 0; color: #b45309;">🎁 Special Offer: 20% Off</h3>
          <p style="color: #92400e;">Use code <strong>${discountCode || 'COMEBACK20'}</strong> to get 20% off your first month.</p>
          <p style="color: #92400e; font-size: 14px;">Valid for 48 hours only!</p>
        </div>

        <a href="https://mathgenie.ai/subscribe" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Claim Your Discount</a>

        <p style="margin-top: 30px; color: #6b7280;">Hope to see you back soon!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  churnedWinback: (userName, discountCode) => ({
    subject: 'MathGenie AI just got better - come back for 30% off',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">We've Made Improvements! ✨</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Since you've been away, we've added some exciting new features to MathGenie AI:</p>

        <div style="background: #f3f4f6; padding: 20px; border-radius: 12px; margin: 20px 0;">
          <ul>
            <li>🧠 Smarter AI explanations</li>
            <li>📊 Better study analytics</li>
            <li>⚡ Faster problem recognition</li>
          </ul>
        </div>

        <div style="background: #fee2e2; padding: 20px; border-radius: 12px; margin: 20px 0; border-left: 4px solid #ef4444;">
          <h3 style="margin-top: 0; color: #b91c1c;">🔥 Limited Time: 30% Off</h3>
          <p style="color: #991b1b;">Use code <strong>${discountCode || 'WELCOME30'}</strong> to get 30% off for 3 months.</p>
        </div>

        <a href="https://mathgenie.ai/subscribe" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Reactivate Now</a>

        <p style="margin-top: 30px; color: #6b7280;">We'd love to have you back!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  founderFeedback: (userName) => ({
    subject: 'Quick question about MathGenie AI',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <p>Hey ${userName || 'there'},</p>

        <p>I'm Jean, the creator of MathGenie AI.</p>

        <p>Are you getting the help you need with your math homework?</p>

        <p>Reply directly to this email if you're stuck on anything or want to see a feature added. I read every response.</p>

        <p style="margin-top: 30px;">- Jean</p>

        <p style="color: #6b7280; font-size: 12px; margin-top: 40px;">P.S. If you'd like to chat directly, book a 15-minute call and get 1 month free: <a href="https://calendly.com/mathgenie/feedback">Schedule a call</a></p>
      </div>
    `,
  }),

  renewal: (userName) => ({
    subject: 'Thanks for staying with MathGenie AI! 💙',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">Thank You! 💙</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Your MathGenie AI subscription has been renewed. Thank you for continuing to learn with us!</p>

        <p>Keep up the great work with your studies!</p>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Continue Learning</a>

        <p style="margin-top: 30px; color: #6b7280;">The MathGenie AI Team</p>
      </div>
    `,
  }),

  billingIssue: (userName) => ({
    subject: '⚠️ Payment issue with your MathGenie AI subscription',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #ef4444;">Payment Issue ⚠️</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>We had trouble processing your payment for MathGenie AI Premium.</p>

        <p>Please update your payment method to keep your subscription active and continue accessing all premium features.</p>

        <a href="https://mathgenie.ai/billing" style="display: inline-block; background: #ef4444; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Update Payment Method</a>

        <p style="margin-top: 30px; color: #6b7280;">Need help? Just reply to this email.<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  productChange: (userName, newProduct) => ({
    subject: 'Your MathGenie AI plan has been updated',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">Plan Updated! 📋</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Your MathGenie AI subscription has been successfully updated${newProduct ? ` to ${newProduct}` : ''}.</p>

        <p>Your new plan is now active. Continue enjoying all the features!</p>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Continue Learning</a>

        <p style="margin-top: 30px; color: #6b7280;">The MathGenie AI Team</p>
      </div>
    `,
  }),

  uncancellation: (userName) => ({
    subject: 'Welcome back to MathGenie AI! 🎉',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #2563eb;">Welcome Back! 🎉</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Great news! Your MathGenie AI subscription has been reactivated.</p>

        <p>We're thrilled to have you back. All your premium features are ready and waiting for you!</p>

        <div style="background: #ecfdf5; padding: 20px; border-radius: 12px; margin: 20px 0; border-left: 4px solid #10b981;">
          <h3 style="margin-top: 0; color: #059669;">✅ Your Premium Features:</h3>
          <ul style="color: #047857;">
            <li>Unlimited math problem scans</li>
            <li>All AI-powered features</li>
            <li>Unlimited flashcards & quizzes</li>
          </ul>
        </div>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #2563eb; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Get Back to Learning</a>

        <p style="margin-top: 30px; color: #6b7280;">The MathGenie AI Team</p>
      </div>
    `,
  }),

  subscriptionPaused: (userName) => ({
    subject: 'Your MathGenie AI subscription is paused',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #f59e0b;">Subscription Paused ⏸️</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Your MathGenie AI subscription has been paused. We'll miss you!</p>

        <p>Your premium features will be available again when your subscription resumes. In the meantime, you can still use our free features.</p>

        <p>If you change your mind, you can resume your subscription anytime from the app.</p>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #f59e0b; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Resume Subscription</a>

        <p style="margin-top: 30px; color: #6b7280;">We hope to see you back soon!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  subscriptionExtended: (userName) => ({
    subject: 'Good news! Your subscription has been extended 🎁',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #10b981;">Subscription Extended! 🎁</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>Great news! Your MathGenie AI subscription has been extended.</p>

        <p>Enjoy more time with all your premium features!</p>

        <a href="https://mathgenie.ai/app" style="display: inline-block; background: #10b981; color: white; padding: 12px 24px; border-radius: 8px; text-decoration: none; font-weight: 600;">Continue Learning</a>

        <p style="margin-top: 30px; color: #6b7280;">Happy studying!<br>The MathGenie AI Team</p>
      </div>
    `,
  }),

  refund: (userName) => ({
    subject: 'Your MathGenie AI refund has been processed',
    html: `
      <div style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px;">
        <h1 style="color: #6b7280;">Refund Processed</h1>
        <p>Hey ${userName || 'there'},</p>
        <p>We've processed your refund for MathGenie AI. We're sorry to see you go.</p>

        <p>If there was anything we could have done better, we'd love to hear your feedback - just reply to this email.</p>

        <p>You're always welcome back! If you decide to give us another try, we'll be here.</p>

        <p style="margin-top: 30px; color: #6b7280;">Wishing you all the best,<br>The MathGenie AI Team</p>
      </div>
    `,
  }),
};

// =============================================================================
// EMAIL SENDING HELPER
// =============================================================================

async function sendEmail(to, templateName, templateData = {}) {
  try {
    const template = emailTemplates[templateName];
    if (!template) {
      console.error(`Email template '${templateName}' not found`);
      return { success: false, error: 'Template not found' };
    }

    const { subject, html } = typeof template === 'function'
      ? template(templateData.userName, templateData.extra)
      : template;

    const resend = getResend();
    const { data, error } = await resend.emails.send({
      from: 'MathGenie AI <hello@mathgenie.ai>',
      to: [to],
      subject: subject,
      html: html,
    });

    if (error) {
      console.error('Resend error:', error);
      return { success: false, error };
    }

    console.log(`Email sent successfully: ${templateName} to ${to}`, data);
    return { success: true, data };
  } catch (error) {
    console.error('Error sending email:', error);
    return { success: false, error: error.message };
  }
}

// =============================================================================
// REVENUECAT WEBHOOK HANDLER
// =============================================================================

exports.revenuecatWebhook = onRequest({ secrets: [resendApiKey], cors: true, invoker: 'public' }, async (req, res) => {
  // Enable CORS
  res.set('Access-Control-Allow-Origin', '*');
  res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  try {
    const event = req.body;
    const eventType = event.type;
    const appUserId = event.app_user_id;

    console.log(`RevenueCat webhook received: ${eventType} for user ${appUserId}`);

    // Get user data from Firestore
    let userEmail = null;
    let userName = null;

    if (appUserId) {
      const userDoc = await db.collection('users').doc(appUserId).get();
      if (userDoc.exists) {
        const userData = userDoc.data();
        userEmail = userData.email;
        userName = userData.displayName || userData.fullName || null;
      }
    }

    if (!userEmail) {
      console.log('No email found for user, skipping email');
      res.status(200).json({ success: true, message: 'No email found' });
      return;
    }

    // Handle different event types
    switch (eventType) {
      case 'INITIAL_PURCHASE':
      case 'NON_RENEWING_PURCHASE':
        // Check if it's a trial
        if (event.period_type === 'TRIAL') {
          await sendEmail(userEmail, 'trialStarted', {
            userName,
            extra: event.expiration_at_ms
              ? new Date(event.expiration_at_ms).toLocaleDateString()
              : null
          });
        } else {
          await sendEmail(userEmail, 'welcome', { userName });
        }
        break;

      case 'RENEWAL':
        await sendEmail(userEmail, 'renewal', { userName });
        break;

      case 'CANCELLATION':
        // Schedule win-back email for 7 days later
        await db.collection('scheduled_emails').add({
          userId: appUserId,
          email: userEmail,
          userName: userName,
          templateName: 'churnedWinback',
          scheduledFor: Timestamp.fromDate(
            new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
          ),
          status: 'pending',
          createdAt: FieldValue.serverTimestamp(),
        });
        console.log(`Scheduled churned win-back email for ${userEmail} in 7 days`);
        break;

      case 'EXPIRATION':
        // Schedule trial win-back email for 24 hours later
        await db.collection('scheduled_emails').add({
          userId: appUserId,
          email: userEmail,
          userName: userName,
          templateName: 'trialWinback',
          scheduledFor: Timestamp.fromDate(
            new Date(Date.now() + 24 * 60 * 60 * 1000) // 24 hours
          ),
          status: 'pending',
          createdAt: FieldValue.serverTimestamp(),
        });
        console.log(`Scheduled trial win-back email for ${userEmail} in 24 hours`);
        break;

      case 'BILLING_ISSUE':
        await sendEmail(userEmail, 'billingIssue', { userName });
        break;

      case 'PRODUCT_CHANGE':
        await sendEmail(userEmail, 'productChange', {
          userName,
          extra: event.new_product_id || null
        });
        break;

      case 'UNCANCELLATION':
        await sendEmail(userEmail, 'uncancellation', { userName });
        break;

      case 'SUBSCRIPTION_PAUSED':
        await sendEmail(userEmail, 'subscriptionPaused', { userName });
        break;

      case 'SUBSCRIPTION_EXTENDED':
        await sendEmail(userEmail, 'subscriptionExtended', { userName });
        break;

      case 'REFUND':
        await sendEmail(userEmail, 'refund', { userName });
        break;

      // Log-only events (no email needed)
      case 'TRANSFER':
      case 'INVOICE_ISSUANCE':
      case 'TEMPORARY_ENTITLEMENT_GRANT':
      case 'REFUND_REVERSED':
      case 'VIRTUAL_CURRENCY_TRANSACTION':
      case 'EXPERIMENT_ENROLLMENT':
      case 'PURCHASE_REDEEMED':
        console.log(`Event logged (no email): ${eventType} for user ${appUserId}`);
        break;

      default:
        console.log(`Unhandled event type: ${eventType}`);
    }

    res.status(200).json({ success: true, eventType });
  } catch (error) {
    console.error('Error processing RevenueCat webhook:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// =============================================================================
// SCHEDULED EMAIL PROCESSOR (runs every hour)
// =============================================================================

exports.processScheduledEmails = onSchedule({ schedule: 'every 60 minutes', secrets: [resendApiKey] }, async () => {
  try {
    const now = Timestamp.now();

    // Get all pending emails that are due
    const snapshot = await db.collection('scheduled_emails')
      .where('status', '==', 'pending')
      .where('scheduledFor', '<=', now)
      .limit(100)
      .get();

    console.log(`Processing ${snapshot.size} scheduled emails`);

    const batch = db.batch();

    for (const doc of snapshot.docs) {
      const data = doc.data();

      // Send the email
      const result = await sendEmail(data.email, data.templateName, {
        userName: data.userName,
        extra: data.extra,
      });

      // Update status
      batch.update(doc.ref, {
        status: result.success ? 'sent' : 'failed',
        sentAt: FieldValue.serverTimestamp(),
        error: result.error || null,
      });
    }

    await batch.commit();
    console.log('Scheduled emails processed successfully');
  } catch (error) {
    console.error('Error processing scheduled emails:', error);
  }
});

// =============================================================================
// WELCOME EMAIL ON USER SIGN-UP (Firestore trigger)
// =============================================================================

exports.sendWelcomeEmailOnSignUp = onDocumentCreated({ document: 'users/{userId}', secrets: [resendApiKey] }, async (event) => {
  const snap = event.data;
  if (!snap) {
    console.log('No data in snapshot');
    return;
  }

  const userData = snap.data();
  const email = userData.email;
  const userName = userData.displayName || userData.fullName || null;
  const userId = event.params.userId;

  if (!email) {
    console.log('No email found for new user, skipping welcome email');
    return;
  }

  // Send welcome email
  await sendEmail(email, 'welcome', { userName });

  // Schedule founder feedback email for 3 days later
  await db.collection('scheduled_emails').add({
    userId: userId,
    email: email,
    userName: userName,
    templateName: 'founderFeedback',
    scheduledFor: Timestamp.fromDate(
      new Date(Date.now() + 3 * 24 * 60 * 60 * 1000) // 3 days
    ),
    status: 'pending',
    createdAt: FieldValue.serverTimestamp(),
  });

  console.log(`Welcome email sent and founder feedback scheduled for ${email}`);
});

// Cloud Function to check if an Apple user exists
exports.checkAppleUserExists = onRequest({ cors: true }, async (req, res) => {
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

    // Query Firestore for user with this Apple ID
    const usersRef = db.collection('users');
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
exports.checkGoogleUserExists = onRequest({ cors: true }, async (req, res) => {
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

    // Query Firestore for user with this email
    const usersRef = db.collection('users');
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
