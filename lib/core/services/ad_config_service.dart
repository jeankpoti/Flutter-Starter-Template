import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Service for managing ad configuration through Firebase Remote Config
/// Provides flexible control over ad display for testing and production environments
class AdConfigService {
  static FirebaseRemoteConfig get _remoteConfig =>
      FirebaseRemoteConfig.instance;
  static bool _isInitialized = false;

  // Remote Config keys
  static const String _adsEnabledKey = 'ads_enabled_for_testing';
  static const String _testUserEmailsKey = 'test_user_emails';
  static const String _forceTestAdsKey = 'force_test_ads';
  static const String _adsCompletelyDisabledKey = 'ads_completely_disabled';
  static const String _mathAiModelNameKey = 'math_ai_model_name';
  static const String _studyAiModelNameKey = 'study_ai_model_name';
  static const String _minRequiredVersionKey = 'min_required_version';
  static const String _forceUpdateEnabledKey = 'force_update_enabled';

  /// Initialize Remote Config with default values and settings
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Remote Config settings
      await _remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 1),
          minimumFetchInterval: const Duration(hours: 1), // Production setting
        ),
      );

      // Set default values for fallback scenarios
      await _remoteConfig.setDefaults(_getDefaultValues());

      // Fetch and activate latest config
      await _remoteConfig.fetchAndActivate();
      _isInitialized = true;
    } catch (e) {
      // Continue with defaults if Remote Config fails
      _isInitialized = true;
    }
  }

  /// Get default configuration values
  static Map<String, dynamic> _getDefaultValues() {
    return {
      _adsEnabledKey: false, // Safe default - no ads
      _testUserEmailsKey: '[]', // Empty test user list
      _forceTestAdsKey: true, // Use test ads by default
      _adsCompletelyDisabledKey: false, // Allow ads in general
      _mathAiModelNameKey: 'gemini-2.5-flash-lite',
      _studyAiModelNameKey: 'gemini-2.5-flash-lite',
      _minRequiredVersionKey: '1.0.0+7',
      _forceUpdateEnabledKey: false,
    };
  }

  /// Check if ads should be shown for the current user
  static bool shouldShowAds([String? userEmail]) {
    try {
      // If ads are completely disabled, return false
      if (_remoteConfig.getBool(_adsCompletelyDisabledKey)) {
        return false;
      }

      // Get user email from auth if not provided
      final email = userEmail ?? FirebaseAuth.instance.currentUser?.email ?? '';
      if (email.isEmpty) return false;

      // Check if ads are enabled for testing
      final adsEnabled = _remoteConfig.getBool(_adsEnabledKey);
      if (!adsEnabled) return false;

      // Check if user is in test email list
      final testEmailsJson = _remoteConfig.getString(_testUserEmailsKey);
      final testEmails = List<String>.from(jsonDecode(testEmailsJson));

      // Check if "*" is in the list (means all users)
      if (testEmails.contains("*")) {
        return true;
      }

      return testEmails.contains(email);
    } catch (e) {
      // Safe fallback - don't show ads if config fails
      return false;
    }
  }

  /// Determine if test ad units should be used
  static bool shouldUseTestAds() {
    try {
      return _remoteConfig.getBool(_forceTestAdsKey);
    } catch (e) {
      return true; // Default to test ads for safety
    }
  }

  /// Check if ads are completely disabled
  static bool areAdsCompletelyDisabled() {
    try {
      return _remoteConfig.getBool(_adsCompletelyDisabledKey);
    } catch (e) {
      return false;
    }
  }

  /// Get list of test user emails (for admin purposes)
  static List<String> getTestUserEmails() {
    try {
      final testEmailsJson = _remoteConfig.getString(_testUserEmailsKey);
      return List<String>.from(jsonDecode(testEmailsJson));
    } catch (e) {
      return [];
    }
  }

  /// Check if current user is a test user
  static bool isCurrentUserTestUser() {
    final userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    return getTestUserEmails().contains(userEmail);
  }

  /// Get configuration status for debugging
  static Map<String, dynamic> getConfigStatus() {
    return {
      'isInitialized': _isInitialized,
      'adsEnabled': _remoteConfig.getBool(_adsEnabledKey),
      'testUserEmails': getTestUserEmails(),
      'forceTestAds': shouldUseTestAds(),
      'adsCompletelyDisabled': areAdsCompletelyDisabled(),
      'currentUserEmail': FirebaseAuth.instance.currentUser?.email,
      'currentUserIsTestUser': isCurrentUserTestUser(),
      'shouldShowAdsForCurrentUser': shouldShowAds(),
    };
  }

  /// Force refresh configuration (useful for testing)
  static Future<void> refreshConfig() async {
    try {
      await _remoteConfig.fetch();
      await _remoteConfig.activate();
    } catch (e) {
      // Ignore errors - continue with cached config
    }
  }

  /// Get the AI model name for math solving
  static String getMathModelName() {
    try {
      return _remoteConfig.getString(_mathAiModelNameKey);
    } catch (e) {
      return 'gemini-2.5-flash-lite';
    }
  }

  /// Get the AI model name for study features (quizzes, plans, etc)
  static String getStudyModelName() {
    try {
      return _remoteConfig.getString(_studyAiModelNameKey);
    } catch (e) {
      return 'gemini-2.5-flash-lite';
    }
  }

  /// Get the minimum required version of the app
  static String getMinRequiredVersion() {
    try {
      return _remoteConfig.getString(_minRequiredVersionKey);
    } catch (e) {
      return '1.0.0+7';
    }
  }

  /// Check if force update is enabled
  static bool isForceUpdateEnabled() {
    try {
      return _remoteConfig.getBool(_forceUpdateEnabledKey);
    } catch (e) {
      return false;
    }
  }
}
