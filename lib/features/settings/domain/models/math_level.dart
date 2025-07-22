enum MathLevel {
  elementary('Elementary', 'Ages 6-11', 'Simple explanations with easy words'),
  highSchool('High School', 'Ages 14-18', 'Standard mathematical explanations'),
  college('College', 'Ages 18+', 'Advanced mathematical concepts');

  const MathLevel(this.displayName, this.ageRange, this.description);

  final String displayName;
  final String ageRange;
  final String description;

  static MathLevel fromString(String value) {
    return MathLevel.values.firstWhere(
      (level) => level.name == value,
      orElse: () => MathLevel.highSchool, // Default to high school
    );
  }

  String toPromptContext() {
    switch (this) {
      case MathLevel.elementary:
        return '''Explain like I'm in elementary school:
- Use very simple words and short sentences
- Show each step clearly with basic explanations
- Use analogies with everyday objects (like toys, food, animals)
- Keep explanations short and encouraging
- Avoid complex mathematical terms
- Use phrases like "Let's think of this as..." or "Imagine you have..."''';

      case MathLevel.highSchool:
        return '''Explain for high school level:
- Use proper mathematical terminology
- Show detailed step-by-step solutions
- Explain the reasoning behind each step
- Include relevant formulas and their applications
- Use standard mathematical language''';

      case MathLevel.college:
        return '''Provide comprehensive college-level explanation:
- Use advanced mathematical language and notation
- Show rigorous step-by-step solutions with mathematical justification
- Include relevant theorems, principles, and proofs when applicable
- Reference mathematical concepts and their relationships
- Provide deeper insight into the mathematical reasoning''';
    }
  }
}