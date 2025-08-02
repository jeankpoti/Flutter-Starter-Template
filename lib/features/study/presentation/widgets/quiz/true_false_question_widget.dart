import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/quiz.dart';

class TrueFalseQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const TrueFalseQuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.selectTrueFalse,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Row(
          children: question.answers
              .map((answer) {
                final isTrue = answer.text.toLowerCase() == 'true';
                final isSelected = selectedAnswer == answer.id;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: answer == question.answers.last ? 0 : 8,
                    ),
                    child: InkWell(
                      onTap: () => onAnswerSelected(answer.id),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isTrue
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.red.withValues(alpha: 0.1))
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isTrue ? Colors.green : Colors.red)
                                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isTrue ? Icons.check_circle : Icons.cancel,
                                color: isSelected
                                    ? (isTrue ? Colors.green : Colors.red)
                                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              TitleMediumText(
                                answer.text,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? (isTrue ? Colors.green : Colors.red)
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList(),
        ),
      ],
    );
  }
}