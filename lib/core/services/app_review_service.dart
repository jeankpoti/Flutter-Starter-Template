import 'dart:io';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:math_ai/core/services/analytics_service.dart';

class AppReviewService {
  static const String _appLaunchCountKey = 'app_launch_count';
  static const String _problemsSolvedKey = 'problems_solved_count';
  static const String _quizzesCompletedKey = 'quizzes_completed_count';
  static const String _lastRequestDateKey = 'last_review_request_date';
  static const String _hasRatedAppKey = 'has_rated_app';

  // Minimum requirements before showing review prompt
  static const int _minLaunches =
      1; // Can ask on first launch if they solve a problem
  static const int _minProblemsSolved = 1; // Ask after first successful solve
  static const int _minQuizzesCompleted = 2;
  static const int _daysBetweenRequests = 60; // 2 months

  static final InAppReview _inAppReview = InAppReview.instance;

  /// Initialize app review service and increment launch count
  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final launchCount = prefs.getInt(_appLaunchCountKey) ?? 0;
    await prefs.setInt(_appLaunchCountKey, launchCount + 1);
  }

  /// Increment problems solved counter
  static Future<void> incrementProblemsSolved() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_problemsSolvedKey) ?? 0;
    await prefs.setInt(_problemsSolvedKey, count + 1);
  }

  /// Increment quizzes completed counter
  static Future<void> incrementQuizzesCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final count = prefs.getInt(_quizzesCompletedKey) ?? 0;
    await prefs.setInt(_quizzesCompletedKey, count + 1);
  }

  /// Check conditions and request review if appropriate
  static Future<void> checkAndRequestReview({
    required String triggerPoint,
    bool afterPositiveAction = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    // Don't ask if user has already rated the app
    final hasRated = prefs.getBool(_hasRatedAppKey) ?? false;
    if (hasRated) return;

    // Don't ask if already requested recently
    final lastRequestDate = prefs.getString(_lastRequestDateKey);
    if (lastRequestDate != null) {
      final daysSinceLastRequest =
          DateTime.now().difference(DateTime.parse(lastRequestDate)).inDays;
      if (daysSinceLastRequest < _daysBetweenRequests) return;
    }

    // Check if minimum conditions are met
    final launchCount = prefs.getInt(_appLaunchCountKey) ?? 0;
    final problemsSolved = prefs.getInt(_problemsSolvedKey) ?? 0;
    final quizzesCompleted = prefs.getInt(_quizzesCompletedKey) ?? 0;

    // Special case: Always ask after first problem solved
    final isFirstProblemSolved =
        triggerPoint == 'problem_solved' && problemsSolved == 1;

    final meetsBasicRequirements =
        launchCount >= _minLaunches && problemsSolved >= _minProblemsSolved;

    // For quiz completion, also check quiz counts
    final meetsQuizRequirement =
        triggerPoint == 'quiz_completion'
            ? quizzesCompleted >= _minQuizzesCompleted
            : true;

    final shouldRequest =
        afterPositiveAction &&
        (isFirstProblemSolved ||
            (meetsBasicRequirements && meetsQuizRequirement));

    if (shouldRequest) {
      // Log analytics event
      await AnalyticsService.logEvent(
        name: 'review_prompt_triggered',
        parameters: {
          'trigger_point': triggerPoint,
          'launch_count': launchCount,
          'problems_solved': problemsSolved,
          'quizzes_completed': quizzesCompleted,
        },
      );

      // Check if in-app review is available
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();
        await prefs.setString(
          _lastRequestDateKey,
          DateTime.now().toIso8601String(),
        );

        // Log that review was requested
        await AnalyticsService.logEvent(
          name: 'review_requested',
          parameters: {'method': 'in_app', 'trigger_point': triggerPoint},
        );
      }
    }
  }

  /// Mark that user has rated the app (to stop asking)
  static Future<void> markAsRated() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasRatedAppKey, true);

    await AnalyticsService.logEvent(name: 'app_rated', parameters: {});
  }

  /// Open store listing directly (fallback option)
  static Future<void> openStoreListing() async {
    const androidAppId = 'com.jeankpoti.mathai.math_ai';
    const iosAppId = '6746733499'; // Your iOS app ID

    final url =
        Platform.isAndroid
            ? 'https://play.google.com/store/apps/details?id=$androidAppId'
            : 'https://apps.apple.com/app/id$iosAppId';

    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      await AnalyticsService.logEvent(
        name: 'store_listing_opened',
        parameters: {'platform': Platform.isAndroid ? 'android' : 'ios'},
      );
    }
  }

  /// Get current review stats (for debugging)
  static Future<Map<String, dynamic>> getReviewStats() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'app_launches': prefs.getInt(_appLaunchCountKey) ?? 0,
      'problems_solved': prefs.getInt(_problemsSolvedKey) ?? 0,
      'quizzes_completed': prefs.getInt(_quizzesCompletedKey) ?? 0,
      'has_rated': prefs.getBool(_hasRatedAppKey) ?? false,
      'last_request_date': prefs.getString(_lastRequestDateKey),
    };
  }
}
