import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_text_widget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/quiz.dart';

class MultipleChoiceQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final String? selectedAnswer;
  final Function(String) onAnswerSelected;

  const MultipleChoiceQuestionWidget({
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
          AppLocalizations.of(context)!.selectCorrectAnswer,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        ...question.answers.map((answer) {
          final isSelected = selectedAnswer == answer.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onAnswerSelected(answer.id),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                      ),
                      child:
                          isSelected
                              ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                              : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          answer.text.contains(r'$') ||
                                  answer.text.contains(r'\(')
                              ? MathTextWidget(
                                answer.text,
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.copyWith(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                ),
                              )
                              : BodyLargeText(
                                answer.text,
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
