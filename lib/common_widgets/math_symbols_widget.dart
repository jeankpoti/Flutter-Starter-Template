import 'package:flutter/material.dart';

class MathSymbolsWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String symbol)? onSymbolTap;

  const MathSymbolsWidget({
    super.key,
    required this.controller,
    this.onSymbolTap,
  });

  @override
  State<MathSymbolsWidget> createState() => _MathSymbolsWidgetState();
}

class _MathSymbolsWidgetState extends State<MathSymbolsWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  static const Map<String, List<String>> symbolCategories = {
    'Basic Math': [
      '+', '−', '×', '÷', '=', '≠', '≈',  // Basic Ops
      'x²', 'x³', 'xⁿ', '√', '³√', 'ⁿ√',  // Powers & Roots
      '½', '¼', '¾',  // Fractions
      '<', '>', '≤', '≥'  // Inequalities
    ],
    'Advanced': [
      'π', 'θ', 'α', 'β', 'γ', 'δ', 'λ',  // Greek
      'log', 'sin', 'cos', 'tan', 'ln',  // Functions
      '∈', '∅', '∪', '∩', '∑', '∏', '∫', '∞',  // Sets
      '°', 'Δ', '∠', '∥', '⊥',  // Geometry
      '⇒', '⇔', '∴', '∵', '±', '≡'  // Logic
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: symbolCategories.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _insertSymbol(String symbol) {
    final text = widget.controller.text;
    final selection = widget.controller.selection;
    
    String newSymbol = symbol;
    
    // Handle special cases for superscript and conversion
    if (symbol == 'x²') {
      newSymbol = '^2';
    } else if (symbol == 'x³') {
      newSymbol = '^3';
    } else if (symbol == 'xⁿ') {
      newSymbol = '^n';
    } else if (symbol == '³√') {
      newSymbol = '∛';
    } else if (symbol == 'ⁿ√') {
      newSymbol = 'ⁿ√';
    } else if (symbol == '÷') {
      // Insert mathematical fraction format
      newSymbol = '⬜/⬜';
    }
    
    // Handle invalid selection positions
    int startPos = selection.start;
    int endPos = selection.end;
    
    // If no valid selection, insert at the end
    if (startPos < 0 || endPos < 0 || startPos > text.length || endPos > text.length) {
      startPos = text.length;
      endPos = text.length;
    }
    
    final newText = text.replaceRange(startPos, endPos, newSymbol);
    
    // Handle cursor positioning for fraction format
    int cursorPosition = startPos + newSymbol.length;
    if (symbol == '÷') {
      // Position cursor at the numerator (first placeholder)
      cursorPosition = startPos + 1; // Position after first ⬜ to allow replacement
    }
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
    
    // Call the callback if provided
    widget.onSymbolTap?.call(newSymbol);
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
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.labelSmall,
            labelColor: Theme.of(context).colorScheme.primary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            indicatorColor: Theme.of(context).colorScheme.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: symbolCategories.keys.map((category) => Tab(text: category)).toList(),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: TabBarView(
              controller: _tabController,
              children: symbolCategories.values.map((symbols) => _buildSymbolGrid(context, symbols)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymbolGrid(BuildContext context, List<String> symbols) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
      child: Wrap(
        spacing: 6.0,
        runSpacing: 6.0,
        alignment: WrapAlignment.start,
        children: symbols.map((symbol) => _buildSymbolButton(context, symbol)).toList(),
      ),
    );
  }

  Widget _buildSymbolButton(BuildContext context, String symbol) {
    return InkWell(
      onTap: () => _insertSymbol(symbol),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
