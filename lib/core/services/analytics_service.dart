import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static FirebaseAnalyticsObserver? _observer;
  
  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseAnalyticsObserver? get observer => _observer;
  
  /// Initialize analytics without tracking permission
  static Future<void> initialize() async {
    _analytics = FirebaseAnalytics.instance;
    _observer = FirebaseAnalyticsObserver(analytics: _analytics!);
    
    // Enable analytics collection
    await _analytics!.setAnalyticsCollectionEnabled(true);
  }
  
  /// Log an event (only if analytics is enabled)
  static Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (_analytics != null) {
      // Filter out null values to match Firebase Analytics requirements
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
  }
  
  /// Log screen view
  static Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (_analytics != null) {
      await _analytics!.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );
    }
  }
  
  /// Set user ID (only if analytics is enabled)
  static Future<void> setUserId(String? userId) async {
    if (_analytics != null) {
      await _analytics!.setUserId(id: userId);
    }
  }
  
  /// Set user property
  static Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (_analytics != null) {
      await _analytics!.setUserProperty(
        name: name,
        value: value,
      );
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
}