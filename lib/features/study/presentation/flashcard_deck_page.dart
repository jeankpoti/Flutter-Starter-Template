import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../domain/models/flashcard.dart';
import '../data/services/flashcard_service.dart';
import 'flashcard_review_page.dart';

class FlashcardDeckPage extends StatefulWidget {
  final FlashCardDeck deck;

  const FlashcardDeckPage({
    super.key,
    required this.deck,
  });

  @override
  State<FlashcardDeckPage> createState() => _FlashcardDeckPageState();
}

class _FlashcardDeckPageState extends State<FlashcardDeckPage> {
  final FlashcardService _flashcardService = FlashcardService();
  List<FlashCard> _cards = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    try {
      await _flashcardService.initialize();
      await _loadCards();
    } catch (e) {
      dev.log('FlashcardDeckPage: Error initializing: $e', name: 'FlashcardDeckPage', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadCards() async {
    try {
      setState(() => _isLoading = true);
      final cards = await _flashcardService.getAllCardsInDeck(widget.deck.id);
      dev.log('FlashcardDeckPage: Loaded ${cards.length} cards', name: 'FlashcardDeckPage');
      
      if (mounted) {
        setState(() {
          _cards = cards;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      dev.log('FlashcardDeckPage: Error loading cards: $e', name: 'FlashcardDeckPage', error: e);
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  /// Helper method to render text with math expressions
  Widget _buildMathText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    Color? color,
    FontWeight? fontWeight,
    int? maxLines,
  }) {
    final mathRegex = RegExp(r'\$([^$]+)\$');
    final matches = mathRegex.allMatches(text);
    
    if (matches.isEmpty) {
      return Text(
        text,
        style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
               TextStyle(color: color, fontWeight: fontWeight),
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxLines,
        overflow: maxLines != null ? TextOverflow.ellipsis : null,
      );
    }

    List<InlineSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, match.start),
          style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                 TextStyle(color: color, fontWeight: fontWeight),
        ));
      }

      final mathExpression = match.group(1) ?? '';
      try {
        spans.add(WidgetSpan(
          child: Math.tex(
            mathExpression,
            textStyle: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                       TextStyle(color: color, fontWeight: fontWeight),
            mathStyle: MathStyle.text,
          ),
          alignment: PlaceholderAlignment.middle,
        ));
      } catch (e) {
        spans.add(TextSpan(
          text: '\$${mathExpression}\$',
          style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
                 TextStyle(color: color, fontWeight: fontWeight),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style?.copyWith(color: color, fontWeight: fontWeight) ?? 
               TextStyle(color: color, fontWeight: fontWeight),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: textAlign ?? TextAlign.start,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TitleMediumText(
              widget.deck.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.deck.description != null && widget.deck.description!.isNotEmpty)
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
            onPressed: _showAddCardDialog,
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Card',
          ),
          PopupMenuButton<String>(
            onSelected: _handleDeckAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit_deck',
                child: ListTile(
                  leading: Icon(Icons.edit_rounded),
                  title: Text('Edit Deck'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
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
      ),
      body: _buildBody(),
      floatingActionButton: _cards.isNotEmpty ? FloatingActionButton.extended(
        onPressed: () => _startReview(),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
        icon: const Icon(Icons.school_rounded),
        label: const Text('Study'),
      ) : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    if (_cards.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadCards,
      child: CustomScrollView(
        slivers: [
          // Deck stats header
          SliverToBoxAdapter(
            child: _buildStatsHeader(),
          ),
          
          // Cards list
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCardItem(_cards[index]),
                childCount: _cards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    final newCards = _cards.where((c) => c.isNew).length;
    final dueCards = _cards.where((c) => c.isDue && !c.isNew).length;
    final learningCards = _cards.length - newCards - dueCards;

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.analytics_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleLargeText(
                      '${_cards.length}',
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    BodyMediumText(
                      'Total Cards',
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildStatChip('New', newCards, Colors.blue)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatChip('Due', dueCards, Colors.orange)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatChip('Learning', learningCards, Colors.green)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          TitleSmallText(
            count.toString(),
            color: color,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          LabelSmallText(
            label,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(FlashCard card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEditCardDialog(card),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header with status
                Row(
                  children: [
                    _buildCardStatusChip(card),
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleCardAction(card, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_rounded),
                            title: Text('Edit'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_rounded),
                            title: Text('Delete'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Card content preview
                _buildMathText(
                  card.front,
                  style: Theme.of(context).textTheme.bodyLarge,
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 8),
                
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _buildMathText(
                    card.back,
                    style: Theme.of(context).textTheme.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    maxLines: 2,
                  ),
                ),
                
                // Tags
                if (card.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: card.tags.take(3).map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: LabelSmallText(
                        tag,
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    )).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardStatusChip(FlashCard card) {
    Color color;
    String label;
    
    if (card.isNew) {
      color = Colors.blue;
      label = 'New';
    } else if (card.isDue) {
      color = Colors.orange;
      label = 'Due';
    } else {
      color = Colors.green;
      label = 'Learning';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LabelSmallText(
        label,
        color: color,
        fontWeight: FontWeight.w600,
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
              onPressed: _showAddCardDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Card'),
            ),
          ],
        ),
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
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadCards,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCardDialog() {
    _showCardDialog();
  }

  void _showEditCardDialog(FlashCard card) {
    _showCardDialog(card: card);
  }

  void _showCardDialog({FlashCard? card}) {
    showDialog(
      context: context,
      builder: (context) => _CardEditDialog(
        card: card,
        deckId: widget.deck.id,
        onSaved: _loadCards,
      ),
    );
  }

  void _handleDeckAction(String action) async {
    switch (action) {
      case 'edit_deck':
        // TODO: Show edit deck dialog
        AppSnackBar.showInfo(context, 'Edit deck coming soon!');
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

        if (confirmed == true) {
          try {
            await _flashcardService.deleteCard(card.id);
            await _loadCards();
            if (mounted) {
              AppSnackBar.showSuccess(context, 'Card deleted successfully');
            }
          } catch (e) {
            if (mounted) {
              AppSnackBar.showError(context, 'Failed to delete card');
            }
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

class _CardEditDialog extends StatefulWidget {
  final FlashCard? card;
  final String deckId;
  final VoidCallback onSaved;

  const _CardEditDialog({
    this.card,
    required this.deckId,
    required this.onSaved,
  });

  @override
  State<_CardEditDialog> createState() => _CardEditDialogState();
}

class _CardEditDialogState extends State<_CardEditDialog> {
  final _frontController = TextEditingController();
  final _backController = TextEditingController();
  final _hintController = TextEditingController();
  final _tagsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.card != null) {
      _frontController.text = widget.card!.front;
      _backController.text = widget.card!.back;
      _hintController.text = widget.card!.hint ?? '';
      _tagsController.text = widget.card!.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    _hintController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.card == null ? 'Add Flashcard' : 'Edit Flashcard'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _frontController,
                  decoration: InputDecoration(
                    labelText: 'Question (Front)',
                    hintText: 'Enter the question or prompt',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.help_outline_rounded),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a question';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backController,
                  decoration: InputDecoration(
                    labelText: 'Answer (Back)',
                    hintText: 'Enter the answer or explanation',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.lightbulb_outline_rounded),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an answer';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hintController,
                  decoration: InputDecoration(
                    labelText: 'Hint (Optional)',
                    hintText: 'Enter a helpful hint',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.tips_and_updates_outlined),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (Optional)',
                    hintText: 'algebra, geometry, calculus',
                    helperText: 'Separate tags with commas',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.local_offer_rounded),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveCard,
          child: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.card == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final flashcardService = FlashcardService();
      await flashcardService.initialize();

      final front = _frontController.text.trim();
      final back = _backController.text.trim();
      final hint = _hintController.text.trim().isEmpty ? null : _hintController.text.trim();
      final tags = _tagsController.text.trim().isEmpty 
          ? <String>[]
          : _tagsController.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      if (widget.card == null) {
        // Add new card
        await flashcardService.addCardToDeck(
          deckId: widget.deckId,
          front: front,
          back: back,
          hint: hint,
          tags: tags,
        );
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Card added successfully!');
        }
      } else {
        // Update existing card
        final updatedCard = widget.card!.copyWith(
          front: front,
          back: back,
          hint: hint,
          tags: tags,
        );
        await flashcardService.updateCard(updatedCard);
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Card updated successfully!');
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, 'Failed to save card: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}