import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../solve_math/data/repository/gemini_solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import '../../domain/models/flashcard.dart';
import '../../domain/models/study_material.dart';
import '../repository/flashcard_repository.dart';

class FlashcardService {
  static final FlashcardService _instance = FlashcardService._internal();
  GeminiSolveMathRepo? _geminiService;
  FlashcardRepository? _flashcardRepository;
  final Random _random = Random();

  factory FlashcardService() {
    return _instance;
  }

  FlashcardService._internal();

  Future<void> initialize() async {
    _geminiService ??= GeminiSolveMathRepo();
    _flashcardRepository ??= FlashcardRepository();

    // Check authentication
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception('User must be authenticated to use flashcard service');
    }

    if (!_geminiService!.isInitialized) {
      await _geminiService!.initialize();
    }
  }

  /// Generate flashcards from study materials using AI
  Future<FlashCardDeck> generateFlashcardsFromMaterials({
    required List<StudyMaterial> materials,
    required String deckName,
    String? deckDescription,
    int cardCount = 20,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();
    final locale = prefs.getLocale();

    // Combine material content for AI analysis
    final combinedContent = _combineMaterialsContent(materials);

    // Generate flashcards using AI
    final cards = await _generateFlashcardsFromContent(
      content: combinedContent,
      mathLevel: mathLevel,
      locale: locale,
      cardCount: cardCount,
    );

    // Create deck
    final deck = FlashCardDeck(
      id: _generateId(),
      userId: userId,
      name: deckName,
      description: deckDescription,
      createdAt: DateTime.now(),
      cardCount: cards.length,
      newCardCount: cards.length,
      sourceType: 'material',
      sourceId: materials.map((m) => m.id).join(','),
    );

    // Save deck and cards

    await _flashcardRepository!.createDeck(deck);

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];

      await _flashcardRepository!.createCard(card.copyWith(deckId: deck.id));
    }

    return deck;
  }

  // Removed generateFlashcardsFromQuiz method - quiz generation not needed

  /// Generate flashcards from content using AI
  Future<List<FlashCard>> _generateFlashcardsFromContent({
    required String content,
    required MathLevel mathLevel,
    required String locale,
    required int cardCount,
  }) async {
    final prompt = _getFlashcardGenerationPrompt(
      locale,
      content,
      mathLevel.displayName,
      cardCount,
    );

    final response = await _geminiService!.generateTextContent(prompt);
    final flashcardText = response.text ?? '';

    final cards = _parseFlashcardsFromAIResponse(flashcardText);

    // Ensure all AI-generated cards have userId
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return cards.map((card) => card.copyWith(userId: userId)).toList();
  }

  /// Get flashcard generation prompt
  String _getFlashcardGenerationPrompt(
    String languageCode,
    String content,
    String levelDisplayName,
    int cardCount,
  ) {
    final Map<String, String> prompts = {
      'en':
          '''You are an expert math teacher creating flashcards. Based on the study material below, create exactly $cardCount flashcards.

STUDY MATERIAL:
$content

REQUIREMENTS:
- Student Level: $levelDisplayName
- Create flashcards that test key concepts, formulas, and problem-solving steps
- Make flashcards progressive in difficulty
- Include clear, concise questions and comprehensive answers
- Focus on understanding, not just memorization

Format each flashcard EXACTLY like this:

FLASHCARD 1:
Front: [Clear, concise question]
Back: [Comprehensive answer with explanation]
Tags: [Tag1, Tag2, Tag3]
Hint: [Optional helpful hint]

FLASHCARD 2:
Front: [Question]  
Back: [Answer with explanation]
Tags: [Tag1, Tag2]

Continue this pattern for all $cardCount flashcards. Make sure to cover the most important concepts from the material.''',

      'fr':
          '''Vous êtes un professeur de mathématiques expert créant des cartes mémoire. Basé sur le matériel d'étude ci-dessous, créez exactement $cardCount cartes mémoire.

MATÉRIEL D'ÉTUDE :
$content

EXIGENCES :
- Niveau étudiant : $levelDisplayName
- Créez des cartes mémoire qui testent les concepts clés, les formules et les étapes de résolution de problèmes
- Rendez les cartes mémoire progressives en difficulté
- Incluez des questions claires et concises et des réponses complètes
- Concentrez-vous sur la compréhension, pas seulement la mémorisation

Formatez chaque carte mémoire EXACTEMENT comme ceci :

CARTE MÉMOIRE 1 :
Front: [Question claire et concise]
Back: [Réponse complète avec explication]
Tags: [Étiquette1, Étiquette2, Étiquette3]
Hint: [Indice utile facultatif]

Continuez ce modèle pour toutes les $cardCount cartes mémoire.''',

      'es':
          '''Eres un profesor de matemáticas experto creando tarjetas de memoria. Basado en el material de estudio a continuación, crea exactamente $cardCount tarjetas de memoria.

MATERIAL DE ESTUDIO:
$content

REQUISITOS:
- Nivel del estudiante: $levelDisplayName
- Crea tarjetas de memoria que prueben conceptos clave, fórmulas y pasos de resolución de problemas
- Haz las tarjetas progresivas en dificultad
- Incluye preguntas claras y concisas y respuestas comprensivas
- Enfócate en comprensión, no solo memorización

Formatea cada tarjeta de memoria EXACTAMENTE así:

TARJETA DE MEMORIA 1:
Front: [Pregunta clara y concisa]
Back: [Respuesta comprensiva con explicación]
Tags: [Etiqueta1, Etiqueta2, Etiqueta3]
Hint: [Pista útil opcional]

Continúa este patrón para todas las $cardCount tarjetas de memoria.''',
    };

    return prompts[languageCode] ?? prompts['en']!;
  }

  /// Parse AI response into flashcards
  List<FlashCard> _parseFlashcardsFromAIResponse(String response) {
    final cards = <FlashCard>[];
    final cardBlocks = response.split(
      RegExp(r'FLASHCARD \d+:|CARTE MÉMOIRE \d+ :|TARJETA DE MEMORIA \d+:'),
    );

    for (int i = 1; i < cardBlocks.length; i++) {
      final block = cardBlocks[i].trim();
      if (block.isEmpty) continue;

      try {
        final card = _parseFlashcardBlock(block);
        if (card != null) {
          cards.add(card);
        }
      } catch (e) {
        // Silently continue on parsing errors
      }
    }

    return cards;
  }

  /// Parse individual flashcard block
  FlashCard? _parseFlashcardBlock(String block) {
    final lines =
        block
            .split('\n')
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

    String front = '';
    String back = '';
    List<String> tags = [];
    String? hint;

    for (final line in lines) {
      if (line.startsWith('Front:')) {
        front = line.replaceFirst('Front:', '').trim();
      } else if (line.startsWith('Back:')) {
        back = line.replaceFirst('Back:', '').trim();
      } else if (line.startsWith('Tags:')) {
        final tagsStr = line.replaceFirst('Tags:', '').trim();
        tags =
            tagsStr
                .split(',')
                .map((t) => t.trim().replaceAll('[', '').replaceAll(']', ''))
                .toList();
      } else if (line.startsWith('Hint:')) {
        hint = line.replaceFirst('Hint:', '').trim();
      }
    }

    if (front.isEmpty || back.isEmpty) {
      return null;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (userId.isEmpty) {
      // Warning: No authenticated user when creating flashcard
    }

    return FlashCard(
      id: _generateId(),
      userId: userId,
      deckId: '', // Will be set later
      front: front,
      back: back,
      hint: hint,
      tags: tags,
      createdAt: DateTime.now(),
      nextReviewAt: null, // Make immediately available for review
      isActive: true, // Explicitly set as active
    );
  }

  /// Review a flashcard and update using SM-2 spaced repetition algorithm
  Future<FlashCard> reviewCard({
    required FlashCard card,
    required ReviewResult result,
  }) async {
    final now = DateTime.now();
    int quality = result.index; // 0 = again, 1 = hard, 2 = good, 3 = easy

    // SM-2 Algorithm implementation
    double newEaseFactor = card.easeFactor;
    int newInterval = card.interval;

    if (quality >= 2) {
      // Correct answer
      if (card.reviewCount == 0) {
        newInterval = 1;
      } else if (card.reviewCount == 1) {
        newInterval = 6;
      } else {
        newInterval = (card.interval * card.easeFactor).round();
      }

      // Update ease factor
      newEaseFactor =
          card.easeFactor +
          (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
      if (newEaseFactor < 1.3) newEaseFactor = 1.3;
    } else {
      // Incorrect answer - reset interval but keep ease factor
      newInterval = 1;
    }

    final nextReviewDate = now.add(Duration(days: newInterval));

    final updatedCard = card.copyWith(
      lastReviewedAt: now,
      nextReviewAt: nextReviewDate,
      reviewCount: card.reviewCount + 1,
      correctCount: quality >= 2 ? card.correctCount + 1 : card.correctCount,
      easeFactor: newEaseFactor,
      interval: newInterval,
    );

    // Save to repository
    await _flashcardRepository!.updateCard(updatedCard);

    return updatedCard;
  }

  /// Get cards due for review in a deck
  Future<List<FlashCard>> getDueCards(String deckId, {int limit = 20}) async {
    try {
      final allCards = await _flashcardRepository!.getCardsInDeck(deckId);

      final dueCards =
          allCards.where((card) => card.isDue && card.isActive).toList();

      // Sort by priority: new cards first, then by due date
      dueCards.sort((a, b) {
        if (a.isNew && !b.isNew) return -1;
        if (!a.isNew && b.isNew) return 1;
        if (a.nextReviewAt == null && b.nextReviewAt == null) return 0;
        if (a.nextReviewAt == null) return -1;
        if (b.nextReviewAt == null) return 1;
        return a.nextReviewAt!.compareTo(b.nextReviewAt!);
      });

      return dueCards.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  /// Get all cards in a deck (for review when no due cards)
  Future<List<FlashCard>> getAllCardsInDeck(String deckId) async {
    try {
      final cards = await _flashcardRepository!.getCardsInDeck(deckId);
      return cards;
    } catch (e) {
      return [];
    }
  }

  /// Create a new deck manually
  Future<FlashCardDeck> createDeck({
    required String name,
    String? description,
    String? color,
    List<String> tags = const [],
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final deck = FlashCardDeck(
      id: _generateId(),
      userId: userId,
      name: name,
      description: description,
      color: color,
      tags: tags,
      createdAt: DateTime.now(),
    );

    await _flashcardRepository!.createDeck(deck);
    return deck;
  }

  /// Add card to deck manually
  Future<FlashCard> addCardToDeck({
    required String deckId,
    required String front,
    required String back,
    String? hint,
    List<String> tags = const [],
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final card = FlashCard(
      id: _generateId(),
      userId: userId,
      deckId: deckId,
      front: front,
      back: back,
      hint: hint,
      tags: tags,
      createdAt: DateTime.now(),
      // Explicitly set nextReviewAt to null for new cards to make them due
      nextReviewAt: null,
    );

    await _flashcardRepository!.createCard(card);

    // Update deck card count
    final deck = await _flashcardRepository!.getDeck(deckId);
    if (deck != null) {
      await _flashcardRepository!.updateDeck(
        deck.copyWith(
          cardCount: deck.cardCount + 1,
          newCardCount: deck.newCardCount + 1,
        ),
      );
    }

    return card;
  }

  /// Get all decks for current user
  Future<List<FlashCardDeck>> getUserDecks() async {
    try {
      final result = await _flashcardRepository!.getUserDecks();
      return result;
    } catch (e) {
      return [];
    }
  }

  /// Get deck statistics
  Future<Map<String, dynamic>> getDeckStatistics(String deckId) async {
    try {
      final cards = await _flashcardRepository!.getCardsInDeck(deckId);

      final total = cards.length;
      final newCards = cards.where((c) => c.isNew).length;
      final dueCards = cards.where((c) => c.isDue && !c.isNew).length;
      final learningCards = cards.where((c) => !c.isNew && !c.isDue).length;

      double averageSuccessRate = 0.0;
      if (cards.isNotEmpty) {
        final totalSuccessRate = cards.fold(
          0.0,
          (sum, card) => sum + card.successRate,
        );
        averageSuccessRate = totalSuccessRate / cards.length;
      }

      return {
        'totalCards': total,
        'newCards': newCards,
        'dueCards': dueCards,
        'learningCards': learningCards,
        'averageSuccessRate': averageSuccessRate,
      };
    } catch (e) {
      return {
        'totalCards': 0,
        'newCards': 0,
        'dueCards': 0,
        'learningCards': 0,
        'averageSuccessRate': 0.0,
      };
    }
  }

  /// Start a review session
  Future<ReviewSession> startReviewSession(String deckId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    final session = ReviewSession(
      id: _generateId(),
      userId: userId,
      deckId: deckId,
      startedAt: DateTime.now(),
    );

    await _flashcardRepository!.createReviewSession(session);
    return session;
  }

  /// Complete a review session
  Future<ReviewSession> completeReviewSession({
    required ReviewSession session,
    required int cardsReviewed,
    required int correctAnswers,
    required Map<String, int> reviewResults,
  }) async {
    final completedSession = session.copyWith(
      completedAt: DateTime.now(),
      cardsReviewed: cardsReviewed,
      correctAnswers: correctAnswers,
      reviewResults: reviewResults,
    );

    await _flashcardRepository!.updateReviewSession(completedSession);

    // Update deck last studied time
    final deck = await _flashcardRepository!.getDeck(session.deckId);
    if (deck != null) {
      await _flashcardRepository!.updateDeck(
        deck.copyWith(lastStudiedAt: DateTime.now()),
      );
    }

    return completedSession;
  }

  /// Helper methods
  String _combineMaterialsContent(List<StudyMaterial> materials) {
    final buffer = StringBuffer();

    for (final material in materials) {
      buffer.writeln('Material: ${material.title}');
      if (material.content != null) {
        buffer.writeln('Content: ${material.content}');
      }
      if (material.aiAnalysis != null) {
        buffer.writeln('Analysis: ${material.aiAnalysis}');
      }
      buffer.writeln('Topics: ${material.extractedTopics.join(", ")}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString();
  }

  /// Delete deck and all its cards
  Future<void> deleteDeck(String deckId) async {
    try {
      await _flashcardRepository!.deleteDeck(deckId);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete specific card
  Future<void> deleteCard(String cardId) async {
    try {
      await _flashcardRepository!.deleteCard(cardId);
    } catch (e) {
      rethrow;
    }
  }

  /// Update deck information
  Future<FlashCardDeck> updateDeck(FlashCardDeck deck) async {
    try {
      await _flashcardRepository!.updateDeck(deck);
      return deck;
    } catch (e) {
      rethrow;
    }
  }

  /// Update card information
  Future<FlashCard> updateCard(FlashCard card) async {
    try {
      await _flashcardRepository!.updateCard(card);
      return card;
    } catch (e) {
      rethrow;
    }
  }
}
