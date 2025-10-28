import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:math_ai/core/services/analytics_service.dart';
import 'package:math_ai/l10n/app_localizations.dart';
import 'package:math_ai/common_widgets/text_widgets.dart';

class AppReviewService {
  static const String _appLaunchCountKey = 'app_launch_count';
  static const String _problemsSolvedKey = 'problems_solved_count';
  static const String _quizzesCompletedKey = 'quizzes_completed_count';
  static const String _lastRequestDateKey = 'last_review_request_date';
  static const String _hasRatedAppKey = 'has_rated_app';

  // Minimum requirements before showing review prompt
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

  /// Check conditions and request review if appropriate (with context for custom dialog)
  static Future<void> checkAndRequestReview({
    required BuildContext context,
    required String triggerPoint,
    bool afterPositiveAction = false,
  }) async {
    if (!await _shouldRequestReview(triggerPoint, afterPositiveAction)) return;
    
    // Show our custom rating dialog
    if (context.mounted) {
      await _showCustomRatingDialog(context, triggerPoint);
    }
  }

  /// Check conditions and request review (legacy method for Cubits without context)
  static Future<void> checkAndRequestReviewLegacy({
    required String triggerPoint,
    bool afterPositiveAction = false,
  }) async {
    if (!await _shouldRequestReview(triggerPoint, afterPositiveAction)) return;
    
    // Use native review directly (no custom dialog)
    await _requestAppStoreReview(triggerPoint, 5); // Assume 5-star intent
  }

  /// Check if review should be requested based on conditions
  static Future<bool> _shouldRequestReview(String triggerPoint, bool afterPositiveAction) async {
    final prefs = await SharedPreferences.getInstance();

    // Don't ask if user has already rated the app
    if (prefs.getBool(_hasRatedAppKey) ?? false) return false;

    // Don't ask if already requested recently
    final lastRequestDate = prefs.getString(_lastRequestDateKey);
    if (lastRequestDate != null) {
      final daysSinceLastRequest = DateTime.now().difference(DateTime.parse(lastRequestDate)).inDays;
      if (daysSinceLastRequest < _daysBetweenRequests) return false;
    }

    // Check if minimum conditions are met
    final launchCount = prefs.getInt(_appLaunchCountKey) ?? 0;
    final problemsSolved = prefs.getInt(_problemsSolvedKey) ?? 0;
    final quizzesCompleted = prefs.getInt(_quizzesCompletedKey) ?? 0;

    final isFirstProblemSolved = triggerPoint == 'problem_solved' && problemsSolved == 1;
    final isFirstEligibleQuiz = triggerPoint == 'quiz_completion' && quizzesCompleted >= _minQuizzesCompleted;
    
    // Only show review on specific milestones, not every action
    final shouldRequest = afterPositiveAction && (isFirstProblemSolved || isFirstEligibleQuiz);

    if (shouldRequest) {
      await AnalyticsService.logEvent(
        name: 'review_prompt_triggered',
        parameters: {'trigger_point': triggerPoint, 'launch_count': launchCount, 'problems_solved': problemsSolved, 'quizzes_completed': quizzesCompleted},
      );
    }

    return shouldRequest;
  }

