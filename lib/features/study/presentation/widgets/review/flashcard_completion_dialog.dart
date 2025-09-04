import 'package:flutter/material.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/flashcard.dart';

class FlashcardCompletionDialog {
  static void show({
    required BuildContext context,
    required List<FlashCard> cards,
    required int sessionCorrectAnswers,
    required ReviewSession? currentSession,
    required VoidCallback onComplete,
  }) {
    final accuracy =
        cards.isNotEmpty
            ? (sessionCorrectAnswers / cards.length * 100).round()
            : 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.celebration_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Review Complete!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TitleLargeText(
                        '$accuracy%',
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      BodySmallText(
                        'Accuracy',
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      context,
                      'Cards',
                      cards.length.toString(),
                      Icons.style_rounded,
                    ),
                    _buildStatColumn(
                      context,
                      'Correct',
                      sessionCorrectAnswers.toString(),
                      Icons.check_circle_outline,
                    ),
                    _buildStatColumn(
                      context,
                      'Time',
                      _formatDuration(
                        currentSession?.duration ?? Duration.zero,
                      ),
                      Icons.access_time_rounded,
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Go back to flashcards
                  onComplete();
                },
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  static Widget _buildStatColumn(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 20),
        const SizedBox(height: 4),
        TitleSmallText(value, fontWeight: FontWeight.w600),
        BodySmallText(
          label,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  static String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }
}