import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../domain/models/flashcard.dart';

class FlashcardDisplayWidget extends StatelessWidget {
  final FlashCard card;
  final bool showAnswer;
  final Animation<double> flipAnimation;
  final VoidCallback? onTap;

  const FlashcardDisplayWidget({
    super.key,
    required this.card,
    required this.showAnswer,
    required this.flipAnimation,
    this.onTap,
  });

  /// Helper method to render text with math expressions
  Widget _buildMathText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
  }) {
    // Check if text contains LaTeX math expressions (enclosed in $ symbols)
    final mathRegex = RegExp(r'\$([^$]+)\$');
    final matches = mathRegex.allMatches(text);

    if (matches.isEmpty) {
      // No math expressions, return regular text
      return Text(
        text,
        style:
            style?.copyWith(color: color, fontWeight: fontWeight) ??
            TextStyle(color: color, fontWeight: fontWeight),
        textAlign: textAlign ?? TextAlign.center,
      );
    }

    // Text contains math expressions, build mixed content
    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before the math expression
      if (match.start > lastMatchEnd) {
        spans.add(
          TextSpan(
            text: text.substring(lastMatchEnd, match.start),
            style:
                style?.copyWith(color: color, fontWeight: fontWeight) ??
                TextStyle(color: color, fontWeight: fontWeight),
          ),
        );
      }

      // Add the math expression
      final mathExpression = match.group(1) ?? '';
      try {
        spans.add(
          WidgetSpan(
            child: Math.tex(
              mathExpression,
              textStyle:
                  style?.copyWith(color: color, fontWeight: fontWeight) ??
                  TextStyle(color: color, fontWeight: fontWeight),
              mathStyle: MathStyle.text,
            ),
            alignment: PlaceholderAlignment.middle,
          ),
        );
      } catch (e) {
        // If math parsing fails, show the original text
        spans.add(
          TextSpan(
            text: '\$$mathExpression\$',
            style:
                style?.copyWith(color: color, fontWeight: fontWeight) ??
                TextStyle(color: color, fontWeight: fontWeight),
          ),
        );
      }

      lastMatchEnd = match.end;
    }

    // Add remaining text after the last math expression
    if (lastMatchEnd < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(lastMatchEnd),
          style:
              style?.copyWith(color: color, fontWeight: fontWeight) ??
              TextStyle(color: color, fontWeight: fontWeight),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.center,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: showAnswer ? null : onTap,
      child: AnimatedBuilder(
        animation: flipAnimation,
        builder: (context, child) {
          final isShowingFront = flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(flipAnimation.value * 3.14159),
            child: Container(
              width: double.infinity,
              height: 420,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isShowingFront
                          ? [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surfaceContainer
                                .withValues(alpha: 0.3),
                          ]
                          : [
                            Theme.of(context).colorScheme.secondaryContainer
                                .withValues(alpha: 0.8),
                            Theme.of(context).colorScheme.tertiaryContainer
                                .withValues(alpha: 0.6),
                          ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color:
                      isShowingFront
                          ? Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.2)
                          : Theme.of(
                            context,
                          ).colorScheme.secondary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.08),
                    offset: const Offset(0, 12),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                  BoxShadow(
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withValues(alpha: 0.04),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child:
                  isShowingFront
                      ? _buildCardFront(context, card)
                      : Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateY(3.14159),
                        child: _buildCardBack(context, card),
                      ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(BuildContext context, FlashCard card) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          // Header with question icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.quiz_rounded,
              size: 32,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          const SizedBox(height: 32),

          // Question content
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildMathText(
                      card.front,
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),

                    if (card.hint != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiaryContainer
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.tertiary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.tertiary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.lightbulb_outline_rounded,
                                size: 20,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LabelSmallText(
                                    AppLocalizations.of(context)!.hint,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(height: 4),
                                  _buildMathText(
                                    card.hint!,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                    textAlign: TextAlign.left,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onTertiaryContainer,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Tap instruction
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.secondary.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.touch_app_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 8),
                LabelMediumText(
                  AppLocalizations.of(context)!.tapToRevealAnswer,
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, FlashCard card) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        height: 450,
        child: Column(
          children: [
            // Header with answer icon
            Icon(
              Icons.check_circle_outline_rounded,
              size: 32,
              color: Theme.of(context).colorScheme.surface,
            ),
            const SizedBox(height: 15),

            // Answer content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: _buildMathText(
                          card.back,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      if (card.tags.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainer
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.local_offer_rounded,
                                    size: 16,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 8),
                                  LabelSmallText(
                                    AppLocalizations.of(context)!.topics,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    card.tags
                                        .map(
                                          (tag) => Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .secondary
                                                  .withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.2),
                                              ),
                                            ),
                                            child: LabelSmallText(
                                              tag,
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
