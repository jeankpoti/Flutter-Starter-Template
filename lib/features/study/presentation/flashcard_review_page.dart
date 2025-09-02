import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../domain/models/flashcard.dart';
import '../data/services/flashcard_service.dart';

class FlashcardReviewPage extends StatefulWidget {
  final FlashCardDeck deck;

  const FlashcardReviewPage({
    super.key,
    required this.deck,
  });

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
      await _flashcardService.initialize();
      final cards = await _flashcardService.getDueCards(widget.deck.id, limit: 20);
      
      if (cards.isEmpty) {
        setState(() {
          _errorMessage = 'No cards due for review';
          _isLoading = false;
        });
        return;
      }
      
      final session = await _flashcardService.startReviewSession(widget.deck.id);
      
      setState(() {
        _cards = cards;
        _currentSession = session;
        _isLoading = false;
      });
    } catch (e) {
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
      await _flashcardService.reviewCard(
        card: currentCard,
        result: result,
      );
      
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
      AppSnackBar.showError(
        context,
        'Error reviewing card: ${e.toString()}',
      );
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
      AppSnackBar.showError(
        context,
        'Error saving session: ${e.toString()}',
      );
    }
  }

  void _showCompletionDialog() {
    final accuracy = _cards.isNotEmpty ? (_sessionCorrectAnswers / _cards.length * 100).round() : 0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.celebration_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            const Text('Review Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TitleLargeText(
                    '$accuracy%',
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                  BodySmallText(
                    'Accuracy',
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  'Cards',
                  _cards.length.toString(),
                  Icons.style_rounded,
                ),
                _buildStatColumn(
                  'Correct',
                  _sessionCorrectAnswers.toString(),
                  Icons.check_circle_outline,
                ),
                _buildStatColumn(
                  'Time',
                  _formatDuration(_currentSession?.duration ?? Duration.zero),
                  Icons.access_time_rounded,
                ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to flashcards
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(height: 4),
        TitleSmallText(
          value,
          fontWeight: FontWeight.w600,
        ),
        BodySmallText(
          label,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m';
    }
    return '${duration.inSeconds}s';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: TitleMediumText(widget.deck.name),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
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
        body: const Center(
          child: CircularProgressIndicator(),
        ),
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
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
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
                child: _buildFlashCard(currentCard),
              ),
            ),
          ),
          
          // Action buttons
          if (!_showAnswer)
            _buildShowAnswerButton()
          else
            _buildReviewButtons(),
        ],
      ),
    );
  }

  Widget _buildFlashCard(FlashCard card) {
    return GestureDetector(
      onTap: _showAnswer ? null : _showAnswerMethod,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final isShowingFront = _flipAnimation.value < 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(_flipAnimation.value * 3.14159),
            child: Container(
              width: double.infinity,
              height: 400,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isShowingFront
                    ? Theme.of(context).colorScheme.surfaceContainer
                    : Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                    offset: const Offset(0, 8),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: isShowingFront
                  ? _buildCardFront(card)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildCardBack(card),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(FlashCard card) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.help_outline_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  HeadlineSmallText(
                    card.front,
                    textAlign: TextAlign.center,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  if (card.hint != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.lightbulb,
                            size: 16,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BodySmallText(
                              card.hint!,
                              color: Theme.of(context).colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FaIcon(
                  FontAwesomeIcons.handPointer,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                BodySmallText(
                  'Tap to reveal answer',
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(FlashCard card) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              child: BodyLargeText(
                card.back,
                textAlign: TextAlign.center,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          if (card.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: card.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LabelSmallText(
                  tag,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              )).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildShowAnswerButton() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: FilledButton(
        onPressed: _isFlipping ? null : _showAnswerMethod,
        style: FilledButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility_rounded),
            const SizedBox(width: 12),
            const Text('Show Answer'),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          BodyMediumText(
            'How well did you know this?',
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildReviewButton(
                  label: 'Again',
                  color: Theme.of(context).colorScheme.error,
                  icon: Icons.close_rounded,
                  result: ReviewResult.again,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReviewButton(
                  label: 'Hard',
                  color: Theme.of(context).colorScheme.tertiary,
                  icon: Icons.trending_down_rounded,
                  result: ReviewResult.hard,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReviewButton(
                  label: 'Good',
                  color: Theme.of(context).colorScheme.primary,
                  icon: Icons.check_rounded,
                  result: ReviewResult.good,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildReviewButton(
                  label: 'Easy',
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icons.trending_up_rounded,
                  result: ReviewResult.easy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewButton({
    required String label,
    required Color color,
    required IconData icon,
    required ReviewResult result,
  }) {
    return FilledButton(
      onPressed: _isFlipping ? null : () => _reviewCard(result),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
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
              size: 80,
              color: _errorMessage == 'No cards due for review'
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              _errorMessage == 'No cards due for review'
                  ? 'All Caught Up!'
                  : 'Error',
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              _errorMessage == 'No cards due for review'
                  ? 'No cards are due for review at the moment. Come back later to continue studying.'
                  : _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _errorMessage == 'No cards due for review'
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