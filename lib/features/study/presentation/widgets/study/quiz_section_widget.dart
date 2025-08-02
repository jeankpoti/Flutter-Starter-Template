import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/quiz.dart';
import '../../../domain/models/study_plan.dart';
import '../../study_cubit.dart';
import '../../study_state.dart';

class QuizSectionWidget extends StatelessWidget {
  final Function({
    QuizDifficulty difficulty,
    int questionCount,
    int timeLimit,
    StudyPlan? selectedPlan,
  })
  onGenerateQuiz;

  const QuizSectionWidget({super.key, required this.onGenerateQuiz});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleLargeText(
              AppLocalizations.of(context)!.testYourKnowledge,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              AppLocalizations.of(context)!.testKnowledgeDescription,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 24),

            // Quiz Options Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                _buildQuizCard(
                  context,
                  title: AppLocalizations.of(context)!.quickQuiz,
                  subtitle: AppLocalizations.of(context)!.quickQuizSubtitle,
                  icon: Icons.flash_on,
                  color: Colors.blue,
                  isLoading: state.isQuickQuizLoading,
                  onPressed:
                      () => onGenerateQuiz(
                        difficulty: QuizDifficulty.easy,
                        questionCount: 5,
                        timeLimit: 10,
                      ),
                ),
                _buildQuizCard(
                  context,
                  title: AppLocalizations.of(context)!.practiceTest,
                  subtitle: AppLocalizations.of(context)!.practiceTestSubtitle,
                  icon: Icons.assignment,
                  color: Colors.orange,
                  isLoading: state.isPracticeTestLoading,
                  onPressed:
                      () => onGenerateQuiz(
                        difficulty: QuizDifficulty.medium,
                        questionCount: 10,
                        timeLimit: 20,
                      ),
                ),
                _buildQuizCard(
                  context,
                  title: AppLocalizations.of(context)!.challengeMode,
                  subtitle: AppLocalizations.of(context)!.challengeModeSubtitle,
                  icon: Icons.psychology,
                  color: Colors.red,
                  isLoading: state.isChallengeLoading,
                  onPressed:
                      () => onGenerateQuiz(
                        difficulty: QuizDifficulty.hard,
                        questionCount: 15,
                        timeLimit: 30,
                      ),
                ),
                _buildQuizCard(
                  context,
                  title: AppLocalizations.of(context)!.allStudyMaterials,
                  subtitle:
                      AppLocalizations.of(context)!.allMaterialsQuizDescription,
                  icon: Icons.library_books,
                  color: Colors.purple,
                  isLoading: state.isAllMaterialsQuizLoading,
                  onPressed:
                      () => onGenerateQuiz(
                        difficulty: QuizDifficulty.medium,
                        questionCount: 12,
                        timeLimit: 25,
                      ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuizCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const Spacer(),
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      )
                    else
                      Icon(Icons.arrow_forward_ios, color: color, size: 16),
                  ],
                ),
                const SizedBox(height: 12),
                TitleMediumText(
                  title,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                BodySmallText(
                  subtitle,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
