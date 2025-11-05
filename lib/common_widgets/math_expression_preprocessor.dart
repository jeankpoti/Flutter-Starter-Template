
class MathExpressionPreprocessor {
  static const List<String> _commonMistakes = [
    r'$\frac{}{}$',
    r'$\sqrt{}$',
    r'$\int$',
    r'$\sum$',
    r'$\lim$',
  ];

  static const Map<String, String> _latexToText = {
    r'\cdot': '×',
    r'\times': '×',
    r'\div': '÷',
    r'\pm': '±',
    r'\neq': '≠',
    r'\leq': '≤',
    r'\geq': '≥',
    r'\approx': '≈',
    r'\infty': '∞',
    r'\pi': 'π',
    r'\theta': 'θ',
    r'\alpha': 'α',
    r'\beta': 'β',
    r'\gamma': 'γ',
    r'\delta': 'δ',
    r'\lambda': 'λ',
    r'\mu': 'μ',
    r'\sigma': 'σ',
    r'\phi': 'φ',
    r'\psi': 'ψ',
    r'\omega': 'ω',
  };

  static ExpressionValidationResult validateExpression(String expression) {
    final issues = <ValidationIssue>[];
    final suggestions = <String>[];
    
    // Remove leading/trailing whitespace
    expression = expression.trim();
    
    if (expression.isEmpty) {
      return ExpressionValidationResult(
        isValid: false,
        originalExpression: expression,
        processedExpression: expression,
        issues: [ValidationIssue(
          type: ValidationIssueType.empty,
          message: 'Please enter a mathematical expression',
          severity: ValidationSeverity.error,
        )],
        suggestions: ['Try using the keyboard to input mathematical symbols'],
      );
    }

    // Check for common incomplete expressions
    _checkIncompleteExpressions(expression, issues, suggestions);
    
    // Check for balanced parentheses and brackets
    _checkBalancedSymbols(expression, issues, suggestions);
    
    // Check for LaTeX syntax errors
    _checkLatexSyntax(expression, issues, suggestions);
    
    // Check for missing operators
    _checkMissingOperators(expression, issues, suggestions);
    
    // Process and clean the expression
    final processedExpression = _processExpression(expression);
    
    // Add helpful suggestions based on content
    _addContentBasedSuggestions(processedExpression, suggestions);

    final isValid = !issues.any((issue) => issue.severity == ValidationSeverity.error);

    return ExpressionValidationResult(
      isValid: isValid,
      originalExpression: expression,
      processedExpression: processedExpression,
      issues: issues,
      suggestions: suggestions,
    );
  }

  static void _checkIncompleteExpressions(String expression, List<ValidationIssue> issues, List<String> suggestions) {
    for (final mistake in _commonMistakes) {
      if (expression.contains(mistake)) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.incomplete,
          message: 'Incomplete expression detected: $mistake',
          severity: ValidationSeverity.warning,
          position: expression.indexOf(mistake),
        ));
        
