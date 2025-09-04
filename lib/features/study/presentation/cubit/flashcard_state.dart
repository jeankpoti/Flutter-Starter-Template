part of 'flashcard_cubit.dart';

class FlashcardState extends Equatable {
  final List<FlashCardDeck> decks;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMsg;

  const FlashcardState({
    this.decks = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMsg,
  });

  FlashcardState copyWith({
    List<FlashCardDeck>? decks,
    bool? isLoading,
    bool? isSuccess,
    String? errorMsg,
  }) {
    return FlashcardState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [decks, isLoading, isSuccess, errorMsg];
}