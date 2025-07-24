import 'package:flutter/material.dart';

class MathKeyboardWidget extends StatelessWidget {
  final Function(String) onSymbolTapped;
  final VoidCallback? onClear;
  final VoidCallback? onBackspace;

  const MathKeyboardWidget({
    super.key,
    required this.onSymbolTapped,
    this.onClear,
    this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Math Symbols',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.keyboard_hide),
                tooltip: 'Hide keyboard',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Basic Operations
          _buildSymbolRow(context, 'Basic', [
            '+', '−', '×', '÷', '=', '≠', '≈', '∞'
          ]),
          
          // Fractions and Powers
          _buildSymbolRow(context, 'Powers', [
            '½', '⅓', '¼', '¾', '²', '³', 'ⁿ', '√'
          ]),
          
          // Comparison and Logic
          _buildSymbolRow(context, 'Compare', [
            '<', '>', '≤', '≥', '±', '∓', '∝', '∴'
          ]),
          
          // Greek Letters (common in math)
          _buildSymbolRow(context, 'Greek', [
            'π', 'θ', 'α', 'β', 'γ', 'δ', 'λ', 'μ'
          ]),
          
          // Geometry and Trigonometry
          _buildSymbolRow(context, 'Geometry', [
            '°', '∠', '⊥', '∥', '△', '○', '∴', '∵'
          ]),
          
          // Set Theory and Logic
          _buildSymbolRow(context, 'Sets', [
            '∈', '∉', '⊂', '⊃', '∪', '∩', '∅', '∀'
          ]),
          
          const SizedBox(height: 16),
          
          // Action buttons
          Row(
            children: [
              if (onBackspace != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onBackspace,
                    icon: const Icon(Icons.backspace_outlined),
                    label: const Text('Backspace'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              if (onBackspace != null && onClear != null)
                const SizedBox(width: 12),
              if (onClear != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolRow(BuildContext context, String category, List<String> symbols) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 8),
          child: Text(
            category,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: symbols.length,
            itemBuilder: (context, index) {
              final symbol = symbols[index];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: Material(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: InkWell(
                    onTap: () => onSymbolTapped(symbol),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        symbol,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Extension to show math keyboard as a bottom sheet
extension MathKeyboardExtension on BuildContext {
  Future<void> showMathKeyboard({
    required Function(String) onSymbolTapped,
    VoidCallback? onClear,
    VoidCallback? onBackspace,
  }) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MathKeyboardWidget(
        onSymbolTapped: onSymbolTapped,
        onClear: onClear,
        onBackspace: onBackspace,
      ),
    );
  }
}