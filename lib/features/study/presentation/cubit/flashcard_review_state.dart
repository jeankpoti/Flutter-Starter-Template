part of 'flashcard_review_cubit.dart';

class FlashcardReviewState extends Equatable {
  final List<FlashCard> cards;
  final ReviewSession? currentSession;
  final int currentCardIndex;
  final int sessionCorrectAnswers;
  final Map<String, int> sessionResults;
  final bool isLoading;
  final bool isSuccess;
  final bool isSessionCompleted;
  final String? errorMsg;

  const FlashcardReviewState({
    this.cards = const [],
    this.currentSession,
    this.currentCardIndex = 0,
    this.sessionCorrectAnswers = 0,
    this.sessionResults = const {},
    this.isLoading = false,
    this.isSuccess = false,
    this.isSessionCompleted = false,
    this.errorMsg,
  });

  FlashCard? get currentCard {
    if (currentCardIndex < cards.length) {
      return cards[currentCardIndex];
    }
    return null;
  }

  double get progress {
    if (cards.isEmpty) return 0.0;
    return (currentCardIndex + 1) / cards.length;
  }

  FlashcardReviewState copyWith({
    List<FlashCard>? cards,
    ReviewSession? currentSession,
    int? currentCardIndex,
    int? sessionCorrectAnswers,
    Map<String, int>? sessionResults,
    bool? isLoading,
    bool? isSuccess,
    bool? isSessionCompleted,
    String? errorMsg,
  }) {
    return FlashcardReviewState(
      cards: cards ?? this.cards,
      currentSession: currentSession ?? this.currentSession,
      currentCardIndex: currentCardIndex ?? this.currentCardIndex,
      sessionCorrectAnswers: sessionCorrectAnswers ?? this.sessionCorrectAnswers,
      sessionResults: sessionResults ?? this.sessionResults,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isSessionCompleted: isSessionCompleted ?? this.isSessionCompleted,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [
    cards,
    currentSession,
    currentCardIndex,
    sessionCorrectAnswers,
    sessionResults,
    isLoading,
    isSuccess,
    isSessionCompleted,
    errorMsg,
  ];
}