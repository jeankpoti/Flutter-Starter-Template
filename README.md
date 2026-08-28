# MathGenie AI

AI-powered math homework solver with study tools, flashcards, and quizzes.

## Tech Stack

- **Frontend**: Flutter (iOS, Android, Web)
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Functions)
- **AI**: Firebase AI (Google Gemini)
- **Subscriptions**: RevenueCat
- **Analytics & Marketing**: Multi-platform attribution tracking

## Marketing & Analytics Stack

This app implements a comprehensive marketing analytics stack for ad attribution, conversion tracking, and user lifecycle management.

### Analytics Platforms Integrated

| Platform | Purpose | Package |
|----------|---------|---------|
| **Firebase Analytics** | Core analytics, Google Ads integration | `firebase_analytics` |
| **PostHog** | Product analytics, feature flags | `posthog_flutter` |
| **Meta (Facebook)** | Facebook/Instagram Ads attribution | `facebook_app_events` |
| **TikTok** | TikTok Ads attribution | `tiktok_events_sdk` |
| **Tenjin** | Mobile attribution, cross-platform tracking | `tenjin_plugin` |

### Events Tracked

#### Acquisition Events
- `first_open` / `app_first_launch` - New installs
- `sign_up` - User registration (with method: google/apple/email)
- `login` - User login

#### Monetization Events
- `paywall_viewed` - Subscription screen viewed
- `begin_checkout` - User initiated purchase
- `start_trial` - Free trial started
- `trial_conversion` - Trial converted to paid
- `purchase` - Subscription purchased (with revenue data)
- `subscription_renewal` - Subscription renewed
- `subscription_cancellation` - User cancelled
- `refund` - Refund processed

#### Subscription Lifecycle (RevenueCat)
All RevenueCat webhook events are tracked:
- Initial purchase, Renewal, Product change
- Cancellation, Billing issue, Uncancellation
- Subscription paused/extended/expired
- Refund, Non-renewing purchase

### Cloud Functions (Email Automation)

RevenueCat webhooks trigger automated emails via Resend:

| Event | Email Sent |
|-------|------------|
| New signup | Welcome email |
| Trial started | Trial welcome |
| Trial expired | Win-back offer (24h delay) |
| Subscription cancelled | Win-back offer (7d delay) |
| Billing issue | Payment update reminder |
| Renewal | Thank you email |

### Configuration Files

```
lib/core/config/
├── posthog_config.dart      # PostHog API key
├── tenjin_config.dart       # Tenjin SDK key
lib/core/services/
├── analytics_service.dart           # Main analytics orchestrator
├── posthog_service.dart             # PostHog wrapper
├── meta_analytics_service.dart      # Meta/Facebook wrapper
├── tiktok_analytics_service.dart    # TikTok wrapper
├── tenjin_analytics_service.dart    # Tenjin wrapper
```

### Setup Checklist

1. **Firebase**: Configure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
2. **Meta**: Add Facebook App ID to `Info.plist` and `AndroidManifest.xml`
3. **TikTok**: Add TikTok App ID to config
4. **Tenjin**: Add SDK key to `tenjin_config.dart`
5. **PostHog**: Add API key to `posthog_config.dart`
6. **RevenueCat**: Configure webhook URL to Cloud Function endpoint
7. **Resend**: Set `RESEND_API_KEY` secret in Firebase Functions

### iOS App Tracking Transparency

The app requests ATT permission for ad attribution:
```dart
await AnalyticsService.requestTrackingAuthorization();
```

## Development

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run

# Deploy Cloud Functions
cd functions && firebase deploy --only functions
```

## Project Structure

```
lib/
├── core/           # Services, config, utilities
├── features/       # Feature modules (account, solve, study, subscription)
├── common_widgets/ # Reusable UI components
├── constants/      # App constants
└── l10n/          # Localization (EN, FR, ES)

functions/          # Firebase Cloud Functions
├── index.js        # RevenueCat webhooks, email automation
```
