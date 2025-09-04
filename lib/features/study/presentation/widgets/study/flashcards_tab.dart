import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/app_snackbar_widget.dart';
import '../../cubit/flashcard_cubit.dart';
import '../../../domain/models/flashcard.dart';
import '../../../domain/models/study_material.dart';
import '../../../domain/models/quiz.dart';
import '../../flashcard_review_page.dart';
import '../../flashcard_deck_page.dart';
import 'flashcard_deck_creation_dialog_widget.dart';
import 'flashcard_deck_edit_dialog_widget.dart';

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
  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  Future<void> _initializeAndLoad() async {
    final flashcardCubit = context.read<FlashcardCubit>();
    await flashcardCubit.initialize();
    await flashcardCubit.loadUserDecks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FlashcardCubit, FlashcardState>(
      listener: (context, state) {
        if (state.errorMsg != null) {
          AppSnackBar.showError(context, state.errorMsg!);
          // Clear the message after showing it
          Future.microtask(() {
            if (context.mounted) {
              context.read<FlashcardCubit>().clearMessages();
            }
          });
        }
        if (state.isSuccess) {
          // Success messages are shown contextually
          Future.microtask(() {
            if (context.mounted) {
              context.read<FlashcardCubit>().clearMessages();
            }
          });
        }
      },
      child: BlocBuilder<FlashcardCubit, FlashcardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.errorMsg != null) {
            return _buildErrorState(state.errorMsg!);
          }

          return RefreshIndicator(
            onRefresh: () => context.read<FlashcardCubit>().loadUserDecks(),
            child: CustomScrollView(
              slivers: [
                // Header with stats
                SliverToBoxAdapter(child: _buildHeader(state.decks)),

                // Quick actions
                SliverToBoxAdapter(child: _buildQuickActions()),

                // Decks list or empty state
                if (state.decks.isEmpty)
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
                        (context, index) => _buildDeckCard(state.decks[index]),
                        childCount: state.decks.length,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(List<FlashCardDeck> decks) {
    final totalCards = decks.fold<int>(
      0,
      (sum, deck) => sum + (deck.cardCount),
    );
    final dueCards = decks.fold<int>(
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
                label: '${decks.length} Decks',
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
                            value: 'manage',
                            child: ListTile(
                              leading: Icon(Icons.settings_rounded),
                              title: Text('Manage Cards'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'study',
                            child: ListTile(
                              leading: Icon(Icons.school_rounded),
                              title: Text('Study'),
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                              leading: Icon(Icons.edit_rounded),
                              title: Text('Edit Deck'),
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

  Widget _buildErrorState(String errorMessage) {
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
                errorMessage,
                textAlign: TextAlign.center,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.read<FlashcardCubit>().loadUserDecks(),
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

  void _showEditDeckDialog(FlashCardDeck deck) {
    showDialog(
      context: context,
      builder:
          (context) => FlashcardDeckEditDialogWidget(
            deck: deck,
            onUpdateDeck: ({required String name, String? description, String? color}) => _updateDeck(
              deck: deck,
              name: name,
              description: description,
              color: color,
            ),
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
                  title: const Text('From Selected Materials'),
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
                    Icons.auto_awesome_rounded,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: const Text('Generate with All Materials'),
                  subtitle: const Text('Create comprehensive flashcards from all study materials'),
                  onTap: () {
                    Navigator.pop(context);
                    _generateFromAllMaterials();
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

  void _generateFromAllMaterials() {
    // Generate flashcards from all available study materials
    widget.onGenerateFromMaterials(
      widget.studyMaterials,
      'Comprehensive Flashcards: ${DateTime.now().day}/${DateTime.now().month}',
      'Generated from all study materials',
    );
  }

  Future<void> _createManualDeck({
    required String name,
    String? description,
    String? color,
  }) async {
    await context.read<FlashcardCubit>().createDeck(
      name: name,
      description: description,
      color: color,
    );
    
    if (mounted) {
      AppSnackBar.showSuccess(context, 'Deck created successfully!');
    }
  }

  Future<void> _updateDeck({
    required FlashCardDeck deck,
    required String name,
    String? description,
    String? color,
  }) async {
    await context.read<FlashcardCubit>().updateDeck(
      deck: deck,
      name: name,
      description: description,
      color: color,
    );
    
    if (mounted) {
      AppSnackBar.showSuccess(context, 'Deck updated successfully!');
    }
  }

  void _openDeck(FlashCardDeck deck) {
    // Navigate to deck management page
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => FlashcardDeckPage(deck: deck)),
    );
  }

  void _handleDeckAction(FlashCardDeck deck, String action) async {
    switch (action) {
      case 'manage':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FlashcardDeckPage(deck: deck)),
        );
        break;
      case 'study':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => FlashcardReviewPage(deck: deck)),
        );
        break;
      case 'edit':
        _showEditDeckDialog(deck);
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
          await context.read<FlashcardCubit>().deleteDeck(deck.id);
          if (mounted) {
            AppSnackBar.showSuccess(context, 'Deck deleted successfully');
          }
        }
        break;
    }
  }
}
