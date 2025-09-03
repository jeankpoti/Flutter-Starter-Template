import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum CardDifficulty {
  easy,
  normal,
  hard,
}

enum ReviewResult {
  again,    // Incorrect/forgot (0)
  hard,     // Correct but difficult (1)
  good,     // Correct with normal effort (2) 
  easy,     // Correct and easy (3)
}

class FlashCard extends Equatable {
  final String id;
  final String userId;
  final String deckId;
  final String front;
  final String back;
  final String? hint;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;
  final int reviewCount;
  final int correctCount;
  final CardDifficulty difficulty;
  final double easeFactor;
  final int interval; // Days until next review
  final bool isActive;

  const FlashCard({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.front,
    required this.back,
    this.hint,
    this.tags = const [],
    required this.createdAt,
    this.lastReviewedAt,
    this.nextReviewAt,
    this.reviewCount = 0,
    this.correctCount = 0,
    this.difficulty = CardDifficulty.normal,
    this.easeFactor = 2.5, // Standard SM-2 algorithm starting value
    this.interval = 1,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'deckId': deckId,
      'front': front,
      'back': back,
      'hint': hint,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastReviewedAt': lastReviewedAt != null ? Timestamp.fromDate(lastReviewedAt!) : null,
      'nextReviewAt': nextReviewAt != null ? Timestamp.fromDate(nextReviewAt!) : null,
      'reviewCount': reviewCount,
      'correctCount': correctCount,
      'difficulty': difficulty.name,
      'easeFactor': easeFactor,
      'interval': interval,
      'isActive': isActive,
    };
  }

  factory FlashCard.fromMap(Map<String, dynamic> map) {
    // Handle legacy data that might not have userId
    String userId = map['userId'] ?? '';
    if (userId.isEmpty) {
      // For legacy cards without userId, we'll need to handle this gracefully
      debugPrint('Warning: FlashCard ${map['id']} missing userId field');
    }
    
    return FlashCard(
      id: map['id'] ?? '',
      userId: userId,
      deckId: map['deckId'] ?? '',
      front: map['front'] ?? '',
      back: map['back'] ?? '',
      hint: map['hint'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastReviewedAt: (map['lastReviewedAt'] as Timestamp?)?.toDate(),
      nextReviewAt: (map['nextReviewAt'] as Timestamp?)?.toDate(),
      reviewCount: map['reviewCount'] ?? 0,
      correctCount: map['correctCount'] ?? 0,
      difficulty: CardDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => CardDifficulty.normal,
      ),
      easeFactor: map['easeFactor']?.toDouble() ?? 2.5,
      interval: map['interval'] ?? 1,
      isActive: map['isActive'] ?? true,
    );
  }

  FlashCard copyWith({
    String? id,
    String? userId,
    String? deckId,
    String? front,
    String? back,
    String? hint,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
    int? reviewCount,
    int? correctCount,
    CardDifficulty? difficulty,
    double? easeFactor,
    int? interval,
    bool? isActive,
  }) {
    return FlashCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
      reviewCount: reviewCount ?? this.reviewCount,
      correctCount: correctCount ?? this.correctCount,
      difficulty: difficulty ?? this.difficulty,
      easeFactor: easeFactor ?? this.easeFactor,
      interval: interval ?? this.interval,
      isActive: isActive ?? this.isActive,
    );
  }

  // Check if card is due for review
  bool get isDue {
    if (nextReviewAt == null) return true;
    return DateTime.now().isAfter(nextReviewAt!);
  }

  // Calculate success rate
  double get successRate {
    if (reviewCount == 0) return 0.0;
    return (correctCount / reviewCount) * 100;
  }

  // Check if card is new (never reviewed)
  bool get isNew {
    return reviewCount == 0;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    deckId,
    front,
    back,
    hint,
    tags,
    createdAt,
    lastReviewedAt,
    nextReviewAt,
    reviewCount,
    correctCount,
    difficulty,
    easeFactor,
    interval,
    isActive,
  ];
}

