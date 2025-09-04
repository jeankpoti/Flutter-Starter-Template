import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/flashcard.dart';

class FlashcardReviewButtons extends StatelessWidget {
  final bool showAnswer;
  final bool isFlipping;
  final VoidCallback onShowAnswer;
  final Function(ReviewResult) onReviewCard;

  const FlashcardReviewButtons({
    super.key,
    required this.showAnswer,
    required this.isFlipping,
    required this.onShowAnswer,
    required this.onReviewCard,
  });

  @override
  Widget build(BuildContext context) {
    if (!showAnswer) {
      return _buildShowAnswerButton(context);
    } else {
      return _buildReviewButtons(context);
    }
  }

  Widget _buildShowAnswerButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: FilledButton(
        onPressed: isFlipping ? null : onShowAnswer,
        style: FilledButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.visibility_rounded,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            const SizedBox(width: 12),
            LabelLargeText(
              'Show Answer',
              color: Theme.of(context).colorScheme.onSecondary,
              fontWeight: FontWeight.w600,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.surfaceContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TitleSmallText(
              'How well did you know this?',
              color: Theme.of(context).colorScheme.onSurface,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildReviewButton(
                  context,
                  label: 'Again',
                  color: Theme.of(context).colorScheme.error,
                  icon: Icons.close_rounded,
                  result: ReviewResult.again,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReviewButton(
                  context,
                  label: 'Hard',
                  color: const Color(0xFFFF8C00), // Orange color for hard
                  icon: Icons.trending_down_rounded,
                  result: ReviewResult.hard,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReviewButton(
                  context,
                  label: 'Good',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.check_rounded,
                  result: ReviewResult.good,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildReviewButton(
                  context,
                  label: 'Easy',
                  color: const Color(0xFF4CAF50), // Green color for easy
                  icon: Icons.trending_up_rounded,
                  result: ReviewResult.easy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton(
    BuildContext context, {
    required String label,
    required Color color,
    required IconData icon,
    required ReviewResult result,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isFlipping ? null : () => onReviewCard(result),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(height: 8),
              LabelSmallText(
                label,
                color: color,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}