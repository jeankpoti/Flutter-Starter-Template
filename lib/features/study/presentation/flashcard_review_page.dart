import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../domain/models/flashcard.dart';
import '../data/services/flashcard_service.dart';
import 'widgets/review/flashcard_display_widget.dart';
import 'widgets/review/flashcard_completion_dialog.dart';
import 'widgets/review/flashcard_review_buttons.dart';

class FlashcardReviewPage extends StatefulWidget {
  final FlashCardDeck deck;

  const FlashcardReviewPage({super.key, required this.deck});

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage>
    with SingleTickerProviderStateMixin {
  final FlashcardService _flashcardService = FlashcardService();
  List<FlashCard> _cards = [];
  int _currentCardIndex = 0;
  bool _isLoading = true;
  bool _showAnswer = false;
  String? _errorMessage;

  ReviewSession? _currentSession;
  int _sessionCorrectAnswers = 0;
  Map<String, int> _sessionResults = {};

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  bool _isFlipping = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );
    _initializeReview();
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  Future<void> _initializeReview() async {
    try {
      dev.log(
        'FlashcardReview: Initializing review for deck ${widget.deck.id}',
        name: 'FlashcardReview',
      );
      await _flashcardService.initialize();

      // First try to get due cards
      final dueCards = await _flashcardService.getDueCards(
        widget.deck.id,
        limit: 20,
      );
      dev.log(
        'FlashcardReview: Found ${dueCards.length} due cards',
        name: 'FlashcardReview',
      );

      List<FlashCard> cards = dueCards;

      // If no due cards, get all cards in the deck for review
      if (cards.isEmpty) {
        dev.log(
          'FlashcardReview: No due cards, getting all cards in deck',
          name: 'FlashcardReview',
        );
        final allCards = await _flashcardService.getAllCardsInDeck(
          widget.deck.id,
        );
        cards = allCards.take(20).toList(); // Limit to 20 cards
        dev.log(
          'FlashcardReview: Found ${cards.length} total cards in deck',
          name: 'FlashcardReview',
        );
      }

      if (cards.isEmpty) {
        dev.log(
          'FlashcardReview: No cards found in deck at all',
          name: 'FlashcardReview',
        );
        setState(() {
          _errorMessage = 'No cards found in this deck';
          _isLoading = false;
        });
        return;
      }

      final session = await _flashcardService.startReviewSession(
        widget.deck.id,
      );
      dev.log(
        'FlashcardReview: Started review session ${session.id}',
        name: 'FlashcardReview',
      );

      setState(() {
        _cards = cards;
        _currentSession = session;
        _isLoading = false;
      });
    } catch (e) {
      dev.log(
        'FlashcardReview: Error initializing review: $e',
        name: 'FlashcardReview',
        error: e,
      );
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _showAnswerMethod() async {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    await _flipController.forward();

    setState(() {
      _showAnswer = true;
      _isFlipping = false;
    });
  }

  Future<void> _reviewCard(ReviewResult result) async {
    if (_currentCardIndex >= _cards.length || _currentSession == null) return;

    final currentCard = _cards[_currentCardIndex];

    try {
      // Update card with spaced repetition
      await _flashcardService.reviewCard(card: currentCard, result: result);

      // Update session stats
      _sessionResults[result.name] = (_sessionResults[result.name] ?? 0) + 1;
      if (result == ReviewResult.good || result == ReviewResult.easy) {
        _sessionCorrectAnswers++;
      }

      // Move to next card or finish session
      if (_currentCardIndex < _cards.length - 1) {
        await _nextCard();
      } else {
        await _finishSession();
      }
    } catch (e) {
      AppSnackBar.showError(context, 'Error reviewing card: ${e.toString()}');
    }
  }

  Future<void> _nextCard() async {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    await _flipController.reverse();

    setState(() {
      _currentCardIndex++;
      _showAnswer = false;
      _isFlipping = false;
    });
  }

  Future<void> _finishSession() async {
    if (_currentSession == null) return;

    try {
      await _flashcardService.completeReviewSession(
        session: _currentSession!,
        cardsReviewed: _cards.length,
        correctAnswers: _sessionCorrectAnswers,
        reviewResults: _sessionResults,
      );

      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      AppSnackBar.showError(context, 'Error saving session: ${e.toString()}');
    }
  }

  void _showCompletionDialog() {
    FlashcardCompletionDialog.show(
      context: context,
      cards: _cards,
      sessionCorrectAnswers: _sessionCorrectAnswers,
      currentSession: _currentSession,
      onComplete: () {},
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: TitleMediumText(widget.deck.name),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: TitleMediumText(widget.deck.name),
          backgroundColor: Colors.transparent,
        ),
        body: _buildErrorState(),
      );
    }

    if (_currentCardIndex >= _cards.length) {
      return Scaffold(
        appBar: AppBar(
          title: TitleMediumText(widget.deck.name),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentCard = _cards[_currentCardIndex];
    final progress = (_currentCardIndex + 1) / _cards.length;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: TitleMediumText(
          widget.deck.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LabelMediumText(
              '${_currentCardIndex + 1}/${_cards.length}',
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Card area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: FlashcardDisplayWidget(
                  card: currentCard,
                  showAnswer: _showAnswer,
                  flipAnimation: _flipAnimation,
                  onTap: _showAnswerMethod,
                ),
              ),
            ),
          ),

          // Action buttons
          FlashcardReviewButtons(
            showAnswer: _showAnswer,
            isFlipping: _isFlipping,
            onShowAnswer: _showAnswerMethod,
            onReviewCard: _reviewCard,
          ),
        ],
      ),
    );
  }





  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _errorMessage == 'No cards due for review'
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 64,
              color:
                  _errorMessage == 'No cards due for review'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              _errorMessage == 'No cards due for review'
                  ? 'All Caught Up!'
                  : 'Error',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              _errorMessage == 'No cards due for review'
                  ? 'No cards are due for review at the moment. Come back later to continue studying.'
                  : _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  _errorMessage == 'No cards due for review'
                      ? () => Navigator.pop(context)
                      : _initializeReview,
              icon: Icon(
                _errorMessage == 'No cards due for review'
                    ? Icons.arrow_back
                    : Icons.refresh,
              ),
              label: Text(
                _errorMessage == 'No cards due for review'
                    ? 'Back to Flashcards'
                    : 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