class FlashCardDeck extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? color;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? lastStudiedAt;
  final int cardCount;
  final int newCardCount;
  final int dueCardCount;
  final bool isPublic;
  final String? sourceType; // 'material', 'quiz', 'manual'
  final String? sourceId;

  const FlashCardDeck({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.color,
    this.tags = const [],
    required this.createdAt,
    this.lastStudiedAt,
    this.cardCount = 0,
    this.newCardCount = 0,
    this.dueCardCount = 0,
    this.isPublic = false,
    this.sourceType,
    this.sourceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'color': color,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastStudiedAt': lastStudiedAt != null ? Timestamp.fromDate(lastStudiedAt!) : null,
      'cardCount': cardCount,
      'newCardCount': newCardCount,
      'dueCardCount': dueCardCount,
      'isPublic': isPublic,
      'sourceType': sourceType,
      'sourceId': sourceId,
    };
  }

  factory FlashCardDeck.fromMap(Map<String, dynamic> map) {
    return FlashCardDeck(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'],
      color: map['color'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastStudiedAt: (map['lastStudiedAt'] as Timestamp?)?.toDate(),
      cardCount: map['cardCount'] ?? 0,
      newCardCount: map['newCardCount'] ?? 0,
      dueCardCount: map['dueCardCount'] ?? 0,
      isPublic: map['isPublic'] ?? false,
      sourceType: map['sourceType'],
      sourceId: map['sourceId'],
    );
  }

  FlashCardDeck copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? color,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? lastStudiedAt,
    int? cardCount,
    int? newCardCount,
    int? dueCardCount,
    bool? isPublic,
    String? sourceType,
    String? sourceId,
  }) {
    return FlashCardDeck(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      color: color ?? this.color,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      cardCount: cardCount ?? this.cardCount,
      newCardCount: newCardCount ?? this.newCardCount,
      dueCardCount: dueCardCount ?? this.dueCardCount,
      isPublic: isPublic ?? this.isPublic,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    description,
    color,
    tags,
    createdAt,
    lastStudiedAt,
    cardCount,
    newCardCount,
    dueCardCount,
    isPublic,
    sourceType,
    sourceId,
  ];
}

class ReviewSession extends Equatable {
  final String id;
  final String userId;
  final String deckId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int cardsReviewed;
  final int correctAnswers;
  final int totalTimeSeconds;
  final Map<String, int> reviewResults; // ReviewResult -> count

  const ReviewSession({
    required this.id,
    required this.userId,
    required this.deckId,
    required this.startedAt,
    this.completedAt,
    this.cardsReviewed = 0,
    this.correctAnswers = 0,
    this.totalTimeSeconds = 0,
    this.reviewResults = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'deckId': deckId,
      'startedAt': Timestamp.fromDate(startedAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cardsReviewed': cardsReviewed,
      'correctAnswers': correctAnswers,
      'totalTimeSeconds': totalTimeSeconds,
      'reviewResults': reviewResults,
    };
  }

  factory ReviewSession.fromMap(Map<String, dynamic> map) {
    return ReviewSession(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      deckId: map['deckId'] ?? '',
      startedAt: (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      cardsReviewed: map['cardsReviewed'] ?? 0,
      correctAnswers: map['correctAnswers'] ?? 0,
      totalTimeSeconds: map['totalTimeSeconds'] ?? 0,
      reviewResults: Map<String, int>.from(map['reviewResults'] ?? {}),
    );
  }

  ReviewSession copyWith({
    String? id,
    String? userId,
    String? deckId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? cardsReviewed,
    int? correctAnswers,
    int? totalTimeSeconds,
    Map<String, int>? reviewResults,
  }) {
    return ReviewSession(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deckId: deckId ?? this.deckId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      totalTimeSeconds: totalTimeSeconds ?? this.totalTimeSeconds,
      reviewResults: reviewResults ?? this.reviewResults,
    );
  }

  // Calculate accuracy percentage
  double get accuracy {
    if (cardsReviewed == 0) return 0.0;
    return (correctAnswers / cardsReviewed) * 100;
  }

  // Check if session is completed
  bool get isCompleted => completedAt != null;

  // Get session duration
  Duration get duration {
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt);
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    deckId,
    startedAt,
    completedAt,
    cardsReviewed,
    correctAnswers,
    totalTimeSeconds,
    reviewResults,
  ];
}