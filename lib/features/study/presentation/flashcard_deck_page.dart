import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../domain/models/flashcard.dart';
import 'flashcard_review_page.dart';
import 'widgets/deck/deck_stats_header_widget.dart';
import 'widgets/deck/flashcard_item_widget.dart';
import 'widgets/deck/card_edit_dialog_widget.dart';
import 'widgets/deck/flashcard_generation_preview_dialog_widget.dart';
import 'widgets/deck/flashcard_options_modal_widget.dart';
import 'widgets/study/flashcard_deck_edit_dialog_widget.dart';
import 'cubit/flashcard_deck_cubit.dart';
import 'cubit/flashcard_cubit.dart';
import 'cubit/flashcard_generation_cubit.dart';
import '../data/repository/flashcard_generation_repository_impl.dart';
import '../data/services/flashcard_generation_service.dart';

class FlashcardDeckPage extends StatelessWidget {
  final FlashCardDeck deck;

  const FlashcardDeckPage({super.key, required this.deck});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => FlashcardDeckCubit()
            ..initialize()
            ..loadCards(deck.id),
        ),
        BlocProvider(create: (context) => FlashcardCubit()),
        BlocProvider(
          create: (context) => FlashcardGenerationCubit(
            FlashcardGenerationRepositoryImpl(FlashcardGenerationService()),
          ),
        ),
      ],
      child: _FlashcardDeckPageView(deck: deck),
    );
  }
}

class _FlashcardDeckPageView extends StatefulWidget {
  final FlashCardDeck deck;

  const _FlashcardDeckPageView({required this.deck});

  @override
  State<_FlashcardDeckPageView> createState() => _FlashcardDeckPageViewState();
}

