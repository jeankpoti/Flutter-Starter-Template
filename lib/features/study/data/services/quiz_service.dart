import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../solve_math/data/repository/gemini_solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import '../../domain/models/quiz.dart';
import '../../domain/models/study_material.dart';
import '../../domain/models/study_plan.dart';
import '../repository/quiz_repository.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  late final GeminiSolveMathRepo _geminiService;
  late final QuizRepository _quizRepository;
  final Random _random = Random();

  factory QuizService() {
    return _instance;
  }

  QuizService._internal();

  Future<void> initialize() async {
    _geminiService = GeminiSolveMathRepo();
    _quizRepository = QuizRepository();
    await _geminiService.initialize();
  }

  /// Generate a quiz from study materials
  Future<Quiz> generateQuizFromMaterials({
    required List<StudyMaterial> materials,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    int questionCount = 10,
    int timeLimit = 30, // minutes
    String? customTitle,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();

    // Combine material content for AI analysis
    final combinedContent = _combineMaterialsContent(materials);
    
    // Generate questions using AI
    final questions = await _generateQuestionsFromContent(
      content: combinedContent,
      mathLevel: mathLevel,
      difficulty: difficulty,
      questionCount: questionCount,
    );

    final quiz = Quiz(
      id: _generateId(),
      userId: userId,
      title: customTitle ?? _generateQuizTitle(materials),
      description: 'AI-generated quiz based on your study materials',
      studyMaterialIds: materials.map((m) => m.id).toList(),
      questions: questions,
      difficulty: difficulty,
      totalPoints: questions.fold<int>(0, (sum, q) => sum + q.pointValue),
      timeLimit: timeLimit,
      createdAt: DateTime.now(),
    );

    return quiz;
  }

  /// Generate a quiz from study plan topics
  Future<Quiz> generateQuizFromStudyPlan({
    required StudyPlan studyPlan,
    List<StudyTopic>? specificTopics,
    QuizDifficulty difficulty = QuizDifficulty.medium,
    int questionCount = 10,
    int timeLimit = 30,
    String? customTitle,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();

    // Use specific topics or all topics from study plan
    final topicsToUse = specificTopics ?? studyPlan.topics;
    
    // Generate questions from topics
    final questions = await _generateQuestionsFromTopics(
      topics: topicsToUse,
      mathLevel: mathLevel,
      difficulty: difficulty,
      questionCount: questionCount,
    );

    final quiz = Quiz(
      id: _generateId(),
      userId: userId,
      title: customTitle ?? 'Quiz: ${studyPlan.title}',
      description: 'Practice quiz for ${studyPlan.title}',
      studyTopicIds: topicsToUse.map((t) => t.id).toList(),
      questions: questions,
      difficulty: difficulty,
      totalPoints: questions.fold<int>(0, (sum, q) => sum + q.pointValue),
      timeLimit: timeLimit,
      createdAt: DateTime.now(),
    );

    return quiz;
  }

  /// Generate questions from material content
  Future<List<QuizQuestion>> _generateQuestionsFromContent({
    required String content,
    required MathLevel mathLevel,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    final prompt = '''
You are an expert math teacher creating quiz questions. Based on the study material below, create exactly $questionCount quiz questions.

STUDY MATERIAL:
$content

REQUIREMENTS:
- Student Level: ${mathLevel.displayName}
- Difficulty: ${difficulty.name}
- Create a mix of question types: multiple choice, short answer, true/false, and fill-in-the-blank
- Questions should test understanding, not just memorization
- Include clear explanations for each answer
- Make questions progressively challenging

Format each question EXACTLY like this:

QUESTION 1:
Type: multiple_choice
Text: [Question text here]
Options:
A) [Option A]
B) [Option B] 
C) [Option C]
D) [Option D]
Correct: A
Explanation: [Why this answer is correct]
Topics: [Topic1, Topic2]
Points: 1

QUESTION 2:
Type: short_answer
Text: [Question text here]
Correct: [Expected answer]
Explanation: [Explanation of the solution]
Topics: [Topic1, Topic2]
Points: 2

QUESTION 3:
Type: true_false
Text: [Statement to evaluate]
Correct: true
Explanation: [Why this is true/false]
Topics: [Topic1]
Points: 1

QUESTION 4:
Type: fill_in_blank
Text: The formula for area of a circle is _____.
Correct: πr²
Explanation: [Explanation]
Topics: [Topic1]
Points: 1

Continue this pattern for all $questionCount questions. Ensure variety in question types and topics covered.
''';

    final response = await _geminiService.generateTextContent(prompt);
    final questionText = response.text ?? '';
    
    return _parseQuestionsFromAIResponse(questionText);
  }

  /// Generate questions from study topics
  Future<List<QuizQuestion>> _generateQuestionsFromTopics({
    required List<StudyTopic> topics,
    required MathLevel mathLevel,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    final topicsContent = _combineTopicsContent(topics);
    
    return _generateQuestionsFromContent(
      content: topicsContent,
      mathLevel: mathLevel,
      difficulty: difficulty,
      questionCount: questionCount,
    );
  }

  /// Parse AI response into quiz questions
  List<QuizQuestion> _parseQuestionsFromAIResponse(String response) {
    final questions = <QuizQuestion>[];
    final questionBlocks = response.split(RegExp(r'QUESTION \d+:'));
    
    for (int i = 1; i < questionBlocks.length; i++) {
      final block = questionBlocks[i].trim();
      if (block.isEmpty) continue;
      
      try {
        final question = _parseQuestionBlock(block, i);
        if (question != null) {
          questions.add(question);
        }
      } catch (e) {
        debugPrint('Error parsing question block $i: $e');
      }
    }
    
    return questions;
  }

  /// Parse individual question block
  QuizQuestion? _parseQuestionBlock(String block, int questionNumber) {
    final lines = block.split('\n').map((line) => line.trim()).where((line) => line.isNotEmpty).toList();
    
    QuestionType? type;
    String questionText = '';
    List<QuizAnswer> answers = [];
    String? correctAnswerId;
    String? explanation;
    List<String> topics = [];
    int points = 1;
    
    String? correctAnswer;
    List<String> options = [];
    
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      if (line.startsWith('Type:')) {
        final typeStr = line.replaceFirst('Type:', '').trim();
        type = _parseQuestionType(typeStr);
      } else if (line.startsWith('Text:')) {
        questionText = line.replaceFirst('Text:', '').trim();
      } else if (line.startsWith('Options:')) {
        // Parse multiple choice options
        for (int j = i + 1; j < lines.length; j++) {
          final optionLine = lines[j];
          if (RegExp(r'^[A-D]\)').hasMatch(optionLine)) {
            options.add(optionLine.substring(2).trim());
          } else {
            break;
          }
        }
      } else if (line.startsWith('Correct:')) {
        correctAnswer = line.replaceFirst('Correct:', '').trim();
      } else if (line.startsWith('Explanation:')) {
        explanation = line.replaceFirst('Explanation:', '').trim();
      } else if (line.startsWith('Topics:')) {
        final topicsStr = line.replaceFirst('Topics:', '').trim();
        topics = topicsStr.split(',').map((t) => t.trim().replaceAll('[', '').replaceAll(']', '')).toList();
      } else if (line.startsWith('Points:')) {
        points = int.tryParse(line.replaceFirst('Points:', '').trim()) ?? 1;
      }
    }
    
    if (type == null || questionText.isEmpty) {
      return null;
    }
    
    // Create answers based on question type
    switch (type) {
      case QuestionType.multipleChoice:
        answers = _createMultipleChoiceAnswers(options, correctAnswer);
        correctAnswerId = answers.firstWhere((a) => a.isCorrect).id;
        break;
      case QuestionType.shortAnswer:
      case QuestionType.fillInTheBlank:
        correctAnswerId = correctAnswer;
        break;
      case QuestionType.trueFalse:
        answers = _createTrueFalseAnswers(correctAnswer?.toLowerCase() == 'true');
        correctAnswerId = answers.firstWhere((a) => a.isCorrect).id;
        break;
    }
    
    return QuizQuestion(
      id: _generateId(),
      questionText: questionText,
      type: type,
      answers: answers,
      correctAnswerId: correctAnswerId,
      explanation: explanation,
      relatedTopics: topics,
      pointValue: points,
    );
  }

  /// Parse question type from string
  QuestionType _parseQuestionType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'multiple_choice':
        return QuestionType.multipleChoice;
      case 'short_answer':
        return QuestionType.shortAnswer;
      case 'true_false':
        return QuestionType.trueFalse;
      case 'fill_in_blank':
        return QuestionType.fillInTheBlank;
      default:
        return QuestionType.multipleChoice;
    }
  }

  /// Create multiple choice answers
  List<QuizAnswer> _createMultipleChoiceAnswers(List<String> options, String? correctAnswer) {
    final answers = <QuizAnswer>[];
    
    for (int i = 0; i < options.length; i++) {
      final option = options[i];
      final optionLetter = String.fromCharCode(65 + i); // A, B, C, D
      final isCorrect = correctAnswer == optionLetter || correctAnswer == option;
      
      answers.add(QuizAnswer(
        id: _generateId(),
        text: option,
        isCorrect: isCorrect,
      ));
    }
    
    return answers;
  }

  /// Create true/false answers
  List<QuizAnswer> _createTrueFalseAnswers(bool correctIsTrue) {
    return [
      QuizAnswer(
        id: _generateId(),
        text: 'True',
        isCorrect: correctIsTrue,
      ),
      QuizAnswer(
        id: _generateId(),
        text: 'False',
        isCorrect: !correctIsTrue,
      ),
    ];
  }

  /// Submit quiz answer and get feedback
  UserQuizAnswer submitAnswer({
    required String questionId,
    required QuizQuestion question,
    String? selectedAnswerId,
    String? textAnswer,
  }) {
    bool isCorrect = false;
    
    switch (question.type) {
      case QuestionType.multipleChoice:
      case QuestionType.trueFalse:
        isCorrect = selectedAnswerId == question.correctAnswerId;
        break;
      case QuestionType.shortAnswer:
      case QuestionType.fillInTheBlank:
        if (textAnswer != null && question.correctAnswerId != null) {
          isCorrect = _compareTextAnswers(textAnswer, question.correctAnswerId!);
        }
        break;
    }
    
    return UserQuizAnswer(
      questionId: questionId,
      selectedAnswerId: selectedAnswerId,
      textAnswer: textAnswer,
      isCorrect: isCorrect,
      answeredAt: DateTime.now(),
    );
  }

  /// Compare text answers with some tolerance
  bool _compareTextAnswers(String userAnswer, String correctAnswer) {
    final userNormalized = userAnswer.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    final correctNormalized = correctAnswer.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Exact match
    if (userNormalized == correctNormalized) return true;
    
    // Check if user answer contains the correct answer
    if (userNormalized.contains(correctNormalized) || correctNormalized.contains(userNormalized)) {
      return true;
    }
    
    // For math expressions, remove spaces and check
    final userMath = userAnswer.replaceAll(RegExp(r'\s+'), '');
    final correctMath = correctAnswer.replaceAll(RegExp(r'\s+'), '');
    
    return userMath.toLowerCase() == correctMath.toLowerCase();
  }

  /// Helper methods
  String _combineMaterialsContent(List<StudyMaterial> materials) {
    final buffer = StringBuffer();
    
    for (final material in materials) {
      buffer.writeln('Material: ${material.title}');
      if (material.content != null) {
        buffer.writeln('Content: ${material.content}');
      }
      if (material.aiAnalysis != null) {
        buffer.writeln('Analysis: ${material.aiAnalysis}');
      }
      buffer.writeln('Topics: ${material.extractedTopics.join(", ")}');
      buffer.writeln('---');
    }
    
    return buffer.toString();
  }

  String _combineTopicsContent(List<StudyTopic> topics) {
    final buffer = StringBuffer();
    
    for (final topic in topics) {
      buffer.writeln('Topic: ${topic.title}');
      buffer.writeln('Description: ${topic.description}');
      buffer.writeln('Key Concepts: ${topic.keyConceptsList.join(", ")}');
      if (topic.practiceProblems.isNotEmpty) {
        buffer.writeln('Practice Problems: ${topic.practiceProblems.join(", ")}');
      }
      buffer.writeln('---');
    }
    
    return buffer.toString();
  }

  String _generateQuizTitle(List<StudyMaterial> materials) {
    if (materials.length == 1) {
      return 'Quiz: ${materials.first.title}';
    }
    return 'Quiz: ${materials.length} Materials';
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + 
           _random.nextInt(1000).toString();
  }

  /// Save completed quiz to history
  Future<void> saveQuizToHistory(Quiz quiz) async {
    try {
      await _quizRepository.saveQuiz(quiz);
    } catch (e) {
      debugPrint('Error saving quiz to history: $e');
      rethrow;
    }
  }

  /// Update existing quiz (for retakes)
  Future<void> updateQuizInHistory(Quiz quiz) async {
    try {
      await _quizRepository.updateQuiz(quiz);
    } catch (e) {
      debugPrint('Error updating quiz in history: $e');
      rethrow;
    }
  }

  /// Get all quizzes for the current user
  Future<List<Quiz>> getQuizHistory() async {
    try {
      return await _quizRepository.getUserQuizzes();
    } catch (e) {
      debugPrint('Error fetching quiz history: $e');
      return [];
    }
  }

  /// Get quizzes for specific study materials
  Future<List<Quiz>> getQuizzesForMaterials(List<String> materialIds) async {
    try {
      return await _quizRepository.getQuizzesForMaterials(materialIds);
    } catch (e) {
      debugPrint('Error fetching quizzes for materials: $e');
      return [];
    }
  }

  /// Get comprehensive quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      return await _quizRepository.getQuizStatistics();
    } catch (e) {
      debugPrint('Error fetching quiz statistics: $e');
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'totalQuestionsAnswered': 0,
        'totalCorrectAnswers': 0,
        'streakCount': 0,
        'recentActivity': <Map<String, dynamic>>[],
      };
    }
  }

  /// Get performance trends over time
  Future<List<Map<String, dynamic>>> getPerformanceTrends({int days = 30}) async {
    try {
      return await _quizRepository.getPerformanceTrends(days: days);
    } catch (e) {
      debugPrint('Error fetching performance trends: $e');
      return [];
    }
  }

  /// Delete a quiz from history
  Future<void> deleteQuizFromHistory(String quizId) async {
    try {
      await _quizRepository.deleteQuiz(quizId);
    } catch (e) {
      debugPrint('Error deleting quiz from history: $e');
      rethrow;
    }
  }
}