import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/app_snackbar_widget.dart';
import '../../../domain/models/flashcard.dart';
import '../../../data/services/flashcard_service.dart';

class CardEditDialogWidget extends StatefulWidget {
  final FlashCard? card;
  final String deckId;
  final VoidCallback onSaved;

  const CardEditDialogWidget({
    super.key,
    this.card,
    required this.deckId,
    required this.onSaved,
  });

  @override
  State<CardEditDialogWidget> createState() => _CardEditDialogWidgetState();

  static void show(
    BuildContext context, {
    FlashCard? card,
    required String deckId,
    required VoidCallback onSaved,
  }) {
    showDialog(
      context: context,
      builder: (context) => CardEditDialogWidget(
        card: card,
        deckId: deckId,
        onSaved: onSaved,
      ),
    );
  }
}

class _CardEditDialogWidgetState extends State<CardEditDialogWidget> {
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
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        widget.card == null ? AppLocalizations.of(context)!.addCard : AppLocalizations.of(context)!.editCard,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
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
                    labelText: '${AppLocalizations.of(context)!.question} (${AppLocalizations.of(context)!.cardFront})',
                    hintText: AppLocalizations.of(context)!.enterYourAnswer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.help_outline_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.fullNameRequired.replaceAll('full name', AppLocalizations.of(context)!.question.toLowerCase());
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _backController,
                  decoration: InputDecoration(
                    labelText: '${AppLocalizations.of(context)!.answer} (${AppLocalizations.of(context)!.cardBack})',
                    hintText: AppLocalizations.of(context)!.enterYourAnswer,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.lightbulb_outline_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.fullNameRequired.replaceAll('full name', AppLocalizations.of(context)!.answer.toLowerCase());
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hintController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.cardHint,
                    hintText: AppLocalizations.of(context)!.hint,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.tips_and_updates_outlined,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.cardTags,
                    hintText: AppLocalizations.of(context)!.tagsExample,
                    helperText: AppLocalizations.of(context)!.separateTagsComma,
                    helperStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.secondary,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.local_offer_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
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
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveCard,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.secondary,
            foregroundColor: Theme.of(context).colorScheme.onSecondary,
          ),
          child: _isLoading 
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              )
            : Text(
                widget.card == null ? AppLocalizations.of(context)!.addCard : AppLocalizations.of(context)!.save,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
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
          AppSnackBar.showSuccess(context, AppLocalizations.of(context)!.addedFlashcards(1, ''));
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
          AppSnackBar.showSuccess(context, AppLocalizations.of(context)!.deckUpdatedSuccessfully);
        }
      }

      if (mounted) {
        Navigator.pop(context);
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        AppSnackBar.showError(context, AppLocalizations.of(context)!.somethingWentWrong);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}