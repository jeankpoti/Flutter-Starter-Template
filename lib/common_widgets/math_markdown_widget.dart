import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MathMarkdownWidget extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final double? fontSize;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final bool selectable;

  const MathMarkdownWidget({
    super.key,
    required this.data,
    this.textStyle,
    this.fontSize,
    this.textColor,
    this.padding,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16.0),
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    // Split content into lines for analysis
    final lines = data.split('\n');
    List<Widget> widgets = [];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      final isHighlighted = _shouldHighlightLine(line, i, lines);
      
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8.0));
        continue;
      }

      final widget = _buildLineWidget(context, line, isHighlighted);
      widgets.add(widget);
      
      // Add spacing between lines
      if (i < lines.length - 1) {
        widgets.add(const SizedBox(height: 4.0));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  bool _shouldHighlightLine(String line, int index, List<String> allLines) {
    final trimmedLine = line.trim();

    // Don't highlight empty lines
    if (trimmedLine.isEmpty) return false;

    // Check for final answer patterns
    final finalAnswerPatterns = [
      RegExp(
        r'^\s*\$\\frac\{.+\}\{.+\}\s*$',
        multiLine: true,
      ), // Final fraction like $\frac{1}{2\pi}$
      RegExp(
        r'^\s*\$.*=.*\$\s*$',
        multiLine: true,
      ), // Math equation ending like $dh/dt = \frac{1}{2\pi}$
      RegExp(r'^\s*Therefore,?\s+.+', caseSensitive: false),
      RegExp(r'^\s*Thus,?\s+.+', caseSensitive: false),
      RegExp(r'^\s*So,?\s+.+', caseSensitive: false),
      RegExp(r'^\s*Answer:?\s+.+', caseSensitive: false),
      RegExp(r'^\s*Final answer:?\s+.+', caseSensitive: false),
      RegExp(r'^\s*Result:?\s+.+', caseSensitive: false),
      RegExp(r'^\s*Solution:?\s+.+', caseSensitive: false),
    ];

    // Check if this line matches any final answer pattern
    for (final pattern in finalAnswerPatterns) {
      if (pattern.hasMatch(trimmedLine)) {
        return true;
      }
    }

    // Check if it's the last meaningful line with math content
    if (index >= allLines.length - 3) {
      // Check last 3 lines
      final hasmath = RegExp(r'\$[^$]+\$').hasMatch(trimmedLine);
      final hasEquation = trimmedLine.contains('=');
      if (hasmath && hasEquation) {
        return true;
      }
    }

    return false;
  }

  Widget _buildLineWidget(
    BuildContext context,
    String line,
    bool isHighlighted,
  ) {
    // Check if the line contains LaTeX math expressions
    final mathRegex = RegExp(r'\$\$([^$]+)\$\$|\$([^$]+)\$');
    final matches = mathRegex.allMatches(line);

    Widget contentWidget;

    if (matches.isEmpty) {
      // No math expressions, use regular markdown
      contentWidget = MarkdownBody(
        data: line,
        styleSheet: MarkdownStyleSheet(
          p:
              textStyle?.copyWith(
                fontSize: fontSize,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ) ??
              TextStyle(
                fontSize: fontSize,
                color: textColor ?? Theme.of(context).colorScheme.onSurface,
              ),
        ),
        selectable: selectable,
      );
    } else {
      // Line contains math expressions, build mixed content
      List<Widget> lineWidgets = [];
      int lastMatchEnd = 0;

      for (final match in matches) {
        // Add text before the math expression
        if (match.start > lastMatchEnd) {
          final textContent = line.substring(lastMatchEnd, match.start);
          if (textContent.trim().isNotEmpty) {
            lineWidgets.add(
              Text(
                textContent,
                style:
                    textStyle?.copyWith(
                      fontSize: fontSize,
                      color:
                          textColor ??
                          Theme.of(context).colorScheme.onSurface,
                    ) ??
                    TextStyle(
                      fontSize: fontSize,
                      color:
                          textColor ??
                          Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            );
          }
        }

        // Add the math expression
        final mathExpression = match.group(1) ?? match.group(2) ?? '';
        final isDisplayMath = match.group(0)?.startsWith('\$\$') ?? false;
        
        try {
          lineWidgets.add(
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Math.tex(
                mathExpression,
                textStyle: textStyle?.copyWith(
                  fontSize: fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ) ?? TextStyle(
                  fontSize: fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
                mathStyle: isDisplayMath ? MathStyle.display : MathStyle.text,
              ),
            ),
          );
        } catch (e) {
          // If math parsing fails, show the original text
          lineWidgets.add(
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              child: Text(
                match.group(0) ?? '',
                style: textStyle?.copyWith(
                  fontSize: fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ) ?? TextStyle(
                  fontSize: fontSize,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }

        lastMatchEnd = match.end;
      }

      // Add remaining text after the last math expression
      if (lastMatchEnd < line.length) {
        final remainingText = line.substring(lastMatchEnd);
        if (remainingText.trim().isNotEmpty) {
          lineWidgets.add(
            Text(
              remainingText,
              style:
                  textStyle?.copyWith(
                    fontSize: fontSize,
                    color:
                        textColor ?? Theme.of(context).colorScheme.onSurface,
                  ) ??
                  TextStyle(
                    fontSize: fontSize,
                    color:
                        textColor ?? Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          );
        }
      }

      contentWidget = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: lineWidgets.map((widget) {
            return Padding(
              padding: const EdgeInsets.only(right: 4.0),
              child: widget,
            );
          }).toList(),
        ),
      );
    }

    // Apply highlighting if needed
    if (isHighlighted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
        child: contentWidget,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: contentWidget,
    );
  }
}