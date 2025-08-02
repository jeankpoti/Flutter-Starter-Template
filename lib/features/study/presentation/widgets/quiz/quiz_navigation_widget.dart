import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../l10n/app_localizations.dart';

class QuizNavigationWidget extends StatelessWidget {
  final int currentQuestionIndex;
  final int totalQuestions;
  final bool isLastQuestion;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const QuizNavigationWidget({
    super.key,
    required this.currentQuestionIndex,
    required this.totalQuestions,
    required this.isLastQuestion,
    required this.onPrevious,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          if (currentQuestionIndex > 0)
            TextButton.icon(
              onPressed: onPrevious,
              icon: const Icon(Icons.arrow_back),
              label: LabelLargeText(
                AppLocalizations.of(context)!.previous,
                color: Theme.of(context).colorScheme.secondary,
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            )
          else
            const SizedBox(width: 100),

          // Question counter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TitleSmallText(
              '${currentQuestionIndex + 1} / $totalQuestions',
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),

          // Next/Finish button
          if (!isLastQuestion)
            TextButton.icon(
              onPressed: onNext,
              label: LabelLargeText(
                AppLocalizations.of(context)!.next,
                color: Theme.of(context).colorScheme.secondary,
              ),
              icon: const Icon(Icons.arrow_forward),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            )
          else
            ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: LabelLargeText(
                AppLocalizations.of(context)!.finishQuiz,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
        ],
      ),
    );
  }
}