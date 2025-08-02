import 'package:flutter/material.dart';
import '../../../../../../common_widgets/text_widgets.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../../domain/models/quiz.dart';
import 'performance_chip_widget.dart';

class QuizHistoryCardWidget extends StatelessWidget {
  final Quiz quiz;
  final int index;
  final VoidCallback onTap;
  final String Function(DateTime) formatDate;
  final Color Function(double) getScoreColor;
  final int Function(Quiz) calculateUnansweredCount;

  const QuizHistoryCardWidget({
    super.key,
    required this.quiz,
    required this.index,
    required this.onTap,
    required this.formatDate,
    required this.getScoreColor,
    required this.calculateUnansweredCount,
  });

  static const double _spacing2 = 8.0;
  static const double _spacing3 = 12.0;
  static const double _spacing4 = 16.0;

  @override
  Widget build(BuildContext context) {
    final score = quiz.lastScore ?? 0.0;
    final completedAt = quiz.lastAttemptAt;

    return TweenAnimationBuilder(
      duration: Duration(
        milliseconds: 300 + (index * 50),
      ), // Staggered animation
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: _spacing3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(_spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TitleMediumText(
                          quiz.title,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: getScoreColor(score).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LabelMediumText(
                          '${score.toStringAsFixed(1)}%',
                          fontWeight: FontWeight.w600,
                          color: getScoreColor(score),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.quiz,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      BodySmallText(
                        '${quiz.questions.length} ${AppLocalizations.of(context)!.questions}',
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      BodySmallText(
                        quiz.difficulty.name.toUpperCase(),
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      if (quiz.attemptCount > 1) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.repeat,
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        BodySmallText(
                          '${quiz.attemptCount} ${AppLocalizations.of(context)!.attempts}',
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (completedAt != null)
                    BodySmallText(
                      '${AppLocalizations.of(context)!.completedOn} ${formatDate(completedAt)}',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),

                  const SizedBox(height: 12),

                  // Performance summary
                  Row(
                    children: [
                      Expanded(
                        child: PerformanceChipWidget(
                          icon: Icons.check_circle,
                          label: AppLocalizations.of(context)!.correct,
                          value: quiz.userAnswers.where((a) => a.isCorrect).length,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: _spacing2),
                      Expanded(
                        child: PerformanceChipWidget(
                          icon: Icons.cancel,
                          label: AppLocalizations.of(context)!.incorrect,
                          value: quiz.userAnswers.where((a) => !a.isCorrect).length,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: _spacing2),
                      Expanded(
                        child: PerformanceChipWidget(
                          icon: Icons.help_outline,
                          label: AppLocalizations.of(context)!.unanswered,
                          value: calculateUnansweredCount(quiz),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}