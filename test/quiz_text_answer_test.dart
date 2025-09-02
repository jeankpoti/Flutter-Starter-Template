import 'package:flutter_test/flutter_test.dart';
import 'package:math_ai/features/study/domain/models/quiz.dart';
import 'package:math_ai/features/study/data/services/quiz_service.dart';

void main() {
  group('Quiz Text Answer Handling', () {
    late QuizService quizService;
    
    setUp(() {
      quizService = QuizService();
    });

    test('should handle empty text answers correctly in performance summary', () {
      // Create test questions
      final questions = [
        QuizQuestion(
          id: 'q1',
          questionText: 'What is 2+2?',
          type: QuestionType.shortAnswer,
          correctAnswerId: '4',
        ),
        QuizQuestion(
          id: 'q2',
          questionText: 'What is 3+3?',
          type: QuestionType.fillInTheBlank,
          correctAnswerId: '6',
        ),
        QuizQuestion(
          id: 'q3',
          questionText: 'True or false: 5>3?',
          type: QuestionType.trueFalse,
          answers: [
            QuizAnswer(id: 'true', text: 'True', isCorrect: true),
            QuizAnswer(id: 'false', text: 'False', isCorrect: false),
          ],
          correctAnswerId: 'true',
        ),
      ];

      // Create user answers - one empty text, one filled text, one selected
      final userAnswers = [
        UserQuizAnswer(
          questionId: 'q1',
          textAnswer: '', // Empty text answer
          isCorrect: false,
          answeredAt: DateTime.now(),
        ),
        UserQuizAnswer(
          questionId: 'q2',
          textAnswer: '6', // Valid text answer
          isCorrect: true,
          answeredAt: DateTime.now(),
        ),
        UserQuizAnswer(
          questionId: 'q3',
          selectedAnswerId: 'true', // Selected answer
          isCorrect: true,
          answeredAt: DateTime.now(),
        ),
      ];

      final quiz = Quiz(
        id: 'test-quiz',
        userId: 'test-user',
        title: 'Test Quiz',
        description: 'Testing text answer handling',
        questions: questions,
        difficulty: QuizDifficulty.medium,
        createdAt: DateTime.now(),
        userAnswers: userAnswers,
      );

      final summary = quiz.getPerformanceSummary();
      
      // Empty text answer should be counted as unanswered
      expect(summary['correct'], equals(2)); // q2 and q3 are correct
      expect(summary['incorrect'], equals(0)); // No incorrect answers
      expect(summary['unanswered'], equals(1)); // q1 has empty text answer
      expect(summary['total'], equals(3));
    });

    test('should handle whitespace-only text answers as unanswered', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'What is the capital of France?',
        type: QuestionType.shortAnswer,
        correctAnswerId: 'Paris',
      );

      final userAnswer = UserQuizAnswer(
        questionId: 'q1',
        textAnswer: '   ', // Whitespace-only answer
        isCorrect: false,
        answeredAt: DateTime.now(),
      );

      final quiz = Quiz(
        id: 'test-quiz',
        userId: 'test-user',
        title: 'Test Quiz',
        description: 'Testing whitespace handling',
        questions: [question],
        difficulty: QuizDifficulty.medium,
        createdAt: DateTime.now(),
        userAnswers: [userAnswer],
      );

      final summary = quiz.getPerformanceSummary();
      
      expect(summary['correct'], equals(0));
      expect(summary['incorrect'], equals(0));
      expect(summary['unanswered'], equals(1)); // Whitespace-only should be unanswered
      expect(summary['total'], equals(1));
    });

    test('should correctly identify quiz as incomplete with empty text answers', () {
      final questions = [
        QuizQuestion(
          id: 'q1',
          questionText: 'What is 2+2?',
          type: QuestionType.shortAnswer,
          correctAnswerId: '4',
        ),
        QuizQuestion(
          id: 'q2',
          questionText: 'What is 3+3?',
          type: QuestionType.shortAnswer,
          correctAnswerId: '6',
        ),
      ];

      final userAnswers = [
        UserQuizAnswer(
          questionId: 'q1',
          textAnswer: '', // Empty answer
          isCorrect: false,
          answeredAt: DateTime.now(),
        ),
        UserQuizAnswer(
          questionId: 'q2',
          textAnswer: '6', // Valid answer
          isCorrect: true,
          answeredAt: DateTime.now(),
        ),
      ];

      final quiz = Quiz(
        id: 'test-quiz',
        userId: 'test-user',
        title: 'Test Quiz',
        description: 'Testing completion status',
        questions: questions,
        difficulty: QuizDifficulty.medium,
        createdAt: DateTime.now(),
        userAnswers: userAnswers,
      );

      // Quiz should not be completed since q1 has empty text answer
      expect(quiz.isCompleted, equals(false));
    });

    test('should submit text answer correctly when not empty', () {
      final question = QuizQuestion(
        id: 'q1',
        questionText: 'What is 2+2?',
        type: QuestionType.shortAnswer,
        correctAnswerId: '4',
      );

      // Test valid text answer
      final validAnswer = quizService.submitAnswer(
        questionId: 'q1',
        question: question,
        textAnswer: '4',
      );
      
      expect(validAnswer.isCorrect, equals(true));
      expect(validAnswer.textAnswer, equals('4'));

      // Test empty text answer
      final emptyAnswer = quizService.submitAnswer(
        questionId: 'q1',
        question: question,
        textAnswer: '',
      );
      
      expect(emptyAnswer.isCorrect, equals(false));
      expect(emptyAnswer.textAnswer, equals(''));

      // Test whitespace-only answer
      final whitespaceAnswer = quizService.submitAnswer(
        questionId: 'q1',
        question: question,
        textAnswer: '   ',
      );
      
      expect(whitespaceAnswer.isCorrect, equals(false));
      expect(whitespaceAnswer.textAnswer, equals('   '));
    });
  });
}