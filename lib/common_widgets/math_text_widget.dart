import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class MathTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Color? color;
  final FontWeight? fontWeight;
  final double? height;
  final TextAlign? textAlign;

  const MathTextWidget(
    this.text, {
    super.key,
    this.style,
    this.color,
    this.fontWeight,
    this.height,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyMedium;
    final effectiveColor = color ?? Theme.of(context).colorScheme.onSurface;
    
    return Column(
      crossAxisAlignment: textAlign == TextAlign.center 
          ? CrossAxisAlignment.center 
          : CrossAxisAlignment.start,
      children: _parseText(text, context, effectiveStyle, effectiveColor),
    );
  }

  List<Widget> _parseText(String text, BuildContext context, TextStyle? baseStyle, Color effectiveColor) {
    final widgets = <Widget>[];
    final lines = text.split('\n');
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }
      
      widgets.add(_parseLine(line, context, baseStyle, effectiveColor));
      
      // Add spacing between lines except for the last one
      if (i < lines.length - 1) {
        widgets.add(SizedBox(height: height != null ? (height! * 8) : 8));
      }
    }
    
    return widgets;
  }

  Widget _parseLine(String line, BuildContext context, TextStyle? baseStyle, Color effectiveColor) {
    final parts = <Widget>[];
    final regex = RegExp(r'\$([^$]+)\$');
    int lastEnd = 0;
    
    for (final match in regex.allMatches(line)) {
      // Add text before math expression
      if (match.start > lastEnd) {
        final textPart = line.substring(lastEnd, match.start);
        if (textPart.isNotEmpty) {
          parts.add(_buildText(textPart, baseStyle, effectiveColor));
        }
      }
      
      // Add math expression
      final mathExpression = match.group(1)!;
      parts.add(_buildMath(mathExpression, context, baseStyle, effectiveColor));
      
      lastEnd = match.end;
    }
    
    // Add remaining text
    if (lastEnd < line.length) {
      final remaining = line.substring(lastEnd);
      if (remaining.isNotEmpty) {
        parts.add(_buildText(remaining, baseStyle, effectiveColor));
      }
    }
    
    // If no math expressions found, return simple text
    if (parts.isEmpty) {
      return _buildText(line, baseStyle, effectiveColor);
    }
    
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: parts,
    );
  }

  Widget _buildText(String text, TextStyle? baseStyle, Color effectiveColor) {
    return Text(
      text,
      style: baseStyle?.copyWith(
        color: effectiveColor,
        fontWeight: fontWeight,
        height: height,
      ),
      textAlign: textAlign,
    );
  }

  Widget _buildMath(String expression, BuildContext context, TextStyle? baseStyle, Color effectiveColor) {
    try {
      final fontSize = baseStyle?.fontSize ?? 16.0;
      return Math.tex(
        expression,
        mathStyle: MathStyle.text,
        textStyle: TextStyle(
          color: effectiveColor,
          fontSize: fontSize,
        ),
      );
    } catch (e) {
      // Fallback to regular text if LaTeX parsing fails
      return Text(
        '\$$expression\$',
        style: baseStyle?.copyWith(
          color: effectiveColor,
          fontWeight: fontWeight,
          height: height,
          fontFamily: 'monospace',
        ),
      );
    }
  }
}