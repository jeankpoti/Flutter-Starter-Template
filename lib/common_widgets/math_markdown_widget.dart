import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathMarkdownWidget extends StatelessWidget {
  final String data;

  const MathMarkdownWidget({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parseContent(data, context),
        ),
      ),
    );
  }

  List<Widget> _parseContent(String text, BuildContext context) {
    final List<Widget> widgets = [];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 12));
        continue;
      }

      // Check for LaTeX math expressions
      if (line.contains(r'$') && line.contains(r'\boxed')) {
        // Handle boxed math expressions
        final regex = RegExp(r'\$([^$]+)\$');
        if (regex.hasMatch(line)) {
          try {
            final match = regex.firstMatch(line)!;
            final mathExpression = match.group(1)!;

            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Center(
                  child: Math.tex(
                    mathExpression,
                    textStyle: Theme.of(
                      context,
                    ).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          } catch (e) {
            // If LaTeX parsing fails, show as regular text
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
        }
      } else if (line.contains(r'$')) {
        // Handle inline math expressions
        try {
          final regex = RegExp(r'\$([^$]+)\$');
          final matches = regex.allMatches(line).toList();

          if (matches.isNotEmpty) {
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: _buildInlineSpans(line, matches, context),
                  ),
                ),
              ),
            );
          } else {
            widgets.add(
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  line,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            );
          }
        } catch (e) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(line, style: Theme.of(context).textTheme.bodyMedium),
            ),
          );
        }
      } else {
        // Regular text with markdown formatting
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _buildFormattedText(line, context),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildFormattedText(String line, BuildContext context) {
    // Handle different markdown formats

    // Check for full line bold titles like "**Problem:**" or "**Solution Steps:**"
    if (line.startsWith('**') && line.endsWith('**') && line.contains(':')) {
      final titleText = line.substring(2, line.length - 2);
      return Container(
        margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              _getIconForTitle(titleText),
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                titleText,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (line.startsWith('# ')) {
      // Header 1 (fallback)
      return Text(
        line.substring(2),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } else if (line.startsWith('## ')) {
      // Header 2 (fallback)
      return Text(
        line.substring(3),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } else if (line.startsWith('### ')) {
      // Header 3 (fallback)
      return Text(
        line.substring(4),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } else if (line.contains('**')) {
      // Handle bold text within line
      return RichText(
        text: TextSpan(
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          children: _buildBoldSpans(line, context),
        ),
      );
    } else if (line.startsWith('- ') || line.startsWith('* ')) {
      // Bullet points
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 6),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                line.substring(2),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (RegExp(r'^\d+\.').hasMatch(line)) {
      // Numbered lists
      final match = RegExp(r'^(\d+)\. (.*)').firstMatch(line);
      if (match != null) {
        final number = match.group(1)!;
        final content = match.group(2)!;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return Text(
        line,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    } else {
      // Regular text
      return Text(
        line,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      );
    }
  }

  List<InlineSpan> _buildBoldSpans(String text, BuildContext context) {
    final List<InlineSpan> spans = [];
    final boldRegex = RegExp(r'\*\*(.*?)\*\*');
    final matches = boldRegex.allMatches(text).toList();

    if (matches.isEmpty) {
      spans.add(TextSpan(text: text));
      return spans;
    }

    int currentIndex = 0;

    for (final match in matches) {
      // Add text before bold
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      // Add bold text
      spans.add(
        TextSpan(
          text: match.group(1)!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  List<InlineSpan> _buildInlineSpans(
    String text,
    List<RegExpMatch> mathMatches,
    BuildContext context,
  ) {
    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in mathMatches) {
      // Add text before math
      if (match.start > currentIndex) {
        spans.add(TextSpan(text: text.substring(currentIndex, match.start)));
      }

      // Add math widget
      try {
        final mathExpression = match.group(1)!;
        spans.add(
          WidgetSpan(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6.0,
                vertical: 2.0,
              ),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Math.tex(
                mathExpression,
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        // If math parsing fails, add as regular text
        spans.add(
          TextSpan(
            text: match.group(0)!,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      }

      currentIndex = match.end;
    }

    // Add remaining text
    if (currentIndex < text.length) {
      spans.add(TextSpan(text: text.substring(currentIndex)));
    }

    return spans;
  }

  IconData _getIconForTitle(String title) {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('problem')) {
      return Icons.quiz_outlined;
    } else if (titleLower.contains('solution') ||
        titleLower.contains('steps')) {
      return Icons.auto_fix_high;
    } else if (titleLower.contains('answer') || titleLower.contains('final')) {
      return Icons.check_circle_outline;
    } else if (titleLower.contains('given') ||
        titleLower.contains('information')) {
      return Icons.info_outline;
    } else if (titleLower.contains('approach') ||
        titleLower.contains('method')) {
      return Icons.lightbulb_outline;
    } else {
      return Icons.arrow_forward_ios;
    }
  }
}
