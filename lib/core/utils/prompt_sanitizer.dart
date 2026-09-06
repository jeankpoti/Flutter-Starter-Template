/// Utility class to sanitize user input before sending to AI prompts.
/// Prevents prompt injection attacks and ensures input safety.
class PromptSanitizer {
  /// Maximum allowed length for math problem input
  static const int maxMathProblemLength = 5000;

  /// Maximum allowed length for study content
  static const int maxStudyContentLength = 50000;

  /// Patterns that could be used for prompt injection
  static final List<RegExp> _injectionPatterns = [
    // Instruction override attempts
    RegExp(r'ignore\s+(all\s+)?(previous|above|prior)\s+instructions?', caseSensitive: false),
    RegExp(r'disregard\s+(all\s+)?(previous|above|prior)\s+instructions?', caseSensitive: false),
    RegExp(r'forget\s+(all\s+)?(previous|above|prior)\s+instructions?', caseSensitive: false),

    // Role manipulation attempts
    RegExp(r'you\s+are\s+now\s+a', caseSensitive: false),
    RegExp(r'pretend\s+(to\s+be|you\s+are)', caseSensitive: false),
    RegExp(r'act\s+as\s+(if\s+you\s+are|a)', caseSensitive: false),
    RegExp(r'roleplay\s+as', caseSensitive: false),

    // System prompt extraction attempts
    RegExp(r'(print|show|display|reveal|tell\s+me)\s+(your\s+)?(system\s+)?(prompt|instructions)', caseSensitive: false),
    RegExp(r'what\s+(are|is)\s+your\s+(system\s+)?(prompt|instructions)', caseSensitive: false),

    // Delimiter injection
    RegExp(r'```\s*system', caseSensitive: false),
    RegExp(r'\[INST\]', caseSensitive: false),
    RegExp(r'\[\/INST\]', caseSensitive: false),
    RegExp(r'<\|system\|>', caseSensitive: false),
    RegExp(r'<\|user\|>', caseSensitive: false),
    RegExp(r'<\|assistant\|>', caseSensitive: false),

    // Output manipulation
    RegExp(r'respond\s+only\s+with', caseSensitive: false),
    RegExp(r'your\s+response\s+must\s+(be|start|begin)', caseSensitive: false),
  ];

  /// Sanitizes math problem input
  /// Returns sanitized string or throws [PromptValidationException] if invalid
  static String sanitizeMathProblem(String input) {
    if (input.isEmpty) {
      throw PromptValidationException('Input cannot be empty');
    }

    // Trim whitespace
    String sanitized = input.trim();

    // Check length
    if (sanitized.length > maxMathProblemLength) {
      throw PromptValidationException(
        'Input exceeds maximum length of $maxMathProblemLength characters',
      );
    }

    // Remove control characters except newlines and tabs
    sanitized = _removeControlCharacters(sanitized);

    // Check for injection patterns
    final injectionMatch = _detectInjectionPatterns(sanitized);
    if (injectionMatch != null) {
      throw PromptValidationException(
        'Input contains invalid content',
      );
    }

    // Escape special characters that could affect prompt structure
    sanitized = _escapePromptDelimiters(sanitized);

    return sanitized;
  }

  /// Sanitizes study content input (more lenient on length)
  static String sanitizeStudyContent(String input) {
    if (input.isEmpty) {
      throw PromptValidationException('Content cannot be empty');
    }

    String sanitized = input.trim();

    if (sanitized.length > maxStudyContentLength) {
      throw PromptValidationException(
        'Content exceeds maximum length of $maxStudyContentLength characters',
      );
    }

    sanitized = _removeControlCharacters(sanitized);

    final injectionMatch = _detectInjectionPatterns(sanitized);
    if (injectionMatch != null) {
      throw PromptValidationException(
        'Content contains invalid patterns',
      );
    }

    sanitized = _escapePromptDelimiters(sanitized);

    return sanitized;
  }

  /// Removes control characters except newlines, tabs, and carriage returns
  static String _removeControlCharacters(String input) {
    final buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      final code = char.codeUnitAt(0);

      // Allow printable ASCII, newline, tab, carriage return, and extended Unicode
      if (code >= 32 || code == 10 || code == 13 || code == 9) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// Detects prompt injection patterns
  /// Returns the matched pattern or null if none found
  static String? _detectInjectionPatterns(String input) {
    for (final pattern in _injectionPatterns) {
      if (pattern.hasMatch(input)) {
        return pattern.pattern;
      }
    }
    return null;
  }

  /// Escapes characters that could be used as prompt delimiters
  static String _escapePromptDelimiters(String input) {
    // Replace sequences that look like role markers
    String escaped = input;

    // Escape triple backticks followed by potential language markers
    escaped = escaped.replaceAll(RegExp(r'```(\s*)(system|user|assistant)', caseSensitive: false),
        '` ` `\$1\$2');

    // Escape angle bracket markers
    escaped = escaped.replaceAll('<|', '< |');
    escaped = escaped.replaceAll('|>', '| >');

    // Escape square bracket instruction markers
    escaped = escaped.replaceAll('[INST]', '[ INST ]');
    escaped = escaped.replaceAll('[/INST]', '[ /INST ]');

    return escaped;
  }

  /// Quick validation check without sanitization
  /// Returns true if input appears safe
  static bool isInputSafe(String input) {
    if (input.isEmpty || input.length > maxMathProblemLength) {
      return false;
    }
    return _detectInjectionPatterns(input) == null;
  }
}

/// Exception thrown when prompt validation fails
class PromptValidationException implements Exception {
  final String message;

  PromptValidationException(this.message);

  @override
  String toString() => 'PromptValidationException: $message';
}
