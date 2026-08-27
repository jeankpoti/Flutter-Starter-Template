import 'package:tenjin_plugin/tenjin_sdk.dart';
import 'package:math_ai/core/config/tenjin_config.dart';

/// Tenjin SDK analytics service for mobile attribution and conversion tracking
///
/// Mirrors the same pattern as TikTokAnalyticsService and MetaAnalyticsService.
/// All methods silently fail if Tenjin SDK is not initialized to avoid
/// interrupting app flow.
class TenjinAnalyticsService {
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize Tenjin SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Skip initialization if SDK key is not set
    if (TenjinConfig.sdkKey.isEmpty ||
        TenjinConfig.sdkKey == 'YOUR_TENJIN_SDK_KEY') {
      return;
    }

    try {
      TenjinSDK.instance.initialize(sdkKey: TenjinConfig.sdkKey);
      TenjinSDK.instance.connect();
      _isInitialized = true;
    } catch (e) {
      // Log error but don't crash - analytics should be non-blocking
      _isInitialized = false;
    }
  }

  /// Log a custom event with name only
  static Future<void> logEvent(String eventName) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName(eventName);
    } catch (e) {
      // Silently fail - don't interrupt app flow for analytics
    }
  }

  /// Log a custom event with name and integer value
  static Future<void> logEventWithValue(String eventName, int value) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithNameAndValue(eventName, value);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log completed registration
  /// Use this when a user signs up
  static Future<void> logCompleteRegistration({String? method}) async {
    if (!_isInitialized) return;

    try {
      final eventName = method != null ? 'registration_$method' : 'registration';
      TenjinSDK.instance.eventWithName(eventName);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log purchase event with revenue
  /// Use this for subscription purchases
  static Future<void> logPurchase({
    required double value,
    required String currency,
    String? productId,
  }) async {
    if (!_isInitialized) return;

    try {
      // Convert value to cents for integer representation
      final valueInCents = (value * 100).round();
      final eventName = productId != null ? 'purchase_$productId' : 'purchase';
      TenjinSDK.instance.eventWithNameAndValue(eventName, valueInCents);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription started event
  static Future<void> logSubscribe({
    double? value,
    String? currency,
    String? plan,
  }) async {
    if (!_isInitialized) return;

    try {
      if (value != null) {
        final valueInCents = (value * 100).round();
        TenjinSDK.instance.eventWithNameAndValue('subscribe', valueInCents);
      } else {
        TenjinSDK.instance.eventWithName('subscribe');
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Log trial started event
  static Future<void> logTrialStart({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('trial_start');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log trial conversion event
  static Future<void> logTrialConversion({
    double? value,
    String? currency,
  }) async {
    if (!_isInitialized) return;

    try {
      if (value != null) {
        final valueInCents = (value * 100).round();
        TenjinSDK.instance
            .eventWithNameAndValue('trial_conversion', valueInCents);
      } else {
        TenjinSDK.instance.eventWithName('trial_conversion');
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Log paywall viewed event
  static Future<void> logPaywallViewed({String? source}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('paywall_view');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log checkout initiated event
  static Future<void> logBeginCheckout({
    double? value,
    String? currency,
  }) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('begin_checkout');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log login event
  static Future<void> logLogin({String? method}) async {
    if (!_isInitialized) return;

    try {
      final eventName = method != null ? 'login_$method' : 'login';
      TenjinSDK.instance.eventWithName(eventName);
    } catch (e) {
      // Silently fail
    }
  }

  /// Log app open event
  static Future<void> logAppOpen() async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('app_open');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log first open event (for new installs)
  static Future<void> logFirstOpen() async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('first_open');
    } catch (e) {
      // Silently fail
    }
  }

  /// Request GDPR opt-in (for GDPR compliant regions)
  static Future<void> optIn() async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.optIn();
    } catch (e) {
      // Silently fail
    }
  }

  /// Request GDPR opt-out
  static Future<void> optOut() async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.optOut();
    } catch (e) {
      // Silently fail
    }
  }

  /// Opt in to ad tracking parameters
  static Future<void> optInParams(List<String> params) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.optInParams(params);
    } catch (e) {
      // Silently fail
    }
  }

  /// Opt out of ad tracking parameters
  static Future<void> optOutParams(List<String> params) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.optOutParams(params);
    } catch (e) {
      // Silently fail
    }
  }

  // ==========================================================================
  // SUBSCRIPTION LIFECYCLE EVENTS
  // ==========================================================================

  /// Log subscription renewal event
  static Future<void> logSubscriptionRenewal({
    double? value,
    String? productId,
  }) async {
    if (!_isInitialized) return;

    try {
      if (value != null) {
        final valueInCents = (value * 100).round();
        TenjinSDK.instance
            .eventWithNameAndValue('subscription_renewal', valueInCents);
      } else {
        TenjinSDK.instance.eventWithName('subscription_renewal');
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription cancellation event
  static Future<void> logSubscriptionCancel({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_cancel');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription product change event
  static Future<void> logSubscriptionChange({
    String? fromProduct,
    String? toProduct,
  }) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_change');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log billing issue event
  static Future<void> logBillingIssue({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('billing_issue');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription reactivation (uncancellation) event
  static Future<void> logSubscriptionReactivate({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_reactivate');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription pause event
  static Future<void> logSubscriptionPause({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_pause');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription expiration event
  static Future<void> logSubscriptionExpire({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_expire');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log subscription extension event
  static Future<void> logSubscriptionExtend({String? productId}) async {
    if (!_isInitialized) return;

    try {
      TenjinSDK.instance.eventWithName('subscription_extend');
    } catch (e) {
      // Silently fail
    }
  }

  /// Log refund event
  static Future<void> logRefund({double? value, String? productId}) async {
    if (!_isInitialized) return;

    try {
      if (value != null) {
        final valueInCents = (value * 100).round();
        TenjinSDK.instance.eventWithNameAndValue('refund', valueInCents);
      } else {
        TenjinSDK.instance.eventWithName('refund');
      }
    } catch (e) {
      // Silently fail
    }
  }

  /// Log one-time (non-renewing) purchase event
  static Future<void> logOneTimePurchase({
    double? value,
    String? productId,
  }) async {
    if (!_isInitialized) return;

    try {
      if (value != null) {
        final valueInCents = (value * 100).round();
        TenjinSDK.instance
            .eventWithNameAndValue('one_time_purchase', valueInCents);
      } else {
        TenjinSDK.instance.eventWithName('one_time_purchase');
      }
    } catch (e) {
      // Silently fail
    }
  }
}