class _FlashcardDeckPageViewState extends State<_FlashcardDeckPageView> {
  FlashcardDeckCubit? _flashcardDeckCubit;
  FlashcardCubit? _flashcardCubit;
  FlashcardGenerationCubit? _generationCubit;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _flashcardDeckCubit = context.read<FlashcardDeckCubit>();
    _flashcardCubit = context.read<FlashcardCubit>();
    _generationCubit = context.read<FlashcardGenerationCubit>();
  }

  @override
  void dispose() {
    _flashcardDeckCubit = null;
    _flashcardCubit = null;
    _generationCubit = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FlashcardDeckCubit, FlashcardDeckState>(
          listener: (context, state) {
            if (state.errorMsg != null) {
              AppSnackBar.showError(context, state.errorMsg!);
              if (mounted && _flashcardDeckCubit != null) {
                _flashcardDeckCubit!.clearMessages();
              }
            }
          },
        ),
        BlocListener<FlashcardGenerationCubit, FlashcardGenerationState>(
          listener: (context, state) {
            if (state.errorMsg != null) {
              AppSnackBar.showError(context, state.errorMsg!);
              if (mounted && _generationCubit != null) {
                _generationCubit!.clearMessages();
              }
            }
            if (state.isSuccess && state.generatedCards.isNotEmpty) {
              _showGenerationPreview(state.generatedCards);
            }
          },
        ),
      ],
      child: BlocBuilder<FlashcardDeckCubit, FlashcardDeckState>(
        builder: (context, state) => Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: _buildAppBar(),
          body: _buildBody(state),
          floatingActionButton: state.cards.isNotEmpty ? _buildFAB() : null,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleMediumText(
            widget.deck.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.deck.description?.isNotEmpty == true)
            BodySmallText(
              widget.deck.description!,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          onPressed: _showAddCardOptions,
          icon: Icon(
            Icons.add_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          tooltip: 'Add Card',
        ),
        PopupMenuButton<String>(
          onSelected: _handleDeckAction,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit_deck',
              child: ListTile(
                leading: Icon(Icons.edit_rounded),
                title: Text('Edit Deck'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'study',
              child: ListTile(
                leading: Icon(Icons.school_rounded),
                title: Text('Study Cards'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBody(FlashcardDeckState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMsg != null) {
      return _buildErrorState(state.errorMsg!);
    }

    if (state.cards.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _flashcardDeckCubit?.loadCards(widget.deck.id) ?? Future.value(),
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: DeckStatsHeaderWidget(cards: state.cards),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => FlashcardItemWidget(
                  card: state.cards[index],
                  onTap: () => _showEditCardDialog(state.cards[index]),
                  onCardAction: (action) => _handleCardAction(state.cards[index], action),
                ),
                childCount: state.cards.length,
              ),
            ),
          ),
        ],
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
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              'No Cards Yet',
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              'Add your first flashcard to start studying.',
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _showAddCardOptions,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              icon: Icon(
                Icons.add_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              label: Text(
                'Add Card',
                style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
            ),
          ],
        ),
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
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            HeadlineSmallText(
              'Error Loading Cards',
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              errorMessage,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _flashcardDeckCubit?.loadCards(widget.deck.id),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return BlocBuilder<FlashcardGenerationCubit, FlashcardGenerationState>(
      builder: (context, generationState) {
        if (generationState.isLoading) {
          return FloatingActionButton(
            onPressed: null,
            backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        return FloatingActionButton.extended(
          onPressed: () => _startReview(),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          foregroundColor: Theme.of(context).colorScheme.onSecondary,
          icon: const Icon(Icons.school_rounded),
          label: const Text('Study'),
        );
      },
    );
  }

  void _showAddCardOptions() {
    FlashcardOptionsModalWidget.show(
      context,
      onManual: _showManualCardDialog,
      onCamera: () => _generationCubit?.generateFromCamera(),
      onGallery: () => _generationCubit?.generateFromGallery(),
      onFile: () => _generationCubit?.generateFromFile(),
    );
  }

  void _showManualCardDialog() {
    CardEditDialogWidget.show(
      context,
      deckId: widget.deck.id,
      onSaved: () => _flashcardDeckCubit?.loadCards(widget.deck.id),
    );
  }

  void _showEditCardDialog(FlashCard card) {
    CardEditDialogWidget.show(
      context,
      card: card,
      deckId: widget.deck.id,
      onSaved: () => _flashcardDeckCubit?.loadCards(widget.deck.id),
    );
  }

  void _showGenerationPreview(List<FlashcardContent> generatedCards) {
    if (!mounted) return;
    
    FlashcardGenerationPreviewDialogWidget.show(
      context,
      generatedCards: generatedCards,
      deckId: widget.deck.id,
      onSaved: () {
        _flashcardDeckCubit?.loadCards(widget.deck.id);
        _generationCubit?.clearGeneratedCards();
      },
    );
  }

  void _showEditDeckDialog() {
    showDialog(
      context: context,
      builder: (context) => FlashcardDeckEditDialogWidget(
        deck: widget.deck,
        onUpdateDeck: ({required String name, String? description, String? color}) async {
          await _flashcardCubit?.updateDeck(
            deck: widget.deck,
            name: name,
            description: description,
            color: color,
          );
          
          if (mounted) {
            AppSnackBar.showSuccess(context, 'Deck updated successfully!');
            Navigator.of(context).pop();
          }
        },
      ),
    );
  }

  void _handleDeckAction(String action) {
    switch (action) {
      case 'edit_deck':
        _showEditDeckDialog();
        break;
      case 'study':
        _startReview();
        break;
    }
  }

  void _handleCardAction(FlashCard card, String action) async {
    switch (action) {
      case 'edit':
        _showEditCardDialog(card);
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Card'),
            content: const Text('Are you sure you want to delete this flashcard? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirmed == true && mounted) {
          await _flashcardDeckCubit?.deleteCard(card.id, widget.deck.id);
          if (mounted) {
            AppSnackBar.showSuccess(context, 'Card deleted successfully');
          }
        }
        break;
    }
  }

  void _startReview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FlashcardReviewPage(deck: widget.deck),
      ),
    );
  }
}