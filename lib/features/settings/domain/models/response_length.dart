enum ResponseLength {
  short('Short', 'Quick explanations', 512),
  medium('Medium', 'Balanced explanations', 1024),
  long('Long', 'Detailed explanations', 2048);

  const ResponseLength(this.displayName, this.description, this.maxTokens);

  final String displayName;
  final String description;
  final int maxTokens;

  static ResponseLength fromString(String value) {
    return ResponseLength.values.firstWhere(
      (length) => length.name == value,
      orElse: () => ResponseLength.short, // Default to short
    );
  }

  String toPromptContext() {
    switch (this) {
      case ResponseLength.short:
        return '''Keep explanations concise and focused:
- Provide the essential steps without excessive detail
- Focus on the key mathematical concepts
- Use brief, clear explanations for each step
- Aim for efficiency while maintaining clarity''';

      case ResponseLength.medium:
        return '''Provide balanced explanations:
- Include sufficient detail for understanding
- Explain key steps with moderate depth
- Add helpful context where needed
- Balance clarity with completeness''';

      case ResponseLength.long:
        return '''Provide comprehensive explanations:
- Include detailed step-by-step breakdowns
- Explain the reasoning behind each step thoroughly
- Add context, examples, and additional insights
- Provide extensive mathematical details and connections''';
    }
  }
}