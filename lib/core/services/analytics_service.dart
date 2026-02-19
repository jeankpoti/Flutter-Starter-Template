import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:math_ai/core/config/posthog_config.dart';
import 'package:math_ai/core/services/posthog_service.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseAnalyticsObserver? get observer => _observer;

  /// Initialize analytics (Firebase + PostHog)
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
  }

  /// Log an event to both Firebase and PostHog
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

  /// Set user ID in both services
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

  /// Reset PostHog identity (call on logout)
  static Future<void> resetPostHogIdentity() async {
    await PostHogService.reset();
  }

  /// Flush PostHog events (call before app close if needed)
  static Future<void> flushPostHog() async {
    await PostHogService.flush();
  }
}
