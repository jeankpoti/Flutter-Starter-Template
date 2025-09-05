/*
FlashcardRepository is an abstract class that defines the methods that flashcard repository implementations must provide.

This defines what flashcard operations the app can do without worrying about specific implementation details.
*/

import '../models/flashcard.dart';
import '../models/study_material.dart';
// import '../models/quiz.dart'; // Removed - quiz generation not needed

abstract class FlashcardRepositoryInterface {
  // Initialization
  Future<void> initialize();

  // Deck Operations
  Future<FlashCardDeck> createDeck({
    required String name,
    String? description,
    String? color,
  });

  Future<List<FlashCardDeck>> getUserDecks();

  Future<FlashCardDeck> updateDeck(FlashCardDeck deck);

  Future<void> deleteDeck(String deckId);

  Future<Map<String, dynamic>> getDeckStatistics(String deckId);

  // Card Operations
  Future<FlashCard> addCardToDeck({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String>? tags,
  });

  Future<List<FlashCard>> getAllCardsInDeck(String deckId);

  Future<List<FlashCard>> getDueCards(String deckId, {int limit = 20});

  Future<FlashCard> updateCard(FlashCard card);

  Future<void> deleteCard(String cardId);

  // Review Operations
  Future<FlashCard> reviewCard({
    required FlashCard card,
    required ReviewResult result,
  });

  Future<ReviewSession> startReviewSession(String deckId);

  Future<ReviewSession> completeReviewSession({
    required ReviewSession session,
    required int cardsReviewed,
    required int correctAnswers,
    required Map<String, int> reviewResults,
  });

  // AI Generation Operations
  Future<FlashCardDeck> generateFlashcardsFromMaterials({
    required List<StudyMaterial> materials,
    required String deckName,
    String? deckDescription,
    int cardCount = 20,
  });

  // Removed generateFlashcardsFromQuiz - quiz generation not needed
}

/*
The repository interface in the domain layer outlines what flashcard operations the app can do,
but it doesn't worry about the specific implementation details. That's for the data layer.

- Everything in the domain layer should be technology-agnostic, which means it 
should not depend on any specific libraries or frameworks like Firebase, SQLite, etc.

*/