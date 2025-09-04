import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../domain/models/flashcard.dart';
import 'widgets/review/flashcard_display_widget.dart';
import 'widgets/review/flashcard_completion_dialog.dart';
import 'widgets/review/flashcard_review_buttons.dart';
import 'cubit/flashcard_review_cubit.dart';

class FlashcardReviewPage extends StatelessWidget {
  final FlashCardDeck deck;

  const FlashcardReviewPage({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              FlashcardReviewCubit()
                ..initialize()
                ..startReviewSession(deck.id),
      child: _FlashcardReviewPageView(deck: deck),
    );
  }
}

class _FlashcardReviewPageView extends StatefulWidget {
  final FlashCardDeck deck;

  const _FlashcardReviewPageView({required this.deck});

  @override
  State<_FlashcardReviewPageView> createState() =>
      _FlashcardReviewPageViewState();
}

class _FlashcardReviewPageViewState extends State<_FlashcardReviewPageView>
    with SingleTickerProviderStateMixin {
  bool _showAnswer = false;

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
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
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

  Future<void> _reviewCard(FlashCard card, ReviewResult result) async {
    await context.read<FlashcardReviewCubit>().reviewCard(
      card: card,
      result: result,
    );
    // Reset animation state after review
    await _nextCard();
  }

  Future<void> _nextCard() async {
    if (_isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    await _flipController.reverse();

    setState(() {
      _showAnswer = false;
      _isFlipping = false;
    });
  }

  void _showCompletionDialog(FlashcardReviewState state) {
    context.read<FlashcardReviewCubit>().completeReviewSession();
    FlashcardCompletionDialog.show(
      context: context,
      cards: state.cards,
      sessionCorrectAnswers: state.sessionCorrectAnswers,
      currentSession: state.currentSession,
      onComplete: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlashcardReviewCubit, FlashcardReviewState>(
      listener: (context, state) {
        if (state.errorMsg != null) {
          AppSnackBar.showError(context, state.errorMsg!);
          // Clear the message after showing it
          Future.microtask(
            () => context.read<FlashcardReviewCubit>().clearMessages(),
          );
        }
        if (state.isSessionCompleted) {
          _showCompletionDialog(state);
        }
      },
      child: BlocBuilder<FlashcardReviewCubit, FlashcardReviewState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: TitleMediumText(widget.deck.name),
                backgroundColor: Colors.transparent,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

          if (state.errorMsg != null) {
            return Scaffold(
              appBar: AppBar(
                title: TitleMediumText(widget.deck.name),
                backgroundColor: Colors.transparent,
              ),
              body: _buildErrorState(state.errorMsg!),
            );
          }

          if (state.cards.isEmpty) {
            return Scaffold(
              appBar: AppBar(
                title: TitleMediumText(widget.deck.name),
                backgroundColor: Colors.transparent,
              ),
              body: _buildEmptyState(),
            );
          }

          final currentCard = state.currentCard;
          if (currentCard == null) {
            return Scaffold(
              appBar: AppBar(
                title: TitleMediumText(widget.deck.name),
                backgroundColor: Colors.transparent,
              ),
              body: const Center(child: CircularProgressIndicator()),
            );
          }

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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: LabelMediumText(
                    '${state.currentCardIndex + 1}/${state.cards.length}',
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
                    value: state.progress,
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
                  onReviewCard: (result) => _reviewCard(currentCard, result),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              errorMessage == 'No cards due for review'
                  ? Icons.check_circle_outline
                  : Icons.error_outline,
              size: 64,
              color:
                  errorMessage == 'No cards due for review'
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              errorMessage == 'No cards due for review'
                  ? 'All Caught Up!'
                  : 'Error',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              errorMessage == 'No cards due for review'
                  ? 'No cards are due for review at the moment. Come back later to continue studying.'
                  : errorMessage,
              textAlign: TextAlign.center,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed:
                  errorMessage == 'No cards due for review'
                      ? () => Navigator.pop(context)
                      : () => context
                          .read<FlashcardReviewCubit>()
                          .startReviewSession(widget.deck.id),
              icon: Icon(
                errorMessage == 'No cards due for review'
                    ? Icons.arrow_back
                    : Icons.refresh,
              ),
              label: Text(
                errorMessage == 'No cards due for review'
                    ? 'Back to Flashcards'
                    : 'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.style_outlined,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              'No Cards Found',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              'This deck doesn\'t have any cards to review.',
              textAlign: TextAlign.center,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Flashcards'),
            ),
          ],
        ),
      ),
    );
  }
}
