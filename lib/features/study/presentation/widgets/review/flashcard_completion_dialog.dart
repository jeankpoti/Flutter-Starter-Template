import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
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
                  color: Theme.of(context).colorScheme.secondary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(AppLocalizations.of(context)!.reviewComplete),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      TitleLargeText(
                        '$accuracy%',
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                      BodySmallText(
                        AppLocalizations.of(context)!.accuracy,
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
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
                      AppLocalizations.of(context)!.cards,
                      cards.length.toString(),
                      Icons.style_rounded,
                    ),
                    _buildStatColumn(
                      context,
                      AppLocalizations.of(context)!.correct,
                      sessionCorrectAnswers.toString(),
                      Icons.check_circle_outline,
                    ),
                    _buildStatColumn(
                      context,
                      AppLocalizations.of(context)!.time,
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
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
                onPressed: () {
                  // Close the dialog first
                  Navigator.of(context, rootNavigator: true).pop();

                  // Then navigate back to the previous screen
                  Future.delayed(const Duration(milliseconds: 50), () {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });

                  onComplete();
                },
                child: Text(
                  AppLocalizations.of(context)!.done,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  static Widget _buildStatColumn(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
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
