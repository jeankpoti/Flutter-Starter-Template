import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../../solve_math/domain/models/quiz_difficulty.dart';
import '../quiz_history_page.dart';

class QuizSectionWidget extends StatelessWidget {
  final List<dynamic> studyPlans;
  final List<dynamic> studyMaterials;
  final bool isQuickQuizLoading;
  final bool isPracticeTestLoading;
  final bool isChallengeLoading;
  final Function({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) onGenerateAndStartQuiz;
  final VoidCallback onAllMaterialsQuiz;

  const QuizSectionWidget({
    super.key,
    required this.studyPlans,
    required this.studyMaterials,
    required this.isQuickQuizLoading,
    required this.isPracticeTestLoading,
    required this.isChallengeLoading,
    required this.onGenerateAndStartQuiz,
    required this.onAllMaterialsQuiz,
  });

  static const double _spacing4 = 16.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),
        const SizedBox(height: 16),
        _buildQuizContainer(context),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: HeadlineSmallText(
            AppLocalizations.of(context)!.practiceQuizzes,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        TextButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QuizHistoryPage(),
              ),
            );
          },
          icon: const Icon(Icons.history),
          label: LabelLargeText(AppLocalizations.of(context)!.history),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuizContainer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacing4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(context),
          const SizedBox(height: 12),
          _buildDescription(context),
          const SizedBox(height: 20),
          _buildQuizOptions(context),
          if (studyPlans.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildChallengeQuiz(context),
          ],
          if (studyMaterials.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildAllMaterialsQuizButton(context),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
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
    );
  }

  Widget _buildDescription(BuildContext context) {
    return BodyMediumText(
      AppLocalizations.of(context)!.testKnowledgeDescription,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
    );
  }

  Widget _buildQuizOptions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildQuizOptionButton(
            context,
            icon: Icons.flash_on,
            title: AppLocalizations.of(context)!.quickQuiz,
            subtitle: AppLocalizations.of(context)!.quickQuizSubtitle,
            difficulty: QuizDifficulty.easy,
            questionCount: 5,
            timeLimit: 10,
            isLoading: isQuickQuizLoading,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuizOptionButton(
            context,
            icon: Icons.school,
            title: AppLocalizations.of(context)!.practiceTest,
            subtitle: AppLocalizations.of(context)!.practiceTestSubtitle,
            difficulty: QuizDifficulty.medium,
            questionCount: 10,
            timeLimit: 20,
            isLoading: isPracticeTestLoading,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeQuiz(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: _buildQuizOptionButton(
        context,
        icon: Icons.emoji_events,
        title: AppLocalizations.of(context)!.challengeMode,
        subtitle: AppLocalizations.of(context)!.challengeModeSubtitle,
        difficulty: QuizDifficulty.hard,
        questionCount: 15,
        timeLimit: 30,
        isFullWidth: true,
        isLoading: isChallengeLoading,
      ),
    );
  }

  Widget _buildQuizOptionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
    bool isFullWidth = false,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: InkWell(
        onTap: isLoading
            ? null
            : () => onGenerateAndStartQuiz(
                  difficulty: difficulty,
                  questionCount: questionCount,
                  timeLimit: timeLimit,
                ),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isFullWidth
              ? _buildFullWidthContent(context, icon, title, subtitle, isLoading)
              : _buildCompactContent(context, icon, title, subtitle, isLoading),
        ),
      ),
    );
  }

  Widget _buildFullWidthContent(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isLoading,
  ) {
    return Row(
      children: [
        isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            : Icon(
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
              const SizedBox(height: 4),
              BodySmallText(
                subtitle,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactContent(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.secondary,
                  ),
                ),
              )
            : Icon(
                icon,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
        const SizedBox(height: 8),
        TitleMediumText(
          title,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 4),
        BodySmallText(
          subtitle,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildAllMaterialsQuizButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onAllMaterialsQuiz,
        icon: const Icon(Icons.quiz),
        label: TitleMediumText(
          AppLocalizations.of(context)!.generateQuizWithAllMaterials,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}