import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_symbols_widget.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/quiz.dart';

class ShortAnswerQuestionWidget extends StatelessWidget {
  final QuizQuestion question;
  final TextEditingController controller;
  final Function(String) onAnswerChanged;

  const ShortAnswerQuestionWidget({
    super.key,
    required this.question,
    required this.controller,
    required this.onAnswerChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.enterYourAnswer,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            TextField(
              onChanged: onAnswerChanged,
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeAnswerHere,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            MathSymbolsWidget(controller: controller),
          ],
        ),
      ],
    );
  }
}