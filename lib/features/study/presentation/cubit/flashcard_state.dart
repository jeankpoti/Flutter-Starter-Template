part of 'flashcard_cubit.dart';

class FlashcardState extends Equatable {
  final List<FlashCardDeck> decks;
  final bool isLoading;
  final bool isSuccess;
  final String? errorMsg;
  final bool isShowingAd;

  const FlashcardState({
    this.decks = const [],
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMsg,
    this.isShowingAd = false,
  });

  FlashcardState copyWith({
    List<FlashCardDeck>? decks,
    bool? isLoading,
    bool? isSuccess,
    String? errorMsg,
    bool? isShowingAd,
  }) {
    return FlashcardState(
      decks: decks ?? this.decks,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMsg: errorMsg,
      isShowingAd: isShowingAd ?? this.isShowingAd,
    );
  }

  @override
  List<Object?> get props => [decks, isLoading, isSuccess, errorMsg, isShowingAd];
}