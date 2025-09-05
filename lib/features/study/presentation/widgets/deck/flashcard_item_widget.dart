import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/flashcard.dart';

class FlashcardItemWidget extends StatelessWidget {
  final FlashCard card;
  final VoidCallback onTap;
  final Function(String) onCardAction;

  const FlashcardItemWidget({
    super.key,
    required this.card,
    required this.onTap,
    required this.onCardAction,
  });

  /// Helper method to render text with math expressions
  Widget _buildMathText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
  }) {
    final mathRegex = RegExp(r'\$([^$]+)\$');
    final matches = mathRegex.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(
        text,
        style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
               TextStyle(color: color, fontWeight: fontWeight),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                 TextStyle(color: color, fontWeight: fontWeight),
        ));
      }

      final mathExpression = match.group(1) ?? '';
      try {
        spans.add(WidgetSpan(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Math.tex(
                mathExpression,
                textStyle: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                           TextStyle(color: color, fontWeight: fontWeight),
                mathStyle: MathStyle.text,
              ),
            ),
          ),
          alignment: PlaceholderAlignment.middle,
        ));
      } catch (e) {
        spans.add(TextSpan(
          text: '\$${mathExpression}\$',
          style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                 TextStyle(color: color, fontWeight: fontWeight),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
               TextStyle(color: color, fontWeight: fontWeight),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      softWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header with status
                Row(
                  children: [
                    _buildCardStatusChip(context),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: onCardAction,
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded),
                            title: Text(AppLocalizations.of(context)!.edit),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_rounded),
                            title: Text(AppLocalizations.of(context)!.delete),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Card content preview
                _buildMathText(
                  card.front,
                  style: Theme.of(context).textTheme.bodyLarge,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildMathText(
                    card.back,
                    style: Theme.of(context).textTheme.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    maxLines: 2,
                  ),
                ),
                
                // Tags
                if (card.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: card.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: LabelSmallText(
                        tag,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStatusChip(BuildContext context) {
    Color color;
    String label;
    
    if (card.isNew) {
      color = Colors.blue;
      label = AppLocalizations.of(context)!.newCards;
    } else if (card.isDue) {
      color = Colors.orange;
      label = AppLocalizations.of(context)!.dueCards;
    } else {
      color = Colors.green;
      label = AppLocalizations.of(context)!.learningCards;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LabelSmallText(
        label,
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}