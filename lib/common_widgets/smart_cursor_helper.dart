import 'package:flutter/material.dart';

class SmartCursorHelper {
  static const Map<String, CursorPlacement> _cursorPlacements = {
    r'$\sqrt{}$': CursorPlacement(7, 0), // Inside the braces
    r'$\frac{}{}$': CursorPlacement(7, 0), // First numerator position
    r'$\sqrt[3]{}$': CursorPlacement(10, 0), // Inside the braces after [3]
    r'$\sqrt[n]{}$': CursorPlacement(9, 0), // Replace 'n' first
    r'$x^2$': CursorPlacement(4, 0), // After the 2
    r'$x^3$': CursorPlacement(4, 0), // After the 3
    r'$x^n$': CursorPlacement(3, 1), // Select 'n' to replace
    r'$\sin()$': CursorPlacement(6, 0), // Inside parentheses
    r'$\cos()$': CursorPlacement(6, 0), // Inside parentheses
    r'$\tan()$': CursorPlacement(6, 0), // Inside parentheses
    r'$\log()$': CursorPlacement(6, 0), // Inside parentheses
    r'$\ln()$': CursorPlacement(5, 0), // Inside parentheses
    r'$\int_{a}^{b} f(x) \, dx$': CursorPlacement(7, 1), // Select 'a' first
    r'$\lim_{x \to a} f(x)$': CursorPlacement(13, 1), // Select 'a' first
    r'$\sum_{i=1}^{n} a_i$': CursorPlacement(11, 1), // Select 'n' first
    r'$\prod_{i=1}^{n} a_i$': CursorPlacement(12, 1), // Select 'n' first
    r'$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$': CursorPlacement(18, 1), // Select first 'a'
    r'$\begin{cases} equation_1 \\ equation_2 \end{cases}$': CursorPlacement(16, 11), // Select 'equation_1'
    r'$\frac{d}{dx} f(x)$': CursorPlacement(15, 4), // Select 'f(x)'
    r'$\frac{\partial}{\partial x} f(x)$': CursorPlacement(27, 4), // Select 'f(x)'
  };

  static TextSelection getSmartCursorPosition(String insertedText, int insertionPoint) {
    final placement = _cursorPlacements[insertedText];
    if (placement != null) {
      final start = insertionPoint + placement.offset;
      final end = start + placement.selectionLength;
      
      if (placement.selectionLength > 0) {
        // Select text for replacement
        return TextSelection(baseOffset: start, extentOffset: end);
      } else {
        // Just position cursor
        return TextSelection.collapsed(offset: start);
      }
    }
    
    // Default: position at end of inserted text
    return TextSelection.collapsed(offset: insertionPoint + insertedText.length);
  }

  static List<CursorJumpPoint> findCursorJumpPoints(String text) {
    final jumpPoints = <CursorJumpPoint>[];
    
    // Find placeholders and empty braces
    final patterns = [
      RegExp(r'\{\}'), // Empty braces
      RegExp(r'\([^)]*\)'), // Parentheses content
      RegExp(r'_\{[^}]*\}'), // Subscript content
      RegExp(r'\^\{[^}]*\}'), // Superscript content
      RegExp(r'\\[a-zA-Z]+\{[^}]*\}'), // Function arguments
    ];
    
    for (final pattern in patterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        if (match.group(0) == '{}') {
          // Empty braces - position inside
          jumpPoints.add(CursorJumpPoint(
            position: match.start + 1,
            type: CursorJumpType.placeholder,
            description: 'Fill in value',
          ));
        } else {
          // Content to potentially replace
          jumpPoints.add(CursorJumpPoint(
            position: match.start,
            selectionEnd: match.end,
            type: CursorJumpType.replaceable,
            description: 'Replace ${match.group(0)}',
          ));
        }
      }
    }
    
    // Sort by position
    jumpPoints.sort((a, b) => a.position.compareTo(b.position));
    
    return jumpPoints;
  }

  static TextSelection? getNextCursorPosition(String text, int currentPosition) {
    final jumpPoints = findCursorJumpPoints(text);
    
    // Find the next jump point after current position
    for (final point in jumpPoints) {
      if (point.position > currentPosition) {
        if (point.selectionEnd != null) {
          return TextSelection(
            baseOffset: point.position,
            extentOffset: point.selectionEnd!,
          );
        } else {
          return TextSelection.collapsed(offset: point.position);
        }
      }
    }
    
    // If no next point, go to the first one (wrap around)
    if (jumpPoints.isNotEmpty) {
      final firstPoint = jumpPoints.first;
      if (firstPoint.selectionEnd != null) {
        return TextSelection(
          baseOffset: firstPoint.position,
          extentOffset: firstPoint.selectionEnd!,
        );
      } else {
        return TextSelection.collapsed(offset: firstPoint.position);
      }
    }
    
    return null;
  }

  static TextSelection? getPreviousCursorPosition(String text, int currentPosition) {
    final jumpPoints = findCursorJumpPoints(text);
    
    // Find the previous jump point before current position
    for (int i = jumpPoints.length - 1; i >= 0; i--) {
      final point = jumpPoints[i];
      if (point.position < currentPosition) {
        if (point.selectionEnd != null) {
          return TextSelection(
            baseOffset: point.position,
            extentOffset: point.selectionEnd!,
          );
        } else {
          return TextSelection.collapsed(offset: point.position);
        }
      }
    }
    
    // If no previous point, go to the last one (wrap around)
    if (jumpPoints.isNotEmpty) {
      final lastPoint = jumpPoints.last;
      if (lastPoint.selectionEnd != null) {
        return TextSelection(
          baseOffset: lastPoint.position,
          extentOffset: lastPoint.selectionEnd!,
        );
      } else {
        return TextSelection.collapsed(offset: lastPoint.position);
      }
    }
    
    return null;
  }

  static bool isInsideLatexExpression(String text, int position) {
    // Count dollar signs before the position
    int dollarCount = 0;
    for (int i = 0; i < position && i < text.length; i++) {
      if (text[i] == '\$') {
        dollarCount++;
      }
    }
    
    // If odd number of dollar signs, we're inside a LaTeX expression
    return dollarCount % 2 == 1;
  }

  static String getLatexExpressionAtPosition(String text, int position) {
    if (!isInsideLatexExpression(text, position)) {
      return '';
    }
    
    // Find the opening dollar sign
    int start = position;
    while (start > 0 && text[start - 1] != '\$') {
      start--;
    }
    
    // Find the closing dollar sign
    int end = position;
    while (end < text.length && text[end] != '\$') {
      end++;
    }
    
    if (start > 0 && end < text.length) {
      return text.substring(start - 1, end + 1);
    }
    
    return '';
  }
}

class CursorPlacement {
  final int offset;
  final int selectionLength;
  
  const CursorPlacement(this.offset, this.selectionLength);
}

class CursorJumpPoint {
  final int position;
  final int? selectionEnd;
  final CursorJumpType type;
  final String description;
  
  const CursorJumpPoint({
    required this.position,
    this.selectionEnd,
    required this.type,
    required this.description,
  });
}

enum CursorJumpType {
  placeholder,
  replaceable,
  argument,
}