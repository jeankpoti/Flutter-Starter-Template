import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';

class FlashcardDeckCreationDialogWidget extends StatefulWidget {
  final Function({required String name, String? description, String? color}) onCreateDeck;

  const FlashcardDeckCreationDialogWidget({
    super.key,
    required this.onCreateDeck,
  });

  @override
  State<FlashcardDeckCreationDialogWidget> createState() => _FlashcardDeckCreationDialogWidgetState();
}

class _FlashcardDeckCreationDialogWidgetState extends State<FlashcardDeckCreationDialogWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedColor;

  final List<Map<String, dynamic>> _colors = [
    {'name': 'Blue', 'value': 'blue', 'color': Colors.blue},
    {'name': 'Red', 'value': 'red', 'color': Colors.red},
    {'name': 'Green', 'value': 'green', 'color': Colors.green},
    {'name': 'Orange', 'value': 'orange', 'color': Colors.orange},
    {'name': 'Purple', 'value': 'purple', 'color': Colors.purple},
    {'name': 'Teal', 'value': 'teal', 'color': Colors.teal},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleMediumText(
        'Create New Deck',
        fontWeight: FontWeight.bold,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Deck Name',
                hintText: 'Enter deck name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.style),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a deck name';
                }
                return null;
              },
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
            
            const SizedBox(height: 12),
            
            // Description field
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Brief description of the deck',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 2,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
            ),
            
            const SizedBox(height: 12),
            
            // Color selection
            LabelMediumText(
              'Deck Color (Optional)',
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _colors.map((colorData) {
                final isSelected = _selectedColor == colorData['value'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = isSelected ? null : colorData['value'];
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorData['color'],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          )
                        : null,
                  ),
                );
              }).toList(),
              ),
            ],
          ),
        ),
      ),
    ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: _createDeck,
          child: const Text('Create Deck'),
        ),
      ],
    );
  }

  void _createDeck() {
    if (_formKey.currentState!.validate()) {
      widget.onCreateDeck(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
        color: _selectedColor,
      );
      Navigator.pop(context);
    }
  }
}