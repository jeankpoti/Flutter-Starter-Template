part of 'flashcard_deck_cubit.dart';

class FlashcardDeckState extends Equatable {
  final List<FlashCard> cards;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMsg;

  const FlashcardDeckState({
    this.cards = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMsg,
  });

  FlashcardDeckState copyWith({
    List<FlashCard>? cards,
    bool? isLoading,
    bool? isSuccess,
    String? errorMsg,
  }) {
    return FlashcardDeckState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [cards, isLoading, isSuccess, errorMsg];
}