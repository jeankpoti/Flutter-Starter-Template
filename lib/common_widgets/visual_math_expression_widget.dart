import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class VisualMathExpressionWidget extends StatelessWidget {
  final String expression;
  final double? fontSize;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final TextAlign? textAlign;
  final bool isDisplayStyle;

  const VisualMathExpressionWidget({
    super.key,
    required this.expression,
    this.fontSize,
    this.textColor,
    this.padding,
    this.textAlign,
    this.isDisplayStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(8.0),
      width: double.infinity,
      child: _buildMathExpression(context),
    );
  }

  Widget _buildMathExpression(BuildContext context) {
    // Clean the expression - remove surrounding $ symbols if present
    String cleanExpression = expression.trim();
    if (cleanExpression.startsWith('\$\$') && cleanExpression.endsWith('\$\$')) {
      cleanExpression = cleanExpression.substring(2, cleanExpression.length - 2);
    } else if (cleanExpression.startsWith('\$') && cleanExpression.endsWith('\$')) {
      cleanExpression = cleanExpression.substring(1, cleanExpression.length - 1);
    }

    try {
      final widget = Math.tex(
        cleanExpression,
        textStyle: TextStyle(
          fontSize: fontSize ?? 16.0,
          color: textColor ?? Theme.of(context).colorScheme.onSurface,
        ),
        mathStyle: isDisplayStyle ? MathStyle.display : MathStyle.text,
      );

      return Align(
        alignment: _getAlignment(),
        child: widget,
      );
    } catch (e) {
      // Fallback to regular text if LaTeX parsing fails
      return Align(
        alignment: _getAlignment(),
        child: Text(
          expression,
          style: TextStyle(
            fontSize: fontSize ?? 16.0,
            color: textColor ?? Theme.of(context).colorScheme.onSurface,
            fontFamily: 'monospace',
          ),
          textAlign: textAlign ?? TextAlign.center,
        ),
      );
    }
  }

  Alignment _getAlignment() {
    switch (textAlign) {
      case TextAlign.left:
        return Alignment.centerLeft;
      case TextAlign.right:
        return Alignment.centerRight;
      case TextAlign.center:
      default:
        return Alignment.center;
    }
  }
}