import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../domain/models/study_plan.dart';
import '../../domain/models/quiz.dart';
import 'all_material_quiz.dart';

class QuizSection extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final bool isQuickQuizLoading;
  final bool isPracticeTestLoading;
  final bool isChallengeLoading;
  final bool isAllMaterialsQuizLoading;
  final void Function({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  })
  onGenerateQuiz;
  final VoidCallback onGenerateAllMaterialsQuiz;
  final VoidCallback onShowHistory;

  const QuizSection({
    super.key,
    required this.studyPlans,
    required this.isQuickQuizLoading,
    required this.isPracticeTestLoading,
    required this.isChallengeLoading,
    required this.isAllMaterialsQuizLoading,
    required this.onGenerateQuiz,
    required this.onGenerateAllMaterialsQuiz,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: HeadlineSmallText(
                AppLocalizations.of(context)!.practiceQuizzes,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: onShowHistory,
              icon: const Icon(Icons.history),
              label: LabelLargeText(AppLocalizations.of(context)!.history),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withOpacity(0.2),
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
                    Icons.quiz,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TitleLargeText(
                      AppLocalizations.of(context)!.testYourKnowledge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BodyMediumText(
                AppLocalizations.of(context)!.testKnowledgeDescription,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: QuizOptionButton(
                      icon: Icons.flash_on,
                      title: AppLocalizations.of(context)!.quickQuiz,
                      subtitle: AppLocalizations.of(context)!.quickQuizSubtitle,
                      onTap:
                          () => onGenerateQuiz(
                            difficulty: QuizDifficulty.easy,
                            questionCount: 5,
                            timeLimit: 10,
                          ),
                      isLoading: isQuickQuizLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuizOptionButton(
                      icon: Icons.school,
                      title: AppLocalizations.of(context)!.practiceTest,
                      subtitle:
                          AppLocalizations.of(context)!.practiceTestSubtitle,
                      onTap:
                          () => onGenerateQuiz(
                            difficulty: QuizDifficulty.medium,
                            questionCount: 10,
                            timeLimit: 20,
                          ),
                      isLoading: isPracticeTestLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (studyPlans.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: QuizOptionButton(
                    icon: Icons.emoji_events,
                    title: AppLocalizations.of(context)!.challengeMode,
                    subtitle:
                        AppLocalizations.of(context)!.challengeModeSubtitle,
                    onTap:
                        () => onGenerateQuiz(
                          difficulty: QuizDifficulty.hard,
                          questionCount: 15,
                          timeLimit: 30,
                        ),
                    isFullWidth: true,
                    isLoading: isChallengeLoading,
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: AllMaterialsQuizButton(
                  onTap: onGenerateAllMaterialsQuiz,
                  isLoading: isAllMaterialsQuizLoading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class QuizOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isFullWidth;
  final bool isLoading;

  const QuizOptionButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isFullWidth = false,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isFullWidth
                  ? Row(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          icon,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 24,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleMediumText(
                              title,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            BodySmallText(
                              subtitle,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                        size: 16,
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          icon,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32,
                        ),
                      const SizedBox(height: 8),
                      TitleSmallText(
                        title,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      LabelSmallText(
                        subtitle,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
