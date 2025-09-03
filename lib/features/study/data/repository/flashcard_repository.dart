import 'dart:developer' as dev;
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/flashcard.dart';

class FlashcardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _userId {
    final uid = _auth.currentUser?.uid ?? '';
    dev.log('FlashcardRepository: Current user ID: $uid', name: 'FlashcardRepository');
    return uid;
  }

  // Collection references
  CollectionReference get _decksCollection => _firestore.collection('flashcardDecks');
  CollectionReference get _cardsCollection => _firestore.collection('flashcards');
  CollectionReference get _sessionsCollection => _firestore.collection('reviewSessions');

  /// Create a new deck
  Future<void> createDeck(FlashCardDeck deck) async {
    try {
      await _decksCollection.doc(deck.id).set(deck.toMap());
      debugPrint('Deck created successfully: ${deck.id}');
    } catch (e) {
      debugPrint('Error creating deck: $e');
      rethrow;
    }
  }

  /// Get a specific deck by ID
  Future<FlashCardDeck?> getDeck(String deckId) async {
    try {
      final doc = await _decksCollection.doc(deckId).get();
      if (doc.exists && doc.data() != null) {
        return FlashCardDeck.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting deck: $e');
      return null;
    }
  }

  /// Get all decks for the current user
  Future<List<FlashCardDeck>> getUserDecks() async {
    try {
      final userId = _userId;
      dev.log('FlashcardRepository: Getting user decks for userId: $userId', name: 'FlashcardRepository');
      
      if (userId.isEmpty) {
        dev.log('FlashcardRepository: User ID is empty! User not authenticated.', name: 'FlashcardRepository');
        return [];
      }
      
      final query = await _decksCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      dev.log('FlashcardRepository: Found ${query.docs.length} deck documents', name: 'FlashcardRepository');
      
      final decks = query.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              dev.log('FlashcardRepository: Deck data: $data', name: 'FlashcardRepository');
              return FlashCardDeck.fromMap(data);
            } catch (e) {
              dev.log('FlashcardRepository: Error parsing deck ${doc.id}: $e', name: 'FlashcardRepository', error: e);
              return null;
            }
          })
          .where((deck) => deck != null)
          .cast<FlashCardDeck>()
          .toList();

      dev.log('FlashcardRepository: Successfully parsed ${decks.length} decks', name: 'FlashcardRepository');
      return decks;
    } catch (e) {
      dev.log('FlashcardRepository: Error getting user decks: $e', name: 'FlashcardRepository', error: e);
      return [];
    }
  }

  /// Update a deck
  Future<void> updateDeck(FlashCardDeck deck) async {
    try {
      await _decksCollection.doc(deck.id).update(deck.toMap());
      debugPrint('Deck updated successfully: ${deck.id}');
    } catch (e) {
      debugPrint('Error updating deck: $e');
      rethrow;
    }
  }

  /// Delete a deck and all its cards
  Future<void> deleteDeck(String deckId) async {
    try {
      // Delete all cards in the deck first
      final cardsQuery = await _cardsCollection
          .where('deckId', isEqualTo: deckId)
          .get();

      final batch = _firestore.batch();

      // Delete all cards
      for (final doc in cardsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete the deck
      batch.delete(_decksCollection.doc(deckId));

      await batch.commit();
      debugPrint('Deck and all its cards deleted successfully: $deckId');
    } catch (e) {
      debugPrint('Error deleting deck: $e');
      rethrow;
    }
  }

  /// Create a new card
  Future<void> createCard(FlashCard card) async {
    try {
      dev.log('FlashcardRepository: Creating card ${card.id} for deck ${card.deckId}', name: 'FlashcardRepository');
      dev.log('FlashcardRepository: Card front: ${card.front.substring(0, min(100, card.front.length))}', name: 'FlashcardRepository');
      
      final cardData = card.toMap();
      dev.log('FlashcardRepository: Card data: $cardData', name: 'FlashcardRepository');
      
      await _cardsCollection.doc(card.id).set(cardData);
      dev.log('FlashcardRepository: Card created successfully: ${card.id}', name: 'FlashcardRepository');
    } catch (e) {
      dev.log('FlashcardRepository: Error creating card: $e', name: 'FlashcardRepository', error: e);
      rethrow;
    }
  }

  /// Get a specific card by ID
  Future<FlashCard?> getCard(String cardId) async {
    try {
      final doc = await _cardsCollection.doc(cardId).get();
      if (doc.exists && doc.data() != null) {
        return FlashCard.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting card: $e');
      return null;
    }
  }

  /// Get all cards in a deck
  Future<List<FlashCard>> getCardsInDeck(String deckId) async {
    try {
      dev.log('FlashcardRepository: Querying cards for deckId: $deckId', name: 'FlashcardRepository');
      
      // Use userId + deckId query to match security rules
      final userId = _userId;
      final query = await _cardsCollection
          .where('userId', isEqualTo: userId)
          .where('deckId', isEqualTo: deckId)
          .get();

      dev.log('FlashcardRepository: Query found ${query.docs.length} cards for userId: $userId, deckId: $deckId', name: 'FlashcardRepository');

      // Filter for active cards in memory since we can't do 3-field query without index
      final cards = query.docs
          .map((doc) => FlashCard.fromMap(doc.data() as Map<String, dynamic>))
          .where((card) => card.isActive)
          .toList();

      dev.log('FlashcardRepository: After isActive filter: ${cards.length} cards', name: 'FlashcardRepository');
      return cards;
    } catch (e) {
      dev.log('FlashcardRepository: Error getting cards in deck: $e', name: 'FlashcardRepository', error: e);
      return [];
    }
  }

  /// Get due cards for a deck
  Future<List<FlashCard>> getDueCardsInDeck(String deckId, {int limit = 20}) async {
    try {
      // Get cards that are due (nextReviewAt is null or in the past)
      final query = await _cardsCollection
          .where('deckId', isEqualTo: deckId)
          .where('isActive', isEqualTo: true)
          .limit(limit * 2) // Get more than needed to filter properly
          .get();

      final cards = query.docs
          .map((doc) => FlashCard.fromMap(doc.data() as Map<String, dynamic>))
          .where((card) => card.isDue)
          .take(limit)
          .toList();

      // Sort by priority: new cards first, then by due date
      cards.sort((a, b) {
        if (a.isNew && !b.isNew) return -1;
        if (!a.isNew && b.isNew) return 1;
        if (a.nextReviewAt == null && b.nextReviewAt == null) return 0;
        if (a.nextReviewAt == null) return -1;
        if (b.nextReviewAt == null) return 1;
        return a.nextReviewAt!.compareTo(b.nextReviewAt!);
      });

      return cards;
    } catch (e) {
      debugPrint('Error getting due cards: $e');
      return [];
    }
  }

  /// Update a card
  Future<void> updateCard(FlashCard card) async {
    try {
      await _cardsCollection.doc(card.id).update(card.toMap());
      debugPrint('Card updated successfully: ${card.id}');
    } catch (e) {
      debugPrint('Error updating card: $e');
      rethrow;
    }
  }

  /// Delete a card
  Future<void> deleteCard(String cardId) async {
    try {
      await _cardsCollection.doc(cardId).delete();
      debugPrint('Card deleted successfully: $cardId');
    } catch (e) {
      debugPrint('Error deleting card: $e');
      rethrow;
    }
  }

  /// Create a review session
  Future<void> createReviewSession(ReviewSession session) async {
    try {
      await _sessionsCollection.doc(session.id).set(session.toMap());
      debugPrint('Review session created successfully: ${session.id}');
    } catch (e) {
      debugPrint('Error creating review session: $e');
      rethrow;
    }
  }

  /// Update a review session
  Future<void> updateReviewSession(ReviewSession session) async {
    try {
      await _sessionsCollection.doc(session.id).update(session.toMap());
      debugPrint('Review session updated successfully: ${session.id}');
    } catch (e) {
      debugPrint('Error updating review session: $e');
      rethrow;
    }
  }

  /// Get review sessions for a deck
  Future<List<ReviewSession>> getReviewSessions(String deckId, {int limit = 10}) async {
    try {
      final query = await _sessionsCollection
          .where('userId', isEqualTo: _userId)
          .where('deckId', isEqualTo: deckId)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ReviewSession.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting review sessions: $e');
      return [];
    }
  }

  /// Get all review sessions for the current user
  Future<List<ReviewSession>> getUserReviewSessions({int limit = 50}) async {
    try {
      final query = await _sessionsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('startedAt', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => ReviewSession.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting user review sessions: $e');
      return [];
    }
  }

  /// Get deck statistics
  Future<Map<String, dynamic>> getDeckStatistics(String deckId) async {
    try {
      final cards = await getCardsInDeck(deckId);
      final sessions = await getReviewSessions(deckId);

      final totalCards = cards.length;
      final newCards = cards.where((c) => c.isNew).length;
      final dueCards = cards.where((c) => c.isDue && !c.isNew).length;
      final learningCards = cards.where((c) => !c.isNew && !c.isDue).length;

      double averageSuccessRate = 0.0;
      if (cards.isNotEmpty) {
        final totalSuccessRate = cards.fold(0.0, (sum, card) => sum + card.successRate);
        averageSuccessRate = totalSuccessRate / cards.length;
      }

      final completedSessions = sessions.where((s) => s.isCompleted).length;
      final totalStudyTime = sessions.fold(0, (sum, session) => sum + session.totalTimeSeconds);

      return {
        'totalCards': totalCards,
        'newCards': newCards,
        'dueCards': dueCards,
        'learningCards': learningCards,
        'averageSuccessRate': averageSuccessRate,
        'completedSessions': completedSessions,
        'totalStudyTimeSeconds': totalStudyTime,
      };
    } catch (e) {
      debugPrint('Error getting deck statistics: $e');
      return {
        'totalCards': 0,
        'newCards': 0,
        'dueCards': 0,
        'learningCards': 0,
        'averageSuccessRate': 0.0,
        'completedSessions': 0,
        'totalStudyTimeSeconds': 0,
      };
    }
  }

  /// Update deck card counts (call this when cards are added/removed)
  Future<void> updateDeckCardCounts(String deckId) async {
    try {
      final cards = await getCardsInDeck(deckId);
      final deck = await getDeck(deckId);
      
      if (deck != null) {
        final newCardCount = cards.where((c) => c.isNew).length;
        final dueCardCount = cards.where((c) => c.isDue && !c.isNew).length;
        
        await updateDeck(deck.copyWith(
          cardCount: cards.length,
          newCardCount: newCardCount,
          dueCardCount: dueCardCount,
        ));
      }
    } catch (e) {
      debugPrint('Error updating deck card counts: $e');
      // Don't rethrow as this is a background operation
    }
  }

  /// Search cards within a deck
  Future<List<FlashCard>> searchCardsInDeck(String deckId, String query) async {
    try {
      final allCards = await getCardsInDeck(deckId);
      final lowercaseQuery = query.toLowerCase();
      
      return allCards.where((card) {
        return card.front.toLowerCase().contains(lowercaseQuery) ||
               card.back.toLowerCase().contains(lowercaseQuery) ||
               card.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
      }).toList();
    } catch (e) {
      debugPrint('Error searching cards: $e');
      return [];
    }
  }

  /// Get cards by tag
  Future<List<FlashCard>> getCardsByTag(String deckId, String tag) async {
    try {
      final allCards = await getCardsInDeck(deckId);
      return allCards.where((card) => card.tags.contains(tag)).toList();
    } catch (e) {
      debugPrint('Error getting cards by tag: $e');
      return [];
    }
  }

  /// Stream deck updates
  Stream<FlashCardDeck?> streamDeck(String deckId) {
    return _decksCollection
        .doc(deckId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return FlashCardDeck.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  /// Stream user decks
  Stream<List<FlashCardDeck>> streamUserDecks() {
    return _decksCollection
        .where('userId', isEqualTo: _userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((query) {
      return query.docs
          .map((doc) => FlashCardDeck.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  /// Stream cards in deck
  Stream<List<FlashCard>> streamCardsInDeck(String deckId) {
    return _cardsCollection
        .where('deckId', isEqualTo: deckId)
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((query) {
      return query.docs
          .map((doc) => FlashCard.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }
}