import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/app_snackbar_widget.dart';
import '../../../data/services/flashcard_service.dart';
import '../../../domain/models/flashcard.dart';
import '../../../domain/models/study_material.dart';
import '../../../domain/models/quiz.dart';
import '../../flashcard_review_page.dart';
import 'flashcard_deck_creation_dialog_widget.dart';

class FlashcardsTab extends StatefulWidget {
  final List<StudyMaterial> studyMaterials;
  final Function(List<StudyMaterial>, String, String?) onGenerateFromMaterials;
  final Function(Quiz, String?, String?) onGenerateFromQuiz;

  const FlashcardsTab({
    super.key,
    required this.studyMaterials,
    required this.onGenerateFromMaterials,
    required this.onGenerateFromQuiz,
  });

  @override
  State<FlashcardsTab> createState() => _FlashcardsTabState();
}

class _FlashcardsTabState extends State<FlashcardsTab> {
  final FlashcardService _flashcardService = FlashcardService();
  List<FlashCardDeck> _decks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      log(
        'FlashcardsTab: Initializing flashcard service...',
        name: 'FlashcardsTab',
      );
      await _flashcardService.initialize();
      log(
        'FlashcardsTab: Service initialized, loading decks...',
        name: 'FlashcardsTab',
      );
      await _loadDecks();
    } catch (e) {
      log(
        'FlashcardsTab: Error during initialization: $e',
        name: 'FlashcardsTab',
        error: e,
      );
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadDecks() async {
    try {
      log('FlashcardsTab: Starting to load decks...', name: 'FlashcardsTab');
      setState(() => _isLoading = true);
      final decks = await _flashcardService.getUserDecks();
      log('FlashcardsTab: Loaded ${decks.length} decks', name: 'FlashcardsTab');
      if (mounted) {
        setState(() {
          _decks = decks;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      log(
        'FlashcardsTab: Error loading decks: $e',
        name: 'FlashcardsTab',
        error: e,
      );
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      onRefresh: _loadDecks,
      child: CustomScrollView(
        slivers: [
          // Header with stats
          SliverToBoxAdapter(child: _buildHeader()),

          // Quick actions
          SliverToBoxAdapter(child: _buildQuickActions()),

          // Decks list or empty state
          if (_decks.isEmpty)
            SliverFillRemaining(child: _buildEmptyState())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildDeckCard(_decks[index]),
                  childCount: _decks.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final totalCards = _decks.fold<int>(
      0,
      (sum, deck) => sum + (deck.cardCount),
    );
    final dueCards = _decks.fold<int>(
      0,
      (sum, deck) => sum + (deck.dueCardCount),
    );

    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(
              context,
            ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.style_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeadlineSmallText(
                      AppLocalizations.of(context)!.flashcardsTab,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodyMediumText(
                      'Review with spaced repetition',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                icon: FontAwesomeIcons.layerGroup,
                label: '${_decks.length} Decks',
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              _buildStatChip(
                icon: FontAwesomeIcons.clone,
                label: '$totalCards Cards',
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(width: 12),
              if (dueCards > 0)
                _buildStatChip(
                  icon: FontAwesomeIcons.clock,
                  label: '$dueCards Due',
                  color: Theme.of(context).colorScheme.error,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          LabelSmallText(label, color: color, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleMediumText(
            'Quick Actions',
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.add_rounded,
                  label: 'Create Deck',
                  onTap: _showCreateDeckDialog,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Generate AI',
                  onTap: _showGenerateDialog,
                  enabled: widget.studyMaterials.isNotEmpty,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                enabled
                    ? Theme.of(context).colorScheme.surface
                    : Theme.of(
                      context,
                    ).colorScheme.surface.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color:
                    enabled
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 8),
              LabelMediumText(
                label,
                color:
                    enabled
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeckCard(FlashCardDeck deck) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openDeck(deck),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getDeckColor(deck.color),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TitleSmallText(
                      deck.name,
                      fontWeight: FontWeight.w600,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_vert,
                      size: 20,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    onSelected: (value) => _handleDeckAction(deck, value),
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete'),
                          ),
                        ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (deck.description != null && deck.description!.isNotEmpty)
                Expanded(
                  child: BodySmallText(
                    deck.description!,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              else
                const Spacer(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LabelSmallText(
                    '${deck.cardCount} cards',
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  if (deck.dueCardCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${deck.dueCardCount} due',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 300),
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
                'No Flashcards Yet',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              BodyMediumText(
                'Create your first flashcard deck or generate one from your study materials.',
                textAlign: TextAlign.center,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed:
                    widget.studyMaterials.isNotEmpty
                        ? _showGenerateDialog
                        : _showCreateDeckDialog,
                icon: Icon(
                  widget.studyMaterials.isNotEmpty
                      ? Icons.auto_awesome_rounded
                      : Icons.add_rounded,
                ),
                label: Text(
                  widget.studyMaterials.isNotEmpty
                      ? 'Generate AI Flashcards'
                      : 'Create Deck',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 300),
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
                'Error Loading Flashcards',
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 8),
              BodyMediumText(
                _errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _loadDecks,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDeckColor(String? colorString) {
    // Simple color parsing - you could expand this
    switch (colorString) {
      case 'blue':
        return Colors.blue;
      case 'red':
        return Colors.red;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.secondary;
    }
  }

  void _showCreateDeckDialog() {
    showDialog(
      context: context,
      builder:
          (context) => FlashcardDeckCreationDialogWidget(
            onCreateDeck: _createManualDeck,
          ),
    );
  }

  void _showGenerateDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleMediumText(
                  'Generate AI Flashcards',
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Icon(
                    Icons.library_books,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('From Study Materials'),
                  subtitle: Text(
                    '${widget.studyMaterials.length} materials available',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _generateFromMaterials();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.quiz,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('From Recent Quiz'),
                  subtitle: const Text('Convert quiz questions to flashcards'),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Show quiz selection dialog
                    _showQuizSelectionDialog();
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
    );
  }

  void _generateFromMaterials() {
    // Use the callback to integrate with StudyCubit if needed
    widget.onGenerateFromMaterials(
      widget.studyMaterials,
      'AI Flashcards: ${DateTime.now().day}/${DateTime.now().month}',
      null,
    );
  }

  void _showQuizSelectionDialog() {
    // TODO: Implement quiz selection dialog
    AppSnackBar.showInfo(context, 'Quiz selection coming soon!');
  }

  Future<void> _createManualDeck({
    required String name,
    String? description,
    String? color,
  }) async {
    try {
      await _flashcardService.createDeck(
        name: name,
        description: description,
        color: color,
      );

      await _loadDecks();

      if (mounted) {
        AppSnackBar.showSuccess(context, 'Deck created successfully!');
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(
          context,
          'Failed to create deck: ${e.toString()}',
        );
      }
    }
  }

  void _openDeck(FlashCardDeck deck) {
    // Navigate to deck view/review
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FlashcardReviewPage(deck: deck)),
    );
  }

  void _handleDeckAction(FlashCardDeck deck, String action) async {
    switch (action) {
      case 'edit':
        // TODO: Show edit deck dialog
        AppSnackBar.showInfo(context, 'Edit deck coming soon!');
        break;
      case 'delete':
        final confirmed = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Delete Deck'),
                content: Text(
                  'Are you sure you want to delete "${deck.name}"? This action cannot be undone.',
                ),
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
            await _flashcardService.deleteDeck(deck.id);
            await _loadDecks();
            if (mounted) {
              AppSnackBar.showSuccess(context, 'Deck deleted successfully');
            }
          } catch (e) {
            if (mounted) {
              AppSnackBar.showError(context, 'Failed to delete deck');
            }
          }
        }
        break;
    }
  }
}