  /// Show custom rating dialog with clear instructions
  static Future<void> _showCustomRatingDialog(
    BuildContext context,
    String triggerPoint,
  ) async {
    if (!context.mounted) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: _buildDialogTitle(context, Icons.star_rate, AppLocalizations.of(context)!.enjoyingMathGenie),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BodyMediumText(AppLocalizations.of(context)!.rateYourExperience, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            BodySmallText(
              AppLocalizations.of(context)!.tapNumberOfStars,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 20),
            _buildStarRating(context, triggerPoint),
          ],
        ),
        actions: [_buildCancelButton(context, AppLocalizations.of(context)!.maybeLater)],
      ),
    );
  }

  /// Build star rating row
  static Widget _buildStarRating(BuildContext context, String triggerPoint) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) => 
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: IconButton(
            icon: Icon(Icons.star_border, color: Theme.of(context).colorScheme.secondary, size: 32),
            onPressed: () => _handleStarRating(context, index + 1, triggerPoint),
          ),
        ),
      ),
    );
  }

  /// Handle star rating selection
  static Future<void> _handleStarRating(BuildContext context, int rating, String triggerPoint) async {
    Navigator.pop(context);
    
    await AnalyticsService.logEvent(
      name: 'custom_rating_selected',
      parameters: {'rating': rating, 'trigger_point': triggerPoint},
    );

    if (rating >= 4) {
      await _requestAppStoreReview(triggerPoint, rating);
    } else {
      if (context.mounted) await _showFeedbackDialog(context, rating, triggerPoint);
    }
  }

  /// Request App Store review for good ratings
  static Future<void> _requestAppStoreReview(String triggerPoint, int rating) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (await _inAppReview.isAvailable()) {
      await _inAppReview.requestReview();
      await prefs.setString(_lastRequestDateKey, DateTime.now().toIso8601String());
      
      await AnalyticsService.logEvent(
        name: 'review_requested',
        parameters: {'method': 'in_app', 'trigger_point': triggerPoint, 'custom_rating': rating},
      );
    } else {
      await openStoreListing();
    }
  }

  /// Show feedback dialog for low ratings
  static Future<void> _showFeedbackDialog(BuildContext context, int rating, String triggerPoint) async {
    if (!context.mounted) return;
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: _buildDialogTitle(context, Icons.feedback_outlined, AppLocalizations.of(context)!.helpUsImprove),
        content: BodyMediumText(AppLocalizations.of(context)!.feedbackMessage, textAlign: TextAlign.center),
        actions: [
          _buildCancelButton(context, AppLocalizations.of(context)!.notNow),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _sendFeedbackEmail(rating, triggerPoint);
            },
            child: LabelLargeText(AppLocalizations.of(context)!.sendFeedback, color: Theme.of(context).colorScheme.secondary),
          ),
        ],
      ),
    );
  }

  /// Build reusable dialog title
  static Widget _buildDialogTitle(BuildContext context, IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 28),
        const SizedBox(width: 12),
        Expanded(child: HeadlineSmallText(title, fontWeight: FontWeight.bold)),
      ],
    );
  }

  /// Build reusable cancel button
  static Widget _buildCancelButton(BuildContext context, String text) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: LabelLargeText(text, color: Theme.of(context).colorScheme.onSurface),
    );
  }

  /// Send feedback email for low ratings
  static Future<void> _sendFeedbackEmail(int rating, String triggerPoint) async {
    await sendGeneralFeedback(
      context: null,
      feedbackType: 'low_rating',
      additionalInfo: 'Rating: $rating stars, Trigger: $triggerPoint',
    );
  }

  /// General feedback functionality (can be used from anywhere)
  static Future<void> sendGeneralFeedback({
    BuildContext? context,
    String feedbackType = 'general',
    String? additionalInfo,
  }) async {
    const email = 'support@jkstudioo.com';
    final subject = Uri.encodeComponent('MathGenie AI Feedback');
    
    final feedbackMessages = {
      'low_rating': 'I have some feedback to help improve the app:',
      'general': 'I would like to share some feedback:',
      'bug_report': 'I encountered an issue and would like to report it:',
      'feature_request': 'I have a feature request:',
    };
    
    String bodyText = 'Hi MathGenie Team,\n\n${feedbackMessages[feedbackType] ?? feedbackMessages['general']}\n\n';
    bodyText += '[Please describe your feedback here]\n\n';
    if (additionalInfo != null) bodyText += 'Additional Info: $additionalInfo\n\n';
    bodyText += 'Thanks!\n\n---\nSent from MathGenie AI';
    
    final uri = Uri.parse('mailto:$email?subject=$subject&body=${Uri.encodeComponent(bodyText)}');
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        await AnalyticsService.logEvent(
          name: 'feedback_email_opened',
          parameters: {'feedback_type': feedbackType, 'has_additional_info': additionalInfo != null},
        );
      } else if (context?.mounted == true) {
        _showFeedbackError(context!);
      }
    } catch (e) {
      if (context?.mounted == true) _showFeedbackError(context!);
      await AnalyticsService.logEvent(
        name: 'feedback_email_failed',
        parameters: {'feedback_type': feedbackType, 'error': e.toString()},
      );
    }
  }

  /// Show error when email app cannot be opened
  static void _showFeedbackError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.feedbackEmailError),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: AppLocalizations.of(context)!.copyEmail,
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${AppLocalizations.of(context)!.supportEmail}: support@jkstudioo.com'),
              duration: const Duration(seconds: 5),
            ),
          ),
        ),
      ),
    );
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
