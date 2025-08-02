import 'package:flutter/material.dart';
import 'quiz_empty_state_widget.dart';
import '../../helpers/quiz_performance_helper.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';

class QuizProgressTabWidget extends StatelessWidget {
  final List<Map<String, dynamic>> performanceTrends;

  const QuizProgressTabWidget({
    super.key,
    required this.performanceTrends,
  });

  @override
  Widget build(BuildContext context) {
    if (performanceTrends.isEmpty) {
      return QuizEmptyStateWidget(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.noProgressData,
        subtitle: AppLocalizations.of(context)!.noProgressDataSubtitle,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleMediumText(
            AppLocalizations.of(context)!.performanceTrends,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          // Simple progress chart representation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TitleSmallText(
                      AppLocalizations.of(context)!.averageScoreTrend,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodySmallText(
                      '${performanceTrends.length} ${AppLocalizations.of(context)!.daysWithActivity}',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Simple bar chart representation
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: performanceTrends.length,
                    itemBuilder: (context, index) {
                      final trend = performanceTrends[index];
                      final score = trend['averageScore'] as double;
                      final height = (score / 100) * 150; // Scale to 150px max height

                      return Container(
                        width: 30,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: QuizPerformanceHelper.getScoreColor(context, score),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            LabelSmallText(
                              '${score.toStringAsFixed(0)}%',
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress insights
          TitleMediumText(
            AppLocalizations.of(context)!.progressInsights,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          if (performanceTrends.isNotEmpty) ...[
            _buildInsightCard(
              context: context,
              icon: Icons.show_chart,
              title: AppLocalizations.of(context)!.recentPerformance,
              description: _getPerformanceInsight(context),
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              context: context,
              icon: Icons.calendar_today,
              title: AppLocalizations.of(context)!.activityPattern,
              description: AppLocalizations.of(context)!.activityPatternDescription(performanceTrends.length),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleSmallText(
                  title,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                BodySmallText(
                  description,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPerformanceInsight(BuildContext context) {
    return QuizPerformanceHelper.getPerformanceInsight(
      context,
      performanceTrends,
    );
  }
}