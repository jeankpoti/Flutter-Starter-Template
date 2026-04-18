import 'package:tiktok_events_sdk/tiktok_events_sdk.dart';
import 'package:math_ai/core/config/tiktok_config.dart';

/// TikTok Events SDK analytics service for conversion tracking and audience building
///
/// Mirrors the same pattern as PostHogService and MetaAnalyticsService for consistency.
/// All methods silently fail if TikTok SDK is not initialized to avoid
/// interrupting app flow.
class TikTokAnalyticsService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize TikTok Events SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization if App ID is not set
    if (TikTokConfig.appId.isEmpty ||
        TikTokConfig.appId == 'YOUR_TIKTOK_APP_ID') {
      return;
    }

    try {
      await TikTokEventsSdk.initSdk(
        androidAppId: TikTokConfig.androidAppId,
        tikTokAndroidId: TikTokConfig.tikTokAndroidId,
        iosAppId: TikTokConfig.iosAppId,
        tiktokIosId: TikTokConfig.tikTokIosId,
        isDebugMode: TikTokConfig.debugMode,
      );
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
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: name,
          properties: parameters != null
              ? EventProperties(
                  value: parameters['value'] as double?,
                  contentId: parameters['content_id'] as String?,
                  quantity: parameters['quantity'] as int?,
                )
              : null,
        ),
      );
    } catch (e) {
      // Silently fail - don't interrupt app flow for analytics
    }
  }

  /// Log completed registration (TikTok standard event)
  /// Use this when a user signs up
  static Future<void> logCompleteRegistration({String? method}) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: 'CompleteRegistration',
          properties: method != null
              ? EventProperties(contentId: method)
              : null,
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log purchase event with revenue (TikTok standard event)
  /// Use this for subscription purchases
  static Future<void> logPurchase({
    required double value,
    required String currency,
    String? contentId,
  }) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: 'CompletePurchase',
          properties: EventProperties(
            value: value,
            contentId: contentId,
            currency: _getCurrencyCode(currency),
          ),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Convert currency string to CurrencyCode enum
  static CurrencyCode? _getCurrencyCode(String? currency) {
    if (currency == null) return null;
    try {
      // Try to find matching currency code
      for (final code in CurrencyCode.values) {
        if (code.name.toUpperCase() == currency.toUpperCase()) {
          return code;
        }
      }
      // Return null if no match found
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Log add to cart event (TikTok standard event)
  /// Use this when user views paywall/subscription screen
  static Future<void> logAddToCart({
    double? value,
    String? currency,
    String? contentId,
  }) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: 'AddToCart',
          properties: EventProperties(
            value: value,
            contentId: contentId,
            currency: _getCurrencyCode(currency),
          ),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log view content event (TikTok standard event)
  static Future<void> logViewContent({
    String? contentType,
    String? contentId,
  }) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: 'ViewContent',
          properties: EventProperties(
            contentId: contentId,
            contentType: contentType,
          ),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscribe event (TikTok standard event)
  static Future<void> logSubscribe({
    double? value,
    String? currency,
    String? plan,
  }) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logEvent(
        event: TikTokEvent(
          eventName: 'Subscribe',
          properties: EventProperties(
            value: value,
            currency: _getCurrencyCode(currency),
            contentId: plan,
          ),
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Identify user for cross-device tracking
  static Future<void> identify(String userId, {String? email}) async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.identify(
        identifier: TikTokIdentifier(
          externalId: userId,
          email: email ?? '',
          externalUserName: '',
          phoneNumber: '',
        ),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Clear user identity (call on logout)
  static Future<void> logout() async {
    if (!_isInitialized) return;

    try {
      await TikTokEventsSdk.logout();
    } catch (e) {
      // Silently fail
    }
  }
}
