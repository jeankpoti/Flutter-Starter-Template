import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:math_ai/core/config/posthog_config.dart';
import 'package:math_ai/core/services/meta_analytics_service.dart';
import 'package:math_ai/core/services/posthog_service.dart';
import 'package:math_ai/core/services/tenjin_analytics_service.dart';
import 'package:math_ai/core/services/tiktok_analytics_service.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize analytics (Firebase + PostHog + Meta + TikTok + Tenjin)
  static Future<void> initialize() async {
    // Initialize Firebase Analytics
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    await _analytics!.setAnalyticsCollectionEnabled(true);

    // Initialize PostHog Analytics
    await PostHogService.initialize(
      apiKey: PostHogConfig.apiKey,
      host: PostHogConfig.host,
    );

    // Initialize Meta Analytics
    await MetaAnalyticsService.initialize();

    // Initialize TikTok Analytics
    await TikTokAnalyticsService.initialize();

    // Initialize Tenjin Analytics
    await TenjinAnalyticsService.initialize();
  }

  /// Request App Tracking Transparency authorization (iOS 14+)
  /// Call this after app launch to enable ad attribution tracking
  static Future<TrackingStatus> requestTrackingAuthorization() async {
    // Only request on iOS
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    }

    try {
      // Check and request tracking authorization
      final status =
          await AppTrackingTransparency.requestTrackingAuthorization();

      // Log the authorization status for analytics
      await logEvent(
        name: 'tracking_authorization_status',
        parameters: {'status': status.name},
      );

      return status;
    } catch (e) {
      return TrackingStatus.notDetermined;
    }
  }

  /// Get current tracking authorization status without prompting
  static Future<TrackingStatus> getTrackingStatus() async {
    if (!Platform.isIOS) {
      return TrackingStatus.notSupported;
    }
    return await AppTrackingTransparency.trackingAuthorizationStatus;
  }

  /// Log an event to Firebase, PostHog, and Meta
  static Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    // Firebase Analytics
    if (_analytics != null) {
      final Map<String, Object>? filteredParameters = parameters != null
          ? Map.fromEntries(
              parameters.entries
                  .where((entry) => entry.value != null)
                  .map((entry) => MapEntry(entry.key, entry.value!)),
            )
          : null;

      await _analytics!.logEvent(
        name: name,
        parameters: filteredParameters,
      );
    }

    // PostHog Analytics
    await PostHogService.capture(name: name, properties: parameters);

    // Meta Analytics
    final Map<String, dynamic>? metaParameters = parameters?.map(
      (key, value) => MapEntry(key, value),
    );
    await MetaAnalyticsService.logEvent(name: name, parameters: metaParameters);

    // TikTok Analytics
    await TikTokAnalyticsService.logEvent(name: name, parameters: metaParameters);
  }

  /// Log screen view to both services
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    // Firebase Analytics
    if (_analytics != null) {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    }

    // PostHog Analytics
    await PostHogService.screen(
      screenName: screenName,
      properties: screenClass != null ? {'screen_class': screenClass} : null,
    );
  }

  /// Set user ID in all services
  static Future<void> setUserId(String? userId) async {
    // Firebase Analytics
    if (_analytics != null) {
      await _analytics!.setUserId(id: userId);
    }

    // PostHog Analytics
    if (userId != null) {
      await PostHogService.identify(userId);
    } else {
      await PostHogService.reset();
    }

    // Meta Analytics
    if (userId != null) {
      await MetaAnalyticsService.setUserId(userId);
    } else {
      await MetaAnalyticsService.clearUserId();
    }

    // TikTok Analytics
    if (userId != null) {
      await TikTokAnalyticsService.identify(userId);
    } else {
      await TikTokAnalyticsService.logout();
    }
  }

  /// Set user property in both services
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    // Firebase Analytics
    if (_analytics != null) {
      await _analytics!.setUserProperty(
        name: name,
        value: value,
      );
    }

    // PostHog Analytics
    if (value != null) {
      await PostHogService.setUserProperties({name: value});
    }
  }

  /// Common events
  static Future<void> logSignUp({required String method}) async {
    await logEvent(
      name: 'sign_up',
      parameters: {'method': method},
    );

    // Meta standard event for registration
    await MetaAnalyticsService.logCompletedRegistration(method: method);

    // TikTok standard event for registration
    await TikTokAnalyticsService.logCompleteRegistration(method: method);

    // Tenjin standard event for registration
    await TenjinAnalyticsService.logCompleteRegistration(method: method);
  }

  static Future<void> logLogin({required String method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );

    // Tenjin login event
    await TenjinAnalyticsService.logLogin(method: method);
  }

  static Future<void> logMathProblemSolved({
    required String method,
    bool? savedToCollection,
  }) async {
    await logEvent(
      name: 'math_problem_solved',
      parameters: {
        'method': method, // 'camera' or 'text'
        if (savedToCollection != null) 'saved_to_collection': savedToCollection,
      },
    );
  }

  static Future<void> logStudyMaterialUploaded({
    required String type,
    required int topicCount,
  }) async {
    await logEvent(
      name: 'study_material_uploaded',
      parameters: {
        'type': type, // 'pdf' or 'image'
        'topic_count': topicCount,
      },
    );
  }

  static Future<void> logQuizCompleted({
    required String studyPlanId,
    required double score,
    required int questionCount,
  }) async {
    await logEvent(
      name: 'quiz_completed',
      parameters: {
        'study_plan_id': studyPlanId,
        'score': score,
        'question_count': questionCount,
      },
    );
  }

  static Future<void> logSubscriptionStarted({
    required String plan,
    required String source,
  }) async {
    await logEvent(
      name: 'subscription_started',
      parameters: {
        'plan': plan,
        'source': source,
      },
    );
  }

  static Future<void> logPurchaseCompleted({
    required String productName,
    required double amount,
    required String currency,
  }) async {
    await logEvent(
      name: 'purchase_completed',
      parameters: {
        'product_name': productName,
        'amount': amount,
        'currency': currency,
      },
    );

    // Meta standard event for purchase (revenue tracking)
    await MetaAnalyticsService.logPurchase(
      amount: amount,
      currency: currency,
      parameters: {'product_name': productName},
    );
  }

  /// Log purchase using Google's standard event (for Google Ads conversion tracking)
  /// Use this for subscription purchases to enable revenue attribution
  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    String? itemName,
    String? itemCategory,
  }) async {
    // Firebase standard purchase event (recognized by Google Ads)
    if (_analytics != null) {
      await _analytics!.logPurchase(
        transactionId: transactionId,
        value: value,
        currency: currency,
        items: itemName != null
            ? [
                AnalyticsEventItem(
                  itemName: itemName,
                  itemCategory: itemCategory,
                  price: value,
                  quantity: 1,
                ),
              ]
            : null,
      );
    }

    // PostHog
    await PostHogService.capture(
      name: 'purchase',
      properties: {
        'transaction_id': transactionId,
        'value': value,
        'currency': currency,
        if (itemName != null) 'item_name': itemName,
      },
    );

    // Meta
    await MetaAnalyticsService.logPurchase(
      amount: value,
      currency: currency,
      parameters: {
        'transaction_id': transactionId,
        if (itemName != null) 'item_name': itemName,
      },
    );

    // TikTok
    await TikTokAnalyticsService.logPurchase(
      value: value,
      currency: currency,
      contentId: itemName,
    );

    // Tenjin
    await TenjinAnalyticsService.logPurchase(
      value: value,
      currency: currency,
      productId: itemName,
    );
  }

  /// Log begin checkout using Google's standard event (for Google Ads funnel tracking)
  /// Call this when user views the paywall/subscription screen
  static Future<void> logBeginCheckout({
    required double value,
    required String currency,
    String? itemName,
  }) async {
    // Firebase standard begin_checkout event
    if (_analytics != null) {
      await _analytics!.logBeginCheckout(
        value: value,
        currency: currency,
        items: itemName != null
            ? [
                AnalyticsEventItem(
                  itemName: itemName,
                  price: value,
                  quantity: 1,
                ),
              ]
            : null,
      );
    }

    // PostHog
    await PostHogService.capture(
      name: 'begin_checkout',
      properties: {
        'value': value,
        'currency': currency,
        if (itemName != null) 'item_name': itemName,
      },
    );

    // Meta
    await MetaAnalyticsService.logInitiatedCheckout(
      totalPrice: value,
      currency: currency,
      contentId: itemName,
    );

    // TikTok (AddToCart = checkout intent)
    await TikTokAnalyticsService.logAddToCart(
      value: value,
      currency: currency,
      contentId: itemName,
    );

    // Tenjin
    await TenjinAnalyticsService.logBeginCheckout(
      value: value,
      currency: currency,
    );
  }

  /// Log app open event (for Google Ads engagement tracking)
  static Future<void> logAppOpen() async {
    if (_analytics != null) {
      await _analytics!.logAppOpen();
    }

    await PostHogService.capture(name: 'app_open');
    await MetaAnalyticsService.logEvent(name: 'app_open');
    await TenjinAnalyticsService.logAppOpen();
  }

  /// Log subscription cancellation or refund request
  static Future<void> logSubscriptionCancellation({
    String? productId,
    String? refundStatus,
  }) async {
    await logEvent(
      name: 'subscription_cancellation',
      parameters: {
        if (productId != null) 'product_id': productId,
        if (refundStatus != null) 'refund_status': refundStatus,
      },
    );
    await TenjinAnalyticsService.logSubscriptionCancel(productId: productId);
  }

  /// Log cancellation survey response (why user is cancelling)
  static Future<void> logCancellationReason({
    required String reason,
  }) async {
    await logEvent(
      name: 'cancellation_reason',
      parameters: {'reason': reason},
    );
  }

  /// Log when user accepts a win-back offer
  static Future<void> logWinbackOfferAccepted({
    required String offerId,
    String? productId,
  }) async {
    await logEvent(
      name: 'winback_offer_accepted',
      parameters: {
        'offer_id': offerId,
        if (productId != null) 'product_id': productId,
      },
    );
  }

  /// Log Customer Center opened (for tracking engagement with subscription management)
  static Future<void> logCustomerCenterOpened() async {
    await logEvent(name: 'customer_center_opened');
  }

  /// Log paywall/subscription screen viewed (for audience building)
  /// Use this to create retargeting audiences of users who saw but didn't convert
  static Future<void> logPaywallViewed({
    required String source,
    double? price,
    String? currency,
  }) async {
    await logEvent(
      name: 'paywall_viewed',
      parameters: {
        'source': source,
        if (price != null) 'price': price,
        if (currency != null) 'currency': currency,
      },
    );

    // Meta standard event for initiated checkout (paywall = checkout intent)
    await MetaAnalyticsService.logInitiatedCheckout(
      totalPrice: price,
      currency: currency,
      contentId: source,
    );

    // TikTok standard event (AddToCart for paywall = checkout intent)
    await TikTokAnalyticsService.logAddToCart(
      value: price,
      currency: currency,
      contentId: source,
    );

    // Tenjin
    await TenjinAnalyticsService.logPaywallViewed(source: source);
  }

  /// Log content view (for audience segmentation)
  static Future<void> logContentViewed({
    required String contentType,
    String? contentId,
  }) async {
    await logEvent(
      name: 'content_viewed',
      parameters: {
        'content_type': contentType,
        if (contentId != null) 'content_id': contentId,
      },
    );

    // Meta standard event
    await MetaAnalyticsService.logViewContent(
      contentType: contentType,
      contentId: contentId,
    );

    // TikTok standard event
    await TikTokAnalyticsService.logViewContent(
      contentType: contentType,
      contentId: contentId,
    );
  }

  /// Reset all analytics identity (call on logout)
  static Future<void> resetIdentity() async {
    await PostHogService.reset();
    await MetaAnalyticsService.clearUserId();
    await MetaAnalyticsService.clearUserData();
    await TikTokAnalyticsService.logout();
  }

  /// Flush all analytics events (call before app close if needed)
  static Future<void> flushAll() async {
    await PostHogService.flush();
    await MetaAnalyticsService.flush();
  }

  /// Reset PostHog identity (call on logout)
  @Deprecated('Use resetIdentity() instead')
  static Future<void> resetPostHogIdentity() async {
    await PostHogService.reset();
  }

  /// Flush PostHog events (call before app close if needed)
  @Deprecated('Use flushAll() instead')
  static Future<void> flushPostHog() async {
    await PostHogService.flush();
  }

  // ============================================================
  // Google Ads Conversion Tracking Events
  // ============================================================

  /// Log app_first_launch event for new user acquisition tracking
  /// This should be called ONCE per device installation
  /// Note: Firebase automatically tracks 'first_open' - we use 'app_first_launch' for custom tracking
  /// Google Ads can import Firebase's automatic first_open event
  static Future<void> logFirstOpen() async {
    // Firebase automatically tracks 'first_open' - no manual logging needed
    // We log a custom event for our own tracking purposes
    if (_analytics != null) {
      await _analytics!.logEvent(
        name: 'app_first_launch',
        parameters: {'engagement_time_msec': 1},
      );
    }

    await PostHogService.capture(name: 'app_first_launch');
    await MetaAnalyticsService.logEvent(name: 'fb_first_open');
    await TikTokAnalyticsService.logEvent(name: 'first_open');
    await TenjinAnalyticsService.logFirstOpen();
  }

  /// Log in_app_purchase event (Google Ads standard event for subscriptions)
  /// This complements the purchase event with subscription-specific data
  static Future<void> logInAppPurchase({
    required String productId,
    required double price,
    required String currency,
    required String subscriptionPeriod,
    String? transactionId,
    bool? isTrialConversion,
    bool? isFirstPurchase,
  }) async {
    final parameters = <String, Object>{
      'product_id': productId,
      'price': price,
      'currency': currency,
      'subscription_period': subscriptionPeriod,
      'quantity': 1,
      if (transactionId != null) 'transaction_id': transactionId,
      if (isTrialConversion != null) 'is_trial_conversion': isTrialConversion,
      if (isFirstPurchase != null) 'is_first_purchase': isFirstPurchase,
    };

    if (_analytics != null) {
      await _analytics!.logEvent(
        name: 'in_app_purchase',
        parameters: parameters,
      );
    }

    await PostHogService.capture(name: 'in_app_purchase', properties: parameters);
  }

  /// Log when user starts a free trial
  /// Critical for Google Ads to optimize for high-intent users
  static Future<void> logTrialStart({
    required String productId,
    required int trialDurationDays,
    String? source,
  }) async {
    final parameters = <String, Object>{
      'product_id': productId,
      'trial_duration_days': trialDurationDays,
      if (source != null) 'source': source,
    };

    if (_analytics != null) {
      await _analytics!.logEvent(
        name: 'start_trial',
        parameters: parameters,
      );
    }

    await PostHogService.capture(name: 'start_trial', properties: parameters);
    await MetaAnalyticsService.logEvent(
      name: 'StartTrial',
      parameters: parameters.cast<String, dynamic>(),
    );
    await TikTokAnalyticsService.logEvent(
      name: 'StartTrial',
      parameters: parameters.cast<String, dynamic>(),
    );
    await TenjinAnalyticsService.logTrialStart(productId: productId);
  }

  /// Log when user converts from trial to paid subscription
  static Future<void> logTrialConversion({
    required String productId,
    required double value,
    required String currency,
    String? transactionId,
  }) async {
    final parameters = <String, Object>{
      'product_id': productId,
      'value': value,
      'currency': currency,
      if (transactionId != null) 'transaction_id': transactionId,
    };

    if (_analytics != null) {
      await _analytics!.logEvent(
        name: 'trial_conversion',
        parameters: parameters,
      );
    }

    await PostHogService.capture(name: 'trial_conversion', properties: parameters);
    await TenjinAnalyticsService.logTrialConversion(
      value: value,
      currency: currency,
    );
  }

  /// Set user properties for Google Ads audience building
  /// Call after user signs up or subscription status changes
  static Future<void> setSubscriptionUserProperties({
    required bool isSubscribed,
    String? subscriptionType,
    bool? isInTrial,
  }) async {
    if (_analytics != null) {
      await _analytics!.setUserProperty(
        name: 'subscription_status',
        value: isSubscribed ? 'subscribed' : 'free',
      );

      if (subscriptionType != null) {
        await _analytics!.setUserProperty(
          name: 'subscription_type',
          value: subscriptionType,
        );
      }

      if (isInTrial != null) {
        await _analytics!.setUserProperty(
          name: 'is_trial_user',
          value: isInTrial.toString(),
        );
      }
    }

    // PostHog
    final properties = <String, Object>{
      'subscription_status': isSubscribed ? 'subscribed' : 'free',
      if (subscriptionType != null) 'subscription_type': subscriptionType,
      if (isInTrial != null) 'is_trial_user': isInTrial,
    };
    await PostHogService.setUserProperties(properties);
  }

  /// Log subscription renewal event
  /// Important for LTV calculation and Google Ads optimization
  static Future<void> logSubscriptionRenewal({
    required String productId,
    required double value,
    required String currency,
    required int renewalCount,
  }) async {
    final parameters = <String, Object>{
      'product_id': productId,
      'value': value,
      'currency': currency,
      'renewal_count': renewalCount,
    };

    if (_analytics != null) {
      await _analytics!.logEvent(
        name: 'subscription_renewal',
        parameters: parameters,
      );
    }

    await PostHogService.capture(name: 'subscription_renewal', properties: parameters);
    await TenjinAnalyticsService.logSubscriptionRenewal(
      value: value,
      productId: productId,
    );
  }

  // ==========================================================================
  // ADDITIONAL SUBSCRIPTION LIFECYCLE EVENTS
  // ==========================================================================

  /// Log subscription product change
  static Future<void> logSubscriptionChange({
    String? fromProductId,
    String? toProductId,
  }) async {
    await logEvent(
      name: 'subscription_change',
      parameters: {
        if (fromProductId != null) 'from_product_id': fromProductId,
        if (toProductId != null) 'to_product_id': toProductId,
      },
    );
    await TenjinAnalyticsService.logSubscriptionChange(
      fromProduct: fromProductId,
      toProduct: toProductId,
    );
  }

  /// Log billing issue
  static Future<void> logBillingIssue({String? productId}) async {
    await logEvent(
      name: 'billing_issue',
      parameters: {if (productId != null) 'product_id': productId},
    );
    await TenjinAnalyticsService.logBillingIssue(productId: productId);
  }

  /// Log subscription reactivation (uncancellation)
  static Future<void> logSubscriptionReactivate({String? productId}) async {
    await logEvent(
      name: 'subscription_reactivate',
      parameters: {if (productId != null) 'product_id': productId},
    );
    await TenjinAnalyticsService.logSubscriptionReactivate(productId: productId);
  }

  /// Log subscription pause
  static Future<void> logSubscriptionPause({String? productId}) async {
    await logEvent(
      name: 'subscription_pause',
      parameters: {if (productId != null) 'product_id': productId},
    );
    await TenjinAnalyticsService.logSubscriptionPause(productId: productId);
  }

  /// Log subscription expiration
  static Future<void> logSubscriptionExpire({String? productId}) async {
    await logEvent(
      name: 'subscription_expire',
      parameters: {if (productId != null) 'product_id': productId},
    );
    await TenjinAnalyticsService.logSubscriptionExpire(productId: productId);
  }

  /// Log subscription extension
  static Future<void> logSubscriptionExtend({String? productId}) async {
    await logEvent(
      name: 'subscription_extend',
      parameters: {if (productId != null) 'product_id': productId},
    );
    await TenjinAnalyticsService.logSubscriptionExtend(productId: productId);
  }

  /// Log refund
  static Future<void> logRefund({double? value, String? productId}) async {
    await logEvent(
      name: 'refund',
      parameters: {
        if (value != null) 'value': value,
        if (productId != null) 'product_id': productId,
      },
    );
    await TenjinAnalyticsService.logRefund(value: value, productId: productId);
  }

  /// Log one-time (non-renewing) purchase
  static Future<void> logOneTimePurchase({
    required double value,
    required String currency,
    String? productId,
  }) async {
    await logEvent(
      name: 'one_time_purchase',
      parameters: {
        'value': value,
        'currency': currency,
        if (productId != null) 'product_id': productId,
      },
    );
    await TenjinAnalyticsService.logOneTimePurchase(
      value: value,
      productId: productId,
    );
  }
}
