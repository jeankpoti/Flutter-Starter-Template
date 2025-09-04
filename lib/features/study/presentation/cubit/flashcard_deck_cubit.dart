import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/repository/flashcard_repository.dart';
import '../../data/repository/flashcard_repository_impl.dart';

part 'flashcard_deck_state.dart';

class FlashcardDeckCubit extends Cubit<FlashcardDeckState> {
  final FlashcardRepositoryInterface _flashcardRepository;

  FlashcardDeckCubit({FlashcardRepositoryInterface? flashcardRepository})
      : _flashcardRepository = flashcardRepository ?? FlashcardRepositoryImpl(),
        super(const FlashcardDeckState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.initialize();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      dev.log('FlashcardDeckCubit: Error initializing: $e', name: 'FlashcardDeckCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> loadCards(String deckId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      final cards = await _flashcardRepository.getAllCardsInDeck(deckId);
      dev.log('FlashcardDeckCubit: Loaded ${cards.length} cards', name: 'FlashcardDeckCubit');
      emit(state.copyWith(
        isLoading: false,
        cards: cards,
        isSuccess: true,
      ));
    } catch (e) {
      dev.log('FlashcardDeckCubit: Error loading cards: $e', name: 'FlashcardDeckCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> addCardToDeck({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String>? tags,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.addCardToDeck(
        deckId: deckId,
        front: front,
        back: back,
        hint: hint,
        tags: tags ?? [],
      );
      // Reload cards after addition
      await loadCards(deckId);
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardDeckCubit: Error adding card: $e', name: 'FlashcardDeckCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to add card: ${e.toString()}'));
    }
  }

  Future<void> updateCard(FlashCard card) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.updateCard(card);
      // Reload cards after update
      await loadCards(card.deckId);
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardDeckCubit: Error updating card: $e', name: 'FlashcardDeckCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to update card: ${e.toString()}'));
    }
  }

  Future<void> deleteCard(String cardId, String deckId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.deleteCard(cardId);
      // Reload cards after deletion
      await loadCards(deckId);
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardDeckCubit: Error deleting card: $e', name: 'FlashcardDeckCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to delete card'));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMsg: null, isSuccess: false));
  }
}