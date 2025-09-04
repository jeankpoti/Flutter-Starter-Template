import 'dart:developer' as dev;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/models/study_material.dart';
import '../../domain/repository/flashcard_repository.dart';
import '../../data/repository/flashcard_repository_impl.dart';

part 'flashcard_state.dart';

class FlashcardCubit extends Cubit<FlashcardState> {
  final FlashcardRepositoryInterface _flashcardRepository;

  FlashcardCubit({FlashcardRepositoryInterface? flashcardRepository})
      : _flashcardRepository = flashcardRepository ?? FlashcardRepositoryImpl(),
        super(const FlashcardState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.initialize();
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      dev.log('FlashcardCubit: Error initializing: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> loadUserDecks() async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      final decks = await _flashcardRepository.getUserDecks();
      dev.log('FlashcardCubit: Loaded ${decks.length} decks', name: 'FlashcardCubit');
      emit(state.copyWith(
        isLoading: false,
        decks: decks,
        isSuccess: true,
      ));
    } catch (e) {
      dev.log('FlashcardCubit: Error loading decks: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> createDeck({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.createDeck(
        name: name,
        description: description,
        color: color,
      );
      // Reload decks after creation
      await loadUserDecks();
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardCubit: Error creating deck: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to create deck: ${e.toString()}'));
    }
  }

  Future<void> deleteDeck(String deckId) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.deleteDeck(deckId);
      // Reload decks after deletion
      await loadUserDecks();
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardCubit: Error deleting deck: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to delete deck'));
    }
  }

  Future<void> updateDeck({
    required FlashCardDeck deck,
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      
      final updatedDeck = deck.copyWith(
        name: name,
        description: description,
        color: color,
      );
      
      await _flashcardRepository.updateDeck(updatedDeck);
      // Reload decks after update
      await loadUserDecks();
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardCubit: Error updating deck: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to update deck: ${e.toString()}'));
    }
  }

  Future<void> generateFlashcardsFromMaterials({
    required List<StudyMaterial> materials,
    required String deckName,
    String? deckDescription,
    int cardCount = 20,
  }) async {
    try {
      emit(state.copyWith(isLoading: true, errorMsg: null));
      await _flashcardRepository.generateFlashcardsFromMaterials(
        materials: materials,
        deckName: deckName,
        deckDescription: deckDescription,
        cardCount: cardCount,
      );
      // Reload decks after generation
      await loadUserDecks();
      emit(state.copyWith(isSuccess: true));
    } catch (e) {
      dev.log('FlashcardCubit: Error generating flashcards: $e', name: 'FlashcardCubit', error: e);
      emit(state.copyWith(isLoading: false, errorMsg: 'Failed to generate flashcards: ${e.toString()}'));
    }
  }

  void clearMessages() {
    emit(state.copyWith(errorMsg: null, isSuccess: false));
  }
}