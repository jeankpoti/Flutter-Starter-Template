# Firebase Remote Config Ad Control Setup Guide

This guide explains how to set up and manage flexible ad control for your math_ai app using Firebase Remote Config.

## Overview

The app now uses Firebase Remote Config to control ad display based on user email addresses. This allows you to:
- **Disable ads completely** for Play Console review
- **Enable ads only for specific test users** 
- **Control test vs production ads** 
- **Manage ad settings remotely** without app updates

## Firebase Console Setup

### Step 1: Access Remote Config
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your **math-homework-ai** project
3. Navigate to **Remote Config** in the left sidebar

### Step 2: Create Configuration Parameters

**IMPORTANT**: Parameter keys must be unique. Create each parameter only once, then update values as needed.

#### Parameter 1: `ads_completely_disabled` (Required)
- **Key**: `ads_completely_disabled`
- **Value Type**: **Boolean**
- **Default Value**: `true`
- **Description**: Emergency kill switch for all ads

#### Parameter 2: `ads_enabled_for_testing` (For Production Only)
- **Key**: `ads_enabled_for_testing`
- **Value Type**: **Boolean**
- **Default Value**: `true`
- **Description**: Master switch for ad testing

#### Parameter 3: `test_user_emails` (For Production Only)
- **Key**: `test_user_emails`
- **Value Type**: **String** (not array!)
- **Default Value**: `["*"]`
- **Description**: JSON array as string of test user emails
- **Examples**: 
  - All users: `["*"]`
  - Specific users: `["tester@gmail.com", "reviewer@playstore.com"]`
  - No users: `[]`

#### Parameter 4: `force_test_ads` (For Production Only)
- **Key**: `force_test_ads`
- **Value Type**: **Boolean**
- **Default Value**: `false`
- **Description**: Use test ad units instead of production

### Step 3: Publish Configuration
1. Click **Publish changes** in Firebase Console
2. Add a description like "Initial ad control setup"
3. Confirm the publish

## Usage Scenarios

### Scenario A: Testing/Play Console Review (No Ads)
**Goal**: Disable all ads during testing or app store review

**Required Parameter**:
- `ads_completely_disabled`: `true` (Boolean)

**Optional Parameters**: None needed

**Result**: No ads shown to anyone, including reviewers.

### Scenario B: Production (All Users See Ads)
**Goal**: Show real ads to all users

**Required Parameters**:
- `ads_completely_disabled`: `false` (Boolean)
- `ads_enabled_for_testing`: `true` (Boolean)
- `test_user_emails`: `["*"]` (String)
- `force_test_ads`: `false` (Boolean)

**Result**: All users see production ads.

### Scenario C: Limited Testing (Specific Users Only)
**Goal**: Show ads only to specific test accounts

**Required Parameters**:
- `ads_completely_disabled`: `false` (Boolean)
- `ads_enabled_for_testing`: `true` (Boolean)
- `test_user_emails`: `["test1@gmail.com", "test2@gmail.com"]` (String)
- `force_test_ads`: `true` (Boolean)

**Result**: Only specified emails see test ads, others skip ads entirely.

### Scenario D: Revenue Testing (Real Ads for Testers)
**Goal**: Test real ads with specific users

**Required Parameters**:
- `ads_completely_disabled`: `false` (Boolean)
- `ads_enabled_for_testing`: `true` (Boolean)
- `test_user_emails`: `["revenue-test@gmail.com"]` (String)
- `force_test_ads`: `false` (Boolean)

**Result**: Specified users see real ads, others skip ads.

## Quick Actions

### Emergency: Disable All Ads Immediately
**Just update one parameter:**
- `ads_completely_disabled`: `true` (Boolean)

### Switch from Testing to Production
**Update these parameters:**
- `ads_completely_disabled`: `false` (Boolean)
- Add `ads_enabled_for_testing`: `true` (Boolean)
- Add `test_user_emails`: `["*"]` (String)
- Add `force_test_ads`: `false` (Boolean)

### Switch from Production back to Testing
**Just update one parameter:**
- `ads_completely_disabled`: `true` (Boolean)

**Note**: Remember to use **String** type for `test_user_emails`, not array!

## Monitoring & Debugging

### Check Current Configuration Status
The app includes debugging capabilities. You can add this to your admin interface:

```dart
// Get current config status
final status = AdConfigService.getConfigStatus();
print('Ad Config Status: $status');
```

### Force Configuration Refresh
```dart
// Refresh config from Firebase
await AdConfigService.refreshConfig();
```

### Verify User Status
```dart
// Check if current user should see ads
final shouldShow = AdConfigService.shouldShowAds();
print('Should show ads: $shouldShow');

// Check if current user is a test user
final isTestUser = AdConfigService.isCurrentUserTestUser();
print('Is test user: $isTestUser');
```

## Ad Unit Configuration

The app automatically selects ad units based on `force_test_ads`:

### Test Ad Units (force_test_ads: true)
- **Android**: `ca-app-pub-3940256099942544/5224354917`
- **iOS**: `ca-app-pub-3940256099942544/1712485313`

### Production Ad Units (force_test_ads: false)
- **Android**: `ca-app-pub-9068204541773057/5566109912`
- **iOS**: `ca-app-pub-9068204541773057/3523897368`

## Best Practices

### 1. Play Console Submission
- Set `ads_completely_disabled: true` before submission
- Only enable ads after approval
- Use test emails for initial testing

### 2. Gradual Rollout
- Start with specific test emails
- Gradually expand the test user list
- Monitor performance and user feedback

### 3. Emergency Response
- Always keep `ads_completely_disabled` as emergency switch
- Monitor Firebase Console for any issues
- Have backup configuration ready

### 4. Testing Protocol
1. **Pre-submission**: All ads disabled
2. **Post-approval**: Enable for specific test emails
3. **Beta testing**: Expand test user list
4. **Production**: Enable for all users

## Troubleshooting

### Configuration Not Taking Effect
1. Check Firebase Console for published changes
2. Restart the app to fetch latest config
3. **If still not working**: Uninstall and reinstall the app (clears Remote Config cache)
4. **For testing**: Clear app data on Android or delete app on iOS
5. Verify user email matches test list exactly

**Note**: Firebase Remote Config has aggressive caching. During testing, you may need to reinstall the app to see immediate changes.

### Users Not Seeing Ads
1. Verify `ads_completely_disabled` is `false`
2. Check `ads_enabled_for_testing` is `true`
3. Confirm user email is in `test_user_emails` array
4. Ensure proper JSON format in email array

### Wrong Ad Units Showing
1. Check `force_test_ads` setting
2. Verify ad unit IDs in `AdService`
3. Confirm AdMob configuration

## Support

For issues with this ad control system:
1. Check Firebase Console configuration
2. Review app logs for Remote Config errors
3. Test with known working email addresses
4. Verify Firebase Remote Config permissions

## Implementation Files

The ad control system spans these files:
- `lib/core/services/ad_config_service.dart` - Remote Config integration
- `lib/core/services/ad_service.dart` - Updated ad service with permissions
- `lib/features/solve_math/presentation/solve_math_cubit.dart` - Math solving ad logic
- `lib/features/study/presentation/cubit/flashcard_generation_cubit.dart` - Flashcard ad logic
- `pubspec.yaml` - Firebase Remote Config dependency
- `lib/main.dart` - Service initialization