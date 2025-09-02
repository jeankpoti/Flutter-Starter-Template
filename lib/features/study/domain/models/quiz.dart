import 'package:cloud_firestore/cloud_firestore.dart';

enum QuestionType {
  multipleChoice,
  shortAnswer,
  trueFalse,
  fillInTheBlank,
}

enum QuizDifficulty {
  easy,
  medium,
  hard,
}

enum QuizStatus {
  notStarted,
  inProgress,
  completed,
}

class QuizAnswer {
  final String id;
  final String text;
  final bool isCorrect;
  final String? explanation;

  const QuizAnswer({
    required this.id,
    required this.text,
    required this.isCorrect,
    this.explanation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isCorrect': isCorrect,
      'explanation': explanation,
    };
  }

  factory QuizAnswer.fromMap(Map<String, dynamic> map) {
    return QuizAnswer(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      isCorrect: map['isCorrect'] ?? false,
      explanation: map['explanation'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizAnswer && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class QuizQuestion {
  final String id;
  final String questionText;
  final QuestionType type;
  final List<QuizAnswer> answers;
  final String? correctAnswerId;
  final String? explanation;
  final String? hint;
  final List<String> relatedTopics;
  final int pointValue;

  const QuizQuestion({
    required this.id,
    required this.questionText,
    required this.type,
    this.answers = const [],
    this.correctAnswerId,
    this.explanation,
    this.hint,
    this.relatedTopics = const [],
    this.pointValue = 1,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionText': questionText,
      'type': type.name,
      'answers': answers.map((answer) => answer.toMap()).toList(),
      'correctAnswerId': correctAnswerId,
      'explanation': explanation,
      'hint': hint,
      'relatedTopics': relatedTopics,
      'pointValue': pointValue,
    };
  }

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      id: map['id'] ?? '',
      questionText: map['questionText'] ?? '',
      type: QuestionType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestionType.multipleChoice,
      ),
      answers: (map['answers'] as List<dynamic>?)
              ?.map((answerMap) => QuizAnswer.fromMap(answerMap))
              .toList() ??
          [],
      correctAnswerId: map['correctAnswerId'],
      explanation: map['explanation'],
      hint: map['hint'],
      relatedTopics: List<String>.from(map['relatedTopics'] ?? []),
      pointValue: map['pointValue'] ?? 1,
    );
  }

  QuizAnswer? get correctAnswer {
    if (correctAnswerId == null) return null;
    try {
      return answers.firstWhere((answer) => answer.id == correctAnswerId);
    } catch (e) {
      return null;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is QuizQuestion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class UserQuizAnswer {
  final String questionId;
  final String? selectedAnswerId;
  final String? textAnswer;
  final bool isCorrect;
  final DateTime answeredAt;

  const UserQuizAnswer({
    required this.questionId,
    this.selectedAnswerId,
    this.textAnswer,
    required this.isCorrect,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'selectedAnswerId': selectedAnswerId,
      'textAnswer': textAnswer,
      'isCorrect': isCorrect,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }

  factory UserQuizAnswer.fromMap(Map<String, dynamic> map) {
    return UserQuizAnswer(
      questionId: map['questionId'] ?? '',
      selectedAnswerId: map['selectedAnswerId'],
      textAnswer: map['textAnswer'],
      isCorrect: map['isCorrect'] ?? false,
      answeredAt: (map['answeredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class Quiz {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> studyMaterialIds;
  final List<String> studyTopicIds;
  final List<QuizQuestion> questions;
  final QuizDifficulty difficulty;
  final int totalPoints;
  final int timeLimit; // in minutes, 0 means no time limit
  final DateTime createdAt;
  final DateTime? lastAttemptAt;
  final QuizStatus status;
  final List<UserQuizAnswer> userAnswers;
  final double? lastScore; // percentage score (0-100)
  final int attemptCount;
  final String? aiRecommendations;

  const Quiz({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.studyMaterialIds = const [],
    this.studyTopicIds = const [],
    this.questions = const [],
    required this.difficulty,
    this.totalPoints = 0,
    this.timeLimit = 0,
    required this.createdAt,
    this.lastAttemptAt,
    this.status = QuizStatus.notStarted,
    this.userAnswers = const [],
    this.lastScore,
    this.attemptCount = 0,
    this.aiRecommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'studyMaterialIds': studyMaterialIds,
      'studyTopicIds': studyTopicIds,
      'questions': questions.map((q) => q.toMap()).toList(),
      'difficulty': difficulty.name,
      'totalPoints': totalPoints,
      'timeLimit': timeLimit,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastAttemptAt': lastAttemptAt != null ? Timestamp.fromDate(lastAttemptAt!) : null,
      'status': status.name,
      'userAnswers': userAnswers.map((ua) => ua.toMap()).toList(),
      'lastScore': lastScore,
      'attemptCount': attemptCount,
      'aiRecommendations': aiRecommendations,
    };
  }

  factory Quiz.fromMap(Map<String, dynamic> map) {
    return Quiz(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      studyMaterialIds: List<String>.from(map['studyMaterialIds'] ?? []),
      studyTopicIds: List<String>.from(map['studyTopicIds'] ?? []),
      questions: (map['questions'] as List<dynamic>?)
              ?.map((qMap) => QuizQuestion.fromMap(qMap))
              .toList() ??
          [],
      difficulty: QuizDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuizDifficulty.medium,
      ),
      totalPoints: map['totalPoints'] ?? 0,
      timeLimit: map['timeLimit'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastAttemptAt: (map['lastAttemptAt'] as Timestamp?)?.toDate(),
      status: QuizStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => QuizStatus.notStarted,
      ),
      userAnswers: (map['userAnswers'] as List<dynamic>?)
              ?.map((uaMap) => UserQuizAnswer.fromMap(uaMap))
              .toList() ??
          [],
      lastScore: map['lastScore']?.toDouble(),
      attemptCount: map['attemptCount'] ?? 0,
      aiRecommendations: map['aiRecommendations'],
    );
  }

  Quiz copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? studyMaterialIds,
    List<String>? studyTopicIds,
    List<QuizQuestion>? questions,
    QuizDifficulty? difficulty,
    int? totalPoints,
    int? timeLimit,
    DateTime? createdAt,
    DateTime? lastAttemptAt,
    QuizStatus? status,
    List<UserQuizAnswer>? userAnswers,
    double? lastScore,
    int? attemptCount,
    String? aiRecommendations,
  }) {
    return Quiz(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      studyMaterialIds: studyMaterialIds ?? this.studyMaterialIds,
      studyTopicIds: studyTopicIds ?? this.studyTopicIds,
      questions: questions ?? this.questions,
      difficulty: difficulty ?? this.difficulty,
      totalPoints: totalPoints ?? this.totalPoints,
      timeLimit: timeLimit ?? this.timeLimit,
      createdAt: createdAt ?? this.createdAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      status: status ?? this.status,
      userAnswers: userAnswers ?? this.userAnswers,
      lastScore: lastScore ?? this.lastScore,
      attemptCount: attemptCount ?? this.attemptCount,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }

  // Calculate current score based on user answers
  double calculateScore() {
    if (questions.isEmpty || userAnswers.isEmpty) return 0.0;
    
    int correctAnswers = userAnswers.where((ua) => ua.isCorrect).length;
    return (correctAnswers / questions.length) * 100;
  }

  // Get unanswered questions
  List<QuizQuestion> getUnansweredQuestions() {
    final answeredQuestions = userAnswers
        .where((ua) => ua.selectedAnswerId != null || (ua.textAnswer != null && ua.textAnswer!.trim().isNotEmpty))
        .toList();
    final answeredQuestionIds = answeredQuestions.map((ua) => ua.questionId).toSet();
    return questions.where((q) => !answeredQuestionIds.contains(q.id)).toList();
  }

  // Check if quiz is completed
  bool get isCompleted {
    final answeredQuestions = userAnswers
        .where((ua) => ua.selectedAnswerId != null || (ua.textAnswer != null && ua.textAnswer!.trim().isNotEmpty))
        .toList();
    return answeredQuestions.length == questions.length;
  }

  // Get performance summary
  Map<String, int> getPerformanceSummary() {
    final correct = userAnswers.where((ua) => ua.isCorrect).length;
    
    // Only count answers that were actually provided (not skipped)
    final answeredQuestions = userAnswers
        .where((ua) => ua.selectedAnswerId != null || (ua.textAnswer != null && ua.textAnswer!.trim().isNotEmpty))
        .toList();
    
    final incorrect = answeredQuestions.where((ua) => !ua.isCorrect).length;
    final unanswered = questions.length - answeredQuestions.length;
    
    return {
      'correct': correct,
      'incorrect': incorrect,
      'unanswered': unanswered,
      'total': questions.length,
    };
  }

  @override
  String toString() {
    return 'Quiz(id: $id, title: $title, questions: ${questions.length}, score: ${lastScore?.toStringAsFixed(1)}%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quiz && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}