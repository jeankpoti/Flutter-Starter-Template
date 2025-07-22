import 'package:flutter/material.dart';

class MathSymbolsWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String symbol)? onSymbolTap;

  const MathSymbolsWidget({
    super.key,
    required this.controller,
    this.onSymbolTap,
  });

  static const List<List<String>> symbolGroups = [
    // Basic operations
    ['+', '-', '×', '÷', '=', '≠', '≈'],
    // Powers and roots
    ['x²', 'x³', 'xⁿ', '√', '∛', '∜'],
    // Fractions and parentheses
    ['½', '¼', '¾', '(', ')', '[', ']'],
    // Comparison and logic
    ['<', '>', '≤', '≥', '∞', '∑', '∏'],
    // Greek letters (common in math)
    ['π', 'θ', 'α', 'β', 'γ', 'δ', 'λ'],
    // Special symbols
    ['°', '%', '±', '∆', '∫', '∂', 'log'],
  ];

  void _insertSymbol(String symbol) {
    final text = controller.text;
    final selection = controller.selection;
    
    String newSymbol = symbol;
    
    // Handle special cases for superscript
    if (symbol == 'x²') {
      newSymbol = '^2';
    } else if (symbol == 'x³') {
      newSymbol = '^3';
    } else if (symbol == 'xⁿ') {
      newSymbol = '^n';
    }
    
    // Handle invalid selection positions
    int startPos = selection.start;
    int endPos = selection.end;
    
    // If no valid selection, insert at the end
    if (startPos < 0 || endPos < 0 || startPos > text.length || endPos > text.length) {
      startPos = text.length;
      endPos = text.length;
    }
    
    final newText = text.replaceRange(
      startPos,
      endPos,
      newSymbol,
    );
    
    controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: startPos + newSymbol.length,
      ),
    );
    
    // Call the callback if provided
    onSymbolTap?.call(newSymbol);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Math Symbols',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(
                Icons.calculate_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...symbolGroups.map((group) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: group.map((symbol) => _buildSymbolButton(context, symbol)).toList(),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSymbolButton(BuildContext context, String symbol) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.0),
        child: InkWell(
          onTap: () => _insertSymbol(symbol),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                width: 0.5,
              ),
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}