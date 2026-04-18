import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:math_ai/core/config/posthog_config.dart';
import 'package:math_ai/core/services/meta_analytics_service.dart';
import 'package:math_ai/core/services/posthog_service.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize analytics (Firebase + PostHog + Meta)
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
  }

  static Future<void> logLogin({required String method}) async {
    await logEvent(
      name: 'login',
      parameters: {'method': method},
    );
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
  }

  /// Reset all analytics identity (call on logout)
  static Future<void> resetIdentity() async {
    await PostHogService.reset();
    await MetaAnalyticsService.clearUserId();
    await MetaAnalyticsService.clearUserData();
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
}
