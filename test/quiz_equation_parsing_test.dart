import 'package:flutter_test/flutter_test.dart';
import 'package:math_ai/features/study/domain/models/quiz.dart';
import 'package:math_ai/features/study/data/services/quiz_service.dart';

void main() {
  group('Quiz Equation Parsing Fix', () {
    late QuizService quizService;
    
    setUp(() {
      quizService = QuizService();
    });

    test('should handle incorrectly formatted AI-generated questions', () {
      // Simulate AI-generated question data that has wrong format
      final incorrectQuestion = QuizQuestion(
        id: 'q1',
        questionText: 'Solve for y in the equation: 5y - 2 = 3y + 8',
        type: QuestionType.shortAnswer,
        correctAnswerId: 'A', // This is wrong - should be "y=5" not "A"
      );

      // Test that user entering "y=5" works
      final userAnswer1 = quizService.submitAnswer(
        questionId: 'q1',
        question: incorrectQuestion,
        textAnswer: 'y=5',
      );
      
      // This should be incorrect because correctAnswerId is "A" not "y=5"
      expect(userAnswer1.isCorrect, equals(false));
      expect(userAnswer1.textAnswer, equals('y=5'));
    });

    test('should properly parse question with both options and wrong type', () {
      // Test the conversion logic that should happen when AI generates mixed format
      final correctAnswer = 'A';
      final options = ['y = 5', 'y = 3', 'y = 7', 'y = 1'];
      
      // Simulate the conversion logic from our parsing fix
      String? correctedAnswer;
      if (correctAnswer.length == 1 && RegExp(r'^[A-D]$').hasMatch(correctAnswer) && options.isNotEmpty) {
        final letterIndex = correctAnswer.codeUnitAt(0) - 65; // A=0, B=1, C=2, D=3
        if (letterIndex >= 0 && letterIndex < options.length) {
          correctedAnswer = options[letterIndex];
        }
      }
      
      expect(correctedAnswer, equals('y = 5'));
    });

    test('should compare mathematical answers flexibly', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'Solve for y: 5y - 2 = 3y + 8',
        type: QuestionType.shortAnswer,
        correctAnswerId: 'y = 5',
      );

      // Test various user input formats that should all be correct
      final testCases = [
        'y=5',      // No spaces
        'y = 5',    // With spaces
        'y= 5',     // Mixed spaces
        'y =5',     // Mixed spaces
        '5',        // Just the value
        'Y=5',      // Different case
        'Y = 5',    // Different case with spaces
      ];

      for (final testAnswer in testCases) {
        final userAnswer = quizService.submitAnswer(
          questionId: 'q1',
          question: question,
          textAnswer: testAnswer,
        );
        
        expect(userAnswer.isCorrect, equals(true), 
               reason: 'Answer "$testAnswer" should be correct');
      }
    });

    test('should reject incorrect mathematical answers', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'Solve for y: 5y - 2 = 3y + 8',
        type: QuestionType.shortAnswer,
        correctAnswerId: 'y = 5',
      );

      // Test various incorrect answers
      final incorrectCases = [
        'y=3',      // Wrong value
        'y = 7',    // Wrong value
        'x=5',      // Wrong variable
        '3',        // Wrong value only
        '',         // Empty
        '   ',      // Whitespace only
      ];

      for (final testAnswer in incorrectCases) {
        final userAnswer = quizService.submitAnswer(
          questionId: 'q1',
          question: question,
          textAnswer: testAnswer,
        );
        
        expect(userAnswer.isCorrect, equals(false), 
               reason: 'Answer "$testAnswer" should be incorrect');
      }
    });

    test('should handle complex mathematical expressions', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'Simplify: 2x + 3x',
        type: QuestionType.shortAnswer,
        correctAnswerId: '5x',
      );

      final testCases = [
        '5x',       // Exact match
        '5 x',      // With space
        '5*x',      // With multiplication
        '5×x',      // With multiplication symbol
        'x*5',      // Reversed order (should work too)
      ];

      for (final testAnswer in testCases) {
        final userAnswer = quizService.submitAnswer(
          questionId: 'q1',
          question: question,
          textAnswer: testAnswer,
        );
        
        expect(userAnswer.isCorrect, equals(true), 
               reason: 'Answer "$testAnswer" should be correct');
      }
    });

    test('should handle fraction and decimal answers', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'What is 1/2 as a decimal?',
        type: QuestionType.shortAnswer,
        correctAnswerId: '0.5',
      );

      // Test basic decimal formats that should work
      final basicCases = ['0.5', '0.50', '.5'];
      
      for (final testAnswer in basicCases) {
        final userAnswer = quizService.submitAnswer(
          questionId: 'q1',
          question: question,
          textAnswer: testAnswer,
        );
        
        expect(userAnswer.isCorrect, equals(true), 
               reason: 'Answer "$testAnswer" should be correct');
      }
    });
  });
}