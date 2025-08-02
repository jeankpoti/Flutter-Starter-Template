import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/quiz.dart';

class QuizPerformanceHelper {
  static Color getScoreColor(BuildContext context, double score) {
    if (score >= 80) return Theme.of(context).colorScheme.secondary;
    if (score >= 60) return Theme.of(context).colorScheme.tertiary;
    return Theme.of(context).colorScheme.error;
  }

  static int calculateUnansweredCount(Quiz quiz) {
    // Count questions that either have no answer entry or have null answers (skipped)
    final answeredQuestionIds = quiz.userAnswers
        .where(
          (answer) =>
              answer.selectedAnswerId != null || answer.textAnswer != null,
        )
        .map((answer) => answer.questionId)
        .toSet();

    return quiz.questions.length - answeredQuestionIds.length;
  }

  static String getPerformanceInsight(
    BuildContext context,
    List<Map<String, dynamic>> performanceTrends,
  ) {
    if (performanceTrends.isEmpty) {
      return AppLocalizations.of(context)!.noRecentActivity;
    }

    final recent = performanceTrends.length > 5
        ? performanceTrends.skip(performanceTrends.length - 5).toList()
        : performanceTrends;
    final scores = recent.map((t) => t['averageScore'] as double).toList();

    if (scores.length < 2) {
      return AppLocalizations.of(context)!.takeMoreQuizzes;
    }

    final trend = scores.last - scores.first;

    if (trend > 5) {
      return AppLocalizations.of(context)!.performanceImprovement;
    } else if (trend < -5) {
      return AppLocalizations.of(context)!.performanceDecline;
    } else {
      return AppLocalizations.of(context)!.performanceConsistent;
    }
  }
}