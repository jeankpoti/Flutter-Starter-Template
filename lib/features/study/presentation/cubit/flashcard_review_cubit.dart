import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/repository/flashcard_repository.dart';
import '../../data/repository/flashcard_repository_impl.dart';

part 'flashcard_review_state.dart';

class FlashcardReviewCubit extends Cubit<FlashcardReviewState> {
  final FlashcardRepositoryInterface _flashcardRepository;

  FlashcardReviewCubit({FlashcardRepositoryInterface? flashcardRepository})
      : _flashcardRepository = flashcardRepository ?? FlashcardRepositoryImpl(),
        super(const FlashcardReviewState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.initialize();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      dev.log('FlashcardReviewCubit: Error initializing: $e', name: 'FlashcardReviewCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> startReviewSession(String deckId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      
      // First try to get due cards
      final dueCards = await _flashcardRepository.getDueCards(deckId, limit: 20);
      dev.log('FlashcardReviewCubit: Found ${dueCards.length} due cards', name: 'FlashcardReviewCubit');

      List<FlashCard> cards = dueCards;

      // If no due cards, get all cards in the deck for review
      if (cards.isEmpty) {
        dev.log('FlashcardReviewCubit: No due cards, getting all cards in deck', name: 'FlashcardReviewCubit');
        final allCards = await _flashcardRepository.getAllCardsInDeck(deckId);
        cards = allCards.take(20).toList(); // Limit to 20 cards
        dev.log('FlashcardReviewCubit: Found ${cards.length} total cards in deck', name: 'FlashcardReviewCubit');
      }

      if (cards.isEmpty) {
        dev.log('FlashcardReviewCubit: No cards found in deck at all', name: 'FlashcardReviewCubit');
        emit(state.copyWith(
          isLoading: false,
          errorMsg: 'No cards found in this deck',
        ));
        return;
      }

      final session = await _flashcardRepository.startReviewSession(deckId);
      dev.log('FlashcardReviewCubit: Started review session ${session.id}', name: 'FlashcardReviewCubit');

      emit(state.copyWith(
        isLoading: false,
        cards: cards,
        currentSession: session,
        currentCardIndex: 0,
        sessionCorrectAnswers: 0,
        sessionResults: {},
        isSuccess: true,
      ));
    } catch (e) {
      dev.log('FlashcardReviewCubit: Error starting review session: $e', name: 'FlashcardReviewCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> reviewCard({
    required FlashCard card,
    required ReviewResult result,
  }) async {
    try {
      // Update card with spaced repetition
      await _flashcardRepository.reviewCard(card: card, result: result);

      // Update session stats
      final updatedResults = Map<String, int>.from(state.sessionResults);
      updatedResults[result.name] = (updatedResults[result.name] ?? 0) + 1;

      int correctAnswers = state.sessionCorrectAnswers;
      if (result == ReviewResult.good || result == ReviewResult.easy) {
        correctAnswers++;
      }

      // Move to next card or finish session
      if (state.currentCardIndex < state.cards.length - 1) {
        emit(state.copyWith(
          currentCardIndex: state.currentCardIndex + 1,
          sessionCorrectAnswers: correctAnswers,
          sessionResults: updatedResults,
        ));
      } else {
        // Session completed
        emit(state.copyWith(
          sessionCorrectAnswers: correctAnswers,
          sessionResults: updatedResults,
          isSessionCompleted: true,
        ));
      }
    } catch (e) {
      dev.log('FlashcardReviewCubit: Error reviewing card: $e', name: 'FlashcardReviewCubit', error: e);
      emit(state.copyWith(errorMsg: 'Error reviewing card: ${e.toString()}'));
    }
  }

  Future<void> completeReviewSession() async {
    if (state.currentSession == null) return;

    try {
      await _flashcardRepository.completeReviewSession(
        session: state.currentSession!,
        cardsReviewed: state.cards.length,
        correctAnswers: state.sessionCorrectAnswers,
        reviewResults: state.sessionResults,
      );
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardReviewCubit: Error completing session: $e', name: 'FlashcardReviewCubit', error: e);
      emit(state.copyWith(errorMsg: 'Error saving session: ${e.toString()}'));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMsg: null, isSuccess: false));
  }
}