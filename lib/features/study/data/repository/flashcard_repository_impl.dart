import '../../domain/models/flashcard.dart';
import '../../domain/models/study_material.dart';
import '../../domain/models/quiz.dart';
import '../../domain/repository/flashcard_repository.dart';
import '../services/flashcard_service.dart';

/// Implementation of FlashcardRepositoryInterface using FlashcardService
/// 
/// This class acts as an adapter between the domain layer and the data layer,
/// delegating all operations to the FlashcardService while implementing the domain interface.
class FlashcardRepositoryImpl implements FlashcardRepositoryInterface {
  final FlashcardService _flashcardService;

  FlashcardRepositoryImpl({FlashcardService? flashcardService})
      : _flashcardService = flashcardService ?? FlashcardService();

  @override
  Future<void> initialize() async {
    await _flashcardService.initialize();
  }

  @override
  Future<FlashCardDeck> createDeck({
    required String name,
    String? description,
    String? color,
  }) async {
    return await _flashcardService.createDeck(
      name: name,
      description: description,
      color: color,
    );
  }

  @override
  Future<List<FlashCardDeck>> getUserDecks() async {
    return await _flashcardService.getUserDecks();
  }

  @override
  Future<FlashCardDeck> updateDeck(FlashCardDeck deck) async {
    return await _flashcardService.updateDeck(deck);
  }

  @override
  Future<void> deleteDeck(String deckId) async {
    await _flashcardService.deleteDeck(deckId);
  }

  @override
  Future<Map<String, dynamic>> getDeckStatistics(String deckId) async {
    return await _flashcardService.getDeckStatistics(deckId);
  }

  @override
  Future<FlashCard> addCardToDeck({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String>? tags,
  }) async {
    return await _flashcardService.addCardToDeck(
      deckId: deckId,
      front: front,
      back: back,
      hint: hint,
      tags: tags ?? [],
    );
  }

  @override
  Future<List<FlashCard>> getAllCardsInDeck(String deckId) async {
    return await _flashcardService.getAllCardsInDeck(deckId);
  }

  @override
  Future<List<FlashCard>> getDueCards(String deckId, {int limit = 20}) async {
    return await _flashcardService.getDueCards(deckId, limit: limit);
  }

  @override
  Future<FlashCard> updateCard(FlashCard card) async {
    return await _flashcardService.updateCard(card);
  }

  @override
  Future<void> deleteCard(String cardId) async {
    await _flashcardService.deleteCard(cardId);
  }

  @override
  Future<FlashCard> reviewCard({
    required FlashCard card,
    required ReviewResult result,
  }) async {
    return await _flashcardService.reviewCard(card: card, result: result);
  }

  @override
  Future<ReviewSession> startReviewSession(String deckId) async {
    return await _flashcardService.startReviewSession(deckId);
  }

  @override
  Future<ReviewSession> completeReviewSession({
    required ReviewSession session,
    required int cardsReviewed,
    required int correctAnswers,
    required Map<String, int> reviewResults,
  }) async {
    return await _flashcardService.completeReviewSession(
      session: session,
      cardsReviewed: cardsReviewed,
      correctAnswers: correctAnswers,
      reviewResults: reviewResults,
    );
  }

  @override
  Future<FlashCardDeck> generateFlashcardsFromMaterials({
    required List<StudyMaterial> materials,
    required String deckName,
    String? deckDescription,
    int cardCount = 20,
  }) async {
    return await _flashcardService.generateFlashcardsFromMaterials(
      materials: materials,
      deckName: deckName,
      deckDescription: deckDescription,
      cardCount: cardCount,
    );
  }

  @override
  Future<FlashCardDeck> generateFlashcardsFromQuiz({
    required Quiz quiz,
    String? deckName,
    String? deckDescription,
  }) async {
    return await _flashcardService.generateFlashcardsFromQuiz(
      quiz: quiz,
      deckName: deckName,
      deckDescription: deckDescription,
    );
  }
}