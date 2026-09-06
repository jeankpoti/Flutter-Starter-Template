import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter_starter/core/config/meta_config.dart';

/// Meta (Facebook) analytics service for conversion tracking and audience building
///
/// Mirrors the same pattern as PostHogService for consistency.
/// All methods silently fail if Meta SDK is not initialized to avoid
/// interrupting app flow.
class MetaAnalyticsService {
  static final FacebookAppEvents _fb = FacebookAppEvents();
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize Meta analytics
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization if App ID is not set
    if (MetaConfig.appId.isEmpty ||
        MetaConfig.appId == 'YOUR_FACEBOOK_APP_ID') {
      return;
    }

    try {
      // Enable automatic app event logging
      await _fb.setAutoLogAppEventsEnabled(true);

      // Enable advertiser tracking (required for iOS 14+ attribution)
      await _fb.setAdvertiserTracking(enabled: true);

      _isInitialized = true;
    } catch (e) {
      // Log error but don't crash - analytics should be non-blocking
      _isInitialized = false;
    }
  }

  /// Log a custom event with optional parameters
  static Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _fb.logEvent(name: name, parameters: parameters);
    } catch (e) {
      // Silently fail - don't interrupt app flow for analytics
    }
  }

  /// Log completed registration (standard Meta event)
  /// Use this when a user signs up
  static Future<void> logCompletedRegistration({String? method}) async {
    if (!_isInitialized) return;

    try {
      await _fb.logCompletedRegistration(registrationMethod: method);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log purchase event with revenue (standard Meta event)
  /// Use this for subscription purchases
  static Future<void> logPurchase({
    required double amount,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isInitialized) return;

    try {
      await _fb.logPurchase(
        amount: amount,
        currency: currency,
        parameters: parameters,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log tutorial completion (custom event)
  static Future<void> logCompleteTutorial({String? contentId}) async {
    if (!_isInitialized) return;

    try {
      await _fb.logEvent(
        name: 'fb_mobile_tutorial_completion',
        parameters: contentId != null ? {'content_id': contentId} : null,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log achievement unlocked (custom event)
  static Future<void> logAchievementUnlocked({String? description}) async {
    if (!_isInitialized) return;

    try {
      await _fb.logEvent(
        name: 'fb_mobile_achievement_unlocked',
        parameters: description != null ? {'description': description} : null,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log initiated checkout (standard Meta event)
  /// Use when user views subscription/paywall
  static Future<void> logInitiatedCheckout({
    double? totalPrice,
    String? currency,
    String? contentId,
    int? numItems,
  }) async {
    if (!_isInitialized) return;

    try {
      await _fb.logInitiatedCheckout(
        totalPrice: totalPrice,
        currency: currency,
        contentId: contentId,
        numItems: numItems,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log content view (custom event)
  static Future<void> logViewContent({
    String? contentType,
    String? contentId,
    String? currency,
    double? price,
  }) async {
    if (!_isInitialized) return;

    try {
      final Map<String, dynamic> params = {};
      if (contentType != null) params['content_type'] = contentType;
      if (contentId != null) params['content_id'] = contentId;
      if (currency != null) params['currency'] = currency;
      if (price != null) params['price'] = price;

      await _fb.logEvent(
        name: 'fb_mobile_content_view',
        parameters: params.isNotEmpty ? params : null,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Set user ID for cross-device tracking
  static Future<void> setUserId(String? userId) async {
    if (!_isInitialized) return;
    if (userId == null) return;

    try {
      await _fb.setUserID(userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear user ID (call on logout)
  static Future<void> clearUserId() async {
    if (!_isInitialized) return;

    try {
      await _fb.clearUserID();
    } catch (e) {
      // Silently fail
    }
  }

  /// Set user data for advanced matching
  static Future<void> setUserData({
    String? email,
    String? firstName,
    String? lastName,
  }) async {
    if (!_isInitialized) return;

    try {
      await _fb.setUserData(
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear user data (call on logout)
  static Future<void> clearUserData() async {
    if (!_isInitialized) return;

    try {
      await _fb.clearUserData();
    } catch (e) {
      // Silently fail
    }
  }

  /// Flush events to Meta (useful before app close)
  static Future<void> flush() async {
    if (!_isInitialized) return;

    try {
      await _fb.flush();
    } catch (e) {
      // Silently fail
    }
  }
}
