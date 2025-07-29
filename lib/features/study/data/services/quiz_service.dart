import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../solve_math/data/repository/gemini_solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import '../../../solve_math/data/repository/prompt_localizer.dart';
import '../../domain/models/quiz.dart';
import '../../domain/models/study_material.dart';
import '../../domain/models/study_plan.dart';
import '../repository/quiz_repository.dart';

class QuizService {
  static final QuizService _instance = QuizService._internal();
  GeminiSolveMathRepo? _geminiService;
  QuizRepository? _quizRepository;
  final Random _random = Random();

  factory QuizService() {
    return _instance;
  }

  QuizService._internal();

  Future<void> initialize() async {
    // Only assign if not already assigned
    _geminiService ??= GeminiSolveMathRepo();
    _quizRepository ??= QuizRepository();
    
    // Only initialize if not already initialized
    if (!_geminiService!.isInitialized) {
      await _geminiService!.initialize();
    }
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
    final locale = prefs.getLocale();

    // Combine material content for AI analysis
    final combinedContent = _combineMaterialsContent(materials);
    
    // Generate questions using AI
    final questions = await _generateQuestionsFromContent(
      content: combinedContent,
      mathLevel: mathLevel,
      locale: locale,
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
    final locale = prefs.getLocale();

    // Use specific topics or all topics from study plan
    final topicsToUse = specificTopics ?? studyPlan.topics;
    
    // Generate questions from topics
    final questions = await _generateQuestionsFromTopics(
      topics: topicsToUse,
      mathLevel: mathLevel,
      locale: locale,
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
    required String locale,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    final prompt = PromptLocalizer.getQuizGenerationPrompt(
      locale,
      content,
      mathLevel.displayName,
      difficulty.name,
      questionCount,
    );

    final response = await _geminiService!.generateTextContent(prompt);
    final questionText = response.text ?? '';
    
    return _parseQuestionsFromAIResponse(questionText);
  }

  /// Generate questions from study topics
  Future<List<QuizQuestion>> _generateQuestionsFromTopics({
    required List<StudyTopic> topics,
    required MathLevel mathLevel,
    required String locale,
    required QuizDifficulty difficulty,
    required int questionCount,
  }) async {
    final topicsContent = _combineTopicsContent(topics);
    
    return _generateQuestionsFromContent(
      content: topicsContent,
      mathLevel: mathLevel,
      locale: locale,
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

  /// Update quiz with new answer and return updated quiz
  Quiz updateQuizWithAnswer({
    required Quiz quiz,
    required UserQuizAnswer answer,
  }) {
    // Remove any existing answer for this question
    final updatedAnswers = quiz.userAnswers
        .where((ua) => ua.questionId != answer.questionId)
        .toList();
    
    // Add the new answer
    updatedAnswers.add(answer);
    
    // Calculate progress and status
    final isCompleted = updatedAnswers.length == quiz.questions.length;
    final newScore = isCompleted ? _calculateQuizScore(quiz.questions, updatedAnswers) : null;
    final newStatus = isCompleted ? QuizStatus.completed : QuizStatus.inProgress;
    
    return quiz.copyWith(
      userAnswers: updatedAnswers,
      lastScore: newScore,
      status: newStatus,
      lastAttemptAt: isCompleted ? DateTime.now() : quiz.lastAttemptAt,
      attemptCount: isCompleted ? quiz.attemptCount + 1 : quiz.attemptCount,
    );
  }

  /// Calculate quiz score based on correct answers
  double _calculateQuizScore(List<QuizQuestion> questions, List<UserQuizAnswer> answers) {
    if (questions.isEmpty || answers.isEmpty) return 0.0;
    
    int correctAnswers = answers.where((ua) => ua.isCorrect).length;
    return (correctAnswers / questions.length) * 100;
  }

  /// Get detailed question tracking for a quiz
  Map<String, dynamic> getQuestionTracking(Quiz quiz) {
    final answeredQuestionIds = quiz.userAnswers.map((ua) => ua.questionId).toSet();
    final unansweredQuestions = quiz.questions
        .where((q) => !answeredQuestionIds.contains(q.id))
        .toList();
    
    final correctAnswers = quiz.userAnswers.where((ua) => ua.isCorrect).length;
    final incorrectAnswers = quiz.userAnswers.length - correctAnswers;
    
    return {
      'totalQuestions': quiz.questions.length,
      'answeredCount': quiz.userAnswers.length,
      'unansweredCount': unansweredQuestions.length,
      'correctCount': correctAnswers,
      'incorrectCount': incorrectAnswers,
      'completionPercentage': (quiz.userAnswers.length / quiz.questions.length) * 100,
      'accuracyPercentage': quiz.userAnswers.isEmpty ? 0.0 : (correctAnswers / quiz.userAnswers.length) * 100,
      'unansweredQuestions': unansweredQuestions,
      'answeredQuestions': quiz.questions
          .where((q) => answeredQuestionIds.contains(q.id))
          .toList(),
    };
  }

  /// Get performance by question type
  Map<String, dynamic> getQuestionTypePerformance(List<Quiz> quizzes) {
    final typeStats = <QuestionType, Map<String, int>>{};
    
    for (final quiz in quizzes) {
      for (final question in quiz.questions) {
        typeStats[question.type] ??= {'total': 0, 'correct': 0};
        typeStats[question.type]!['total'] = typeStats[question.type]!['total']! + 1;
        
        final userAnswer = quiz.userAnswers
            .where((ua) => ua.questionId == question.id)
            .firstOrNull;
        
        if (userAnswer != null && userAnswer.isCorrect) {
          typeStats[question.type]!['correct'] = typeStats[question.type]!['correct']! + 1;
        }
      }
    }
    
    final performance = <String, dynamic>{};
    for (final entry in typeStats.entries) {
      final total = entry.value['total']!;
      final correct = entry.value['correct']!;
      performance[entry.key.name] = {
        'total': total,
        'correct': correct,
        'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
      };
    }
    
    return performance;
  }

  /// Get topic-based performance analysis
  Map<String, dynamic> getTopicPerformance(List<Quiz> quizzes) {
    final topicStats = <String, Map<String, int>>{};
    
    for (final quiz in quizzes) {
      for (final question in quiz.questions) {
        for (final topic in question.relatedTopics) {
          topicStats[topic] ??= {'total': 0, 'correct': 0};
          topicStats[topic]!['total'] = topicStats[topic]!['total']! + 1;
          
          final userAnswer = quiz.userAnswers
              .where((ua) => ua.questionId == question.id)
              .firstOrNull;
          
          if (userAnswer != null && userAnswer.isCorrect) {
            topicStats[topic]!['correct'] = topicStats[topic]!['correct']! + 1;
          }
        }
      }
    }
    
    final performance = <String, dynamic>{};
    for (final entry in topicStats.entries) {
      final total = entry.value['total']!;
      final correct = entry.value['correct']!;
      performance[entry.key] = {
        'total': total,
        'correct': correct,
        'accuracy': total > 0 ? (correct / total) * 100 : 0.0,
      };
    }
    
    return performance;
  }

  /// Get time-based answering patterns
  Map<String, dynamic> getAnswerTimePatterns(Quiz quiz) {
    if (quiz.userAnswers.length < 2) {
      return {'averageTimePerQuestion': 0, 'timePattern': 'insufficient_data'};
    }
    
    final sortedAnswers = quiz.userAnswers.toList()
      ..sort((a, b) => a.answeredAt.compareTo(b.answeredAt));
    
    final timeDifferences = <Duration>[];
    for (int i = 1; i < sortedAnswers.length; i++) {
      timeDifferences.add(
        sortedAnswers[i].answeredAt.difference(sortedAnswers[i - 1].answeredAt),
      );
    }
    
    final averageTime = timeDifferences.isNotEmpty
        ? timeDifferences.map((d) => d.inSeconds).reduce((a, b) => a + b) / timeDifferences.length
        : 0;
    
    String pattern = 'steady';
    if (timeDifferences.isNotEmpty) {
      final firstHalf = timeDifferences.take(timeDifferences.length ~/ 2);
      final secondHalf = timeDifferences.skip(timeDifferences.length ~/ 2);
      
      final firstAvg = firstHalf.map((d) => d.inSeconds).reduce((a, b) => a + b) / firstHalf.length;
      final secondAvg = secondHalf.map((d) => d.inSeconds).reduce((a, b) => a + b) / secondHalf.length;
      
      if (secondAvg > firstAvg * 1.5) {
        pattern = 'slowing_down';
      } else if (secondAvg < firstAvg * 0.7) {
        pattern = 'speeding_up';
      }
    }
    
    return {
      'averageTimePerQuestion': averageTime,
      'timePattern': pattern,
      'totalTimeSpent': quiz.userAnswers.isNotEmpty && quiz.userAnswers.length > 1
          ? sortedAnswers.last.answeredAt.difference(sortedAnswers.first.answeredAt).inMinutes
          : 0,
    };
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
      await _quizRepository!.saveQuiz(quiz);
    } catch (e) {
      debugPrint('Error saving quiz to history: $e');
      rethrow;
    }
  }

  /// Update existing quiz (for retakes)
  Future<void> updateQuizInHistory(Quiz quiz) async {
    try {
      await _quizRepository!.updateQuiz(quiz);
    } catch (e) {
      debugPrint('Error updating quiz in history: $e');
      rethrow;
    }
  }

  /// Get all quizzes for the current user
  Future<List<Quiz>> getQuizHistory() async {
    try {
      return await _quizRepository!.getUserQuizzes();
    } catch (e) {
      debugPrint('Error fetching quiz history: $e');
      return [];
    }
  }

  /// Get quizzes for specific study materials
  Future<List<Quiz>> getQuizzesForMaterials(List<String> materialIds) async {
    try {
      return await _quizRepository!.getQuizzesForMaterials(materialIds);
    } catch (e) {
      debugPrint('Error fetching quizzes for materials: $e');
      return [];
    }
  }

  /// Get comprehensive quiz statistics
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      return await _quizRepository!.getQuizStatistics();
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
      return await _quizRepository!.getPerformanceTrends(days: days);
    } catch (e) {
      debugPrint('Error fetching performance trends: $e');
      return [];
    }
  }

  /// Delete a quiz from history
  Future<void> deleteQuizFromHistory(String quizId) async {
    try {
      await _quizRepository!.deleteQuiz(quizId);
    } catch (e) {
      debugPrint('Error deleting quiz from history: $e');
      rethrow;
    }
  }

  /// Save quiz progress (answers) without completing the quiz
  Future<void> saveQuizProgress(Quiz quiz) async {
    try {
      await _quizRepository!.updateQuiz(quiz);
      debugPrint('Quiz progress saved: ${quiz.id}');
    } catch (e) {
      debugPrint('Error saving quiz progress: $e');
      rethrow;
    }
  }

  /// Get comprehensive answer tracking summary
  Map<String, dynamic> getAnswerTrackingSummary(List<Quiz> quizzes) {
    int totalQuestions = 0;
    int totalAnswered = 0;
    int totalCorrect = 0;
    int totalIncorrect = 0;
    
    final questionTypeBreakdown = <String, Map<String, int>>{};
    final topicBreakdown = <String, Map<String, int>>{};
    final timePatterns = <String, int>{};
    
    for (final quiz in quizzes) {
      totalQuestions += quiz.questions.length;
      totalAnswered += quiz.userAnswers.length;
      totalCorrect += quiz.userAnswers.where((ua) => ua.isCorrect).length;
      totalIncorrect += quiz.userAnswers.where((ua) => !ua.isCorrect).length;
      
      // Track question type performance
      for (final question in quiz.questions) {
        final type = question.type.name;
        questionTypeBreakdown[type] ??= {'total': 0, 'answered': 0, 'correct': 0};
        questionTypeBreakdown[type]!['total'] = questionTypeBreakdown[type]!['total']! + 1;
        
        final userAnswer = quiz.userAnswers
            .where((ua) => ua.questionId == question.id)
            .firstOrNull;
        
        if (userAnswer != null) {
          questionTypeBreakdown[type]!['answered'] = questionTypeBreakdown[type]!['answered']! + 1;
          if (userAnswer.isCorrect) {
            questionTypeBreakdown[type]!['correct'] = questionTypeBreakdown[type]!['correct']! + 1;
          }
        }
        
        // Track topic performance
        for (final topic in question.relatedTopics) {
          topicBreakdown[topic] ??= {'total': 0, 'answered': 0, 'correct': 0};
          topicBreakdown[topic]!['total'] = topicBreakdown[topic]!['total']! + 1;
          
          if (userAnswer != null) {
            topicBreakdown[topic]!['answered'] = topicBreakdown[topic]!['answered']! + 1;
            if (userAnswer.isCorrect) {
              topicBreakdown[topic]!['correct'] = topicBreakdown[topic]!['correct']! + 1;
            }
          }
        }
      }
      
      // Track time patterns
      final timePattern = getAnswerTimePatterns(quiz)['timePattern'] as String;
      timePatterns[timePattern] = (timePatterns[timePattern] ?? 0) + 1;
    }
    
    return {
      'overall': {
        'totalQuestions': totalQuestions,
        'totalAnswered': totalAnswered,
        'totalCorrect': totalCorrect,
        'totalIncorrect': totalIncorrect,
        'unanswered': totalQuestions - totalAnswered,
        'overallAccuracy': totalAnswered > 0 ? (totalCorrect / totalAnswered) * 100 : 0.0,
        'completionRate': totalQuestions > 0 ? (totalAnswered / totalQuestions) * 100 : 0.0,
      },
      'questionTypeBreakdown': questionTypeBreakdown,
      'topicBreakdown': topicBreakdown,
      'timePatterns': timePatterns,
    };
  }

  /// Get questions that need review (frequently answered incorrectly)
  List<Map<String, dynamic>> getQuestionsNeedingReview(List<Quiz> quizzes, {double threshold = 50.0}) {
    final questionPerformance = <String, Map<String, dynamic>>{};
    
    for (final quiz in quizzes) {
      for (final question in quiz.questions) {
        if (!questionPerformance.containsKey(question.id)) {
          questionPerformance[question.id] = {
            'question': question,
            'totalAttempts': 0,
            'correctAttempts': 0,
            'topics': question.relatedTopics,
            'type': question.type.name,
          };
        }
        
        final userAnswer = quiz.userAnswers
            .where((ua) => ua.questionId == question.id)
            .firstOrNull;
        
        if (userAnswer != null) {
          questionPerformance[question.id]!['totalAttempts']++;
          if (userAnswer.isCorrect) {
            questionPerformance[question.id]!['correctAttempts']++;
          }
        }
      }
    }
    
    final needReview = <Map<String, dynamic>>[];
    
    for (final entry in questionPerformance.entries) {
      final data = entry.value;
      final totalAttempts = data['totalAttempts'] as int;
      final correctAttempts = data['correctAttempts'] as int;
      
      if (totalAttempts > 0) {
        final accuracy = (correctAttempts / totalAttempts) * 100;
        if (accuracy < threshold) {
          needReview.add({
            'questionId': entry.key,
            'question': data['question'],
            'accuracy': accuracy,
            'totalAttempts': totalAttempts,
            'correctAttempts': correctAttempts,
            'topics': data['topics'],
            'type': data['type'],
          });
        }
      }
    }
    
    // Sort by worst performance first
    needReview.sort((a, b) => (a['accuracy'] as double).compareTo(b['accuracy'] as double));
    
    return needReview;
  }

  /// Get learning progress insights
  Map<String, dynamic> getLearningInsights(List<Quiz> quizzes) {
    if (quizzes.isEmpty) {
      return {
        'strongTopics': <String>[],
        'weakTopics': <String>[],
        'improvingTopics': <String>[],
        'strugglingTopics': <String>[],
        'recommendations': <String>[],
      };
    }
    
    final topicPerformance = getTopicPerformance(quizzes);
    final strongTopics = <String>[];
    final weakTopics = <String>[];
    
    for (final entry in topicPerformance.entries) {
      final accuracy = entry.value['accuracy'] as double;
      if (accuracy >= 80) {
        strongTopics.add(entry.key);
      } else if (accuracy < 60) {
        weakTopics.add(entry.key);
      }
    }
    
    // Analyze trends (compare recent vs older performance)
    final recentQuizzes = quizzes.take(quizzes.length ~/ 2).toList();
    final olderQuizzes = quizzes.skip(quizzes.length ~/ 2).toList();
    
    final recentTopicPerformance = getTopicPerformance(recentQuizzes);
    final olderTopicPerformance = getTopicPerformance(olderQuizzes);
    
    final improvingTopics = <String>[];
    final strugglingTopics = <String>[];
    
    for (final topic in recentTopicPerformance.keys) {
      if (olderTopicPerformance.containsKey(topic)) {
        final recentAccuracy = recentTopicPerformance[topic]!['accuracy'] as double;
        final olderAccuracy = olderTopicPerformance[topic]!['accuracy'] as double;
        
        if (recentAccuracy > olderAccuracy + 10) {
          improvingTopics.add(topic);
        } else if (recentAccuracy < olderAccuracy - 10) {
          strugglingTopics.add(topic);
        }
      }
    }
    
    // Generate recommendations
    final recommendations = <String>[];
    if (weakTopics.isNotEmpty) {
      recommendations.add('Focus on reviewing ${weakTopics.take(3).join(", ")} concepts');
    }
    if (strugglingTopics.isNotEmpty) {
      recommendations.add('Practice more ${strugglingTopics.take(2).join(" and ")} problems');
    }
    if (strongTopics.isNotEmpty) {
      recommendations.add('Great work on ${strongTopics.take(2).join(" and ")}! Keep it up');
    }
    
    return {
      'strongTopics': strongTopics,
      'weakTopics': weakTopics,
      'improvingTopics': improvingTopics,
      'strugglingTopics': strugglingTopics,
      'recommendations': recommendations,
    };
  }
}