        if (mistake.contains(r'\frac')) {
          suggestions.add('Fill in both numerator and denominator for fractions');
        } else if (mistake.contains(r'\sqrt')) {
          suggestions.add('Add the expression inside the square root');
        } else if (mistake.contains(r'\int')) {
          suggestions.add('Specify the function to integrate');
        }
      }
    }
  }

  static void _checkBalancedSymbols(String expression, List<ValidationIssue> issues, List<String> suggestions) {
    final symbols = {
      '(': ')',
      '[': ']',
      '{': '}',
      r'\{': r'\}',
      r'\(': r'\)',
      r'\[': r'\]',
    };

    for (final entry in symbols.entries) {
      final openCount = entry.key.allMatches(expression).length;
      final closeCount = entry.value.allMatches(expression).length;
      
      if (openCount != closeCount) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.unbalanced,
          message: 'Unbalanced ${entry.key}${entry.value} symbols',
          severity: ValidationSeverity.error,
        ));
        
        if (openCount > closeCount) {
          suggestions.add('Add missing ${entry.value} symbols');
        } else {
          suggestions.add('Remove extra ${entry.value} symbols');
        }
      }
    }

    // Check for unmatched dollar signs (LaTeX delimiters)
    final dollarCount = r'$'.allMatches(expression).length;
    if (dollarCount % 2 != 0) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.unbalanced,
        message: 'Unmatched LaTeX delimiter (\$)',
        severity: ValidationSeverity.error,
      ));
      suggestions.add('Ensure all LaTeX expressions are properly enclosed with \$ symbols');
    }
  }

  static void _checkLatexSyntax(String expression, List<ValidationIssue> issues, List<String> suggestions) {
    // Check for common LaTeX syntax errors
    final latexErrors = {
      r'\\': 'Double backslash should be single backslash',
      r'\}': 'Unmatched closing brace',
      r'_{': 'Subscript missing closing brace',
      r'^{': 'Superscript missing closing brace',
    };

    for (final entry in latexErrors.entries) {
      if (expression.contains(entry.key) && !_isValidLatexContext(expression, entry.key)) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.syntax,
          message: entry.value,
          severity: ValidationSeverity.warning,
          position: expression.indexOf(entry.key),
        ));
      }
    }
  }

  static bool _isValidLatexContext(String expression, String pattern) {
    // Basic check for valid LaTeX context
    // This is a simplified check - in a real implementation, you'd want more sophisticated parsing
    return true; // Placeholder for more complex validation
  }

  static void _checkMissingOperators(String expression, List<ValidationIssue> issues, List<String> suggestions) {
    // Check for missing operators between numbers and variables
    final missingOpPattern = RegExp(r'\d[a-zA-Z]|\)[a-zA-Z]|\d\(|[a-zA-Z]\d');
    final matches = missingOpPattern.allMatches(expression);
    
    for (final match in matches) {
      // Skip if it's inside a LaTeX expression
      if (!_isInsideLatex(expression, match.start)) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.missingOperator,
          message: 'Missing operator between ${match.group(0)}',
          severity: ValidationSeverity.warning,
          position: match.start,
        ));
        suggestions.add('Add multiplication operator where needed (e.g., 2x should be 2×x or 2*x)');
      }
    }
  }

  static bool _isInsideLatex(String expression, int position) {
    int dollarCount = 0;
    for (int i = 0; i < position && i < expression.length; i++) {
      if (expression[i] == '\$') {
        dollarCount++;
      }
    }
    return dollarCount % 2 == 1;
  }

  static String _processExpression(String expression) {
    String processed = expression;
    
    // Convert LaTeX symbols to Unicode for better AI understanding
    for (final entry in _latexToText.entries) {
      processed = processed.replaceAll(entry.key, entry.value);
    }
    
    // Clean up extra spaces
    processed = processed.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Convert common notation
    processed = processed.replaceAll('**', '^'); // Power notation
    processed = processed.replaceAll('sqrt(', '√('); // Square root
    
    return processed;
  }

  static void _addContentBasedSuggestions(String expression, List<String> suggestions) {
    // Add suggestions based on the type of math problem
    if (expression.contains('=')) {
      suggestions.add('Solving equations: Clearly state what variable to solve for');
    }
    
    if (expression.contains(RegExp(r'[∫∑∏]')) || expression.contains('integral') || expression.contains('sum')) {
      suggestions.add('Calculus problems: Specify limits of integration or summation clearly');
    }
    
    if (expression.contains(RegExp(r'sin|cos|tan|sec|csc|cot'))) {
      suggestions.add('Trigonometry: Specify if angles are in degrees or radians');
    }
    
    if (expression.contains(RegExp(r'log|ln'))) {
      suggestions.add('Logarithms: Specify the base if different from 10 or e');
    }
    
    if (expression.contains(RegExp(r'\d+x²|\d+x\^2|ax²|ax\^2'))) {
      suggestions.add('Quadratic equations: Use the quadratic formula template for easier solving');
    }
    
    if (expression.contains('derivative') || expression.contains('d/dx')) {
      suggestions.add('Derivatives: Clearly specify the function and variable');
    }
  }

  static String cleanLatexExpression(String expression) {
    // Remove empty LaTeX expressions
    expression = expression.replaceAll(RegExp(r'\$\s*\$'), '');
    
    // Fix common LaTeX issues
    expression = expression.replaceAll(RegExp(r'\$\s*([^$]*?)\s*\$'), r'$$$1$$');
    
    // Remove duplicate dollar signs
    expression = expression.replaceAll(RegExp(r'\$+'), r'$');
    
    return expression.trim();
  }

  static String prepareForAI(String expression) {
    final validationResult = validateExpression(expression);
    
    if (!validationResult.isValid) {
      // Return the original expression with a note about issues
      return '${validationResult.processedExpression}\n\nNote: This expression may have some formatting issues. Please check for completeness.';
    }
    
    String prepared = validationResult.processedExpression;
    
    // Add context for better AI understanding
    if (prepared.contains('=') && !prepared.toLowerCase().contains('solve')) {
      prepared = 'Solve: $prepared';
    }
    
    // Add helpful context for specific problem types
    if (prepared.contains(RegExp(r'∫|integral'))) {
      prepared = 'Evaluate the integral: $prepared';
    } else if (prepared.contains(RegExp(r'lim|limit'))) {
      prepared = 'Evaluate the limit: $prepared';
    } else if (prepared.contains(RegExp(r'd/dx|derivative'))) {
      prepared = 'Find the derivative: $prepared';
    }
    
    return prepared;
  }
}

class ExpressionValidationResult {
  final bool isValid;
  final String originalExpression;
  final String processedExpression;
  final List<ValidationIssue> issues;
  final List<String> suggestions;

  const ExpressionValidationResult({
    required this.isValid,
    required this.originalExpression,
    required this.processedExpression,
    required this.issues,
    required this.suggestions,
  });

  bool get hasWarnings => issues.any((issue) => issue.severity == ValidationSeverity.warning);
  bool get hasErrors => issues.any((issue) => issue.severity == ValidationSeverity.error);
  
  List<ValidationIssue> get errors => issues.where((issue) => issue.severity == ValidationSeverity.error).toList();
  List<ValidationIssue> get warnings => issues.where((issue) => issue.severity == ValidationSeverity.warning).toList();
}

class ValidationIssue {
  final ValidationIssueType type;
  final String message;
  final ValidationSeverity severity;
  final int? position;

  const ValidationIssue({
    required this.type,
    required this.message,
    required this.severity,
    this.position,
  });
}

enum ValidationIssueType {
  empty,
  incomplete,
  unbalanced,
  syntax,
  missingOperator,
  ambiguous,
}

enum ValidationSeverity {
  info,
  warning,
  error,
}