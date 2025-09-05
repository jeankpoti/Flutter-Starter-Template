import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/flashcard.dart';

class DeckStatsHeaderWidget extends StatelessWidget {
  final List<FlashCard> cards;

  const DeckStatsHeaderWidget({
    super.key,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final newCards = cards.where((c) => c.isNew).length;
    final dueCards = cards.where((c) => c.isDue && !c.isNew).length;
    final learningCards = cards.length - newCards - dueCards;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleLargeText(
                      '${cards.length}',
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    BodyMediumText(
                      AppLocalizations.of(context)!.totalCards,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatChip(context, AppLocalizations.of(context)!.newCards, newCards, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatChip(context, AppLocalizations.of(context)!.dueCards, dueCards, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatChip(context, AppLocalizations.of(context)!.learningCards, learningCards, Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(BuildContext context, String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          TitleSmallText(
            count.toString(),
            color: color,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          LabelSmallText(
            label,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }
}