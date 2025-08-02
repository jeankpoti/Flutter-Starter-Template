import 'package:flutter/material.dart';
import 'stat_card_widget.dart';
import 'detailed_stat_card_widget.dart';
import '../../helpers/date_format_helper.dart';
import '../../helpers/quiz_performance_helper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';

class QuizStatisticsTabWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const QuizStatisticsTabWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    TitleLargeText(
                      AppLocalizations.of(context)!.quizStatistics,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        title: AppLocalizations.of(context)!.totalQuizzes,
                        value: statistics['totalQuizzes']?.toString() ?? '0',
                        icon: Icons.quiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        title: AppLocalizations.of(context)!.averageScore,
                        value: '${(statistics['averageScore'] ?? 0.0).toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: StatCardWidget(
                        title: AppLocalizations.of(context)!.bestScore,
                        value: '${(statistics['bestScore'] ?? 0.0).toStringAsFixed(1)}%',
                        icon: Icons.emoji_events,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCardWidget(
                        title: AppLocalizations.of(context)!.currentStreak,
                        value: '${statistics['streakCount'] ?? 0} ${AppLocalizations.of(context)!.days}',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Detailed statistics
          TitleMediumText(
            AppLocalizations.of(context)!.detailedStatistics,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DetailedStatCardWidget(
                  title: AppLocalizations.of(context)!.questionsAnswered,
                  value: statistics['totalQuestionsAnswered']?.toString() ?? '0',
                  subtitle: AppLocalizations.of(context)!.totalQuestionsAttempted,
                  icon: Icons.help_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DetailedStatCardWidget(
                  title: AppLocalizations.of(context)!.correctAnswers,
                  value: statistics['totalCorrectAnswers']?.toString() ?? '0',
                  subtitle: AppLocalizations.of(context)!.questionsAnsweredCorrectly,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity
          if (statistics['recentActivity'] != null &&
              (statistics['recentActivity'] as List).isNotEmpty) ...[
            TitleMediumText(
              AppLocalizations.of(context)!.recentActivity,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),

            ...(statistics['recentActivity'] as List<Map<String, dynamic>>)
                .take(5)
                .map((activity) => _buildRecentActivityCard(context, activity)),
          ],
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(BuildContext context, Map<String, dynamic> activity) {
    final score = activity['score'] as double?;
    final completedAt = activity['completedAt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.quiz,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(
                  activity['title'] ?? AppLocalizations.of(context)!.quiz,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                if (completedAt != null)
                  BodySmallText(
                    DateFormatHelper.formatDate(context, DateTime.parse(completedAt)),
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
          if (score != null)
            LabelMediumText(
              '${score.toStringAsFixed(1)}%',
              fontWeight: FontWeight.w600,
              color: QuizPerformanceHelper.getScoreColor(context, score),
            ),
        ],
      ),
    );
  }
}