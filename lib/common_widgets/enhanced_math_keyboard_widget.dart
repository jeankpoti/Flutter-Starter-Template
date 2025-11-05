import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'smart_cursor_helper.dart';
import 'expression_history_manager.dart';

class EnhancedMathKeyboardWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String symbol)? onSymbolTap;

  const EnhancedMathKeyboardWidget({
    super.key,
    required this.controller,
    this.onSymbolTap,
  });

  @override
  State<EnhancedMathKeyboardWidget> createState() =>
      _EnhancedMathKeyboardWidgetState();
}

class _EnhancedMathKeyboardWidgetState
    extends State<EnhancedMathKeyboardWidget> {
  bool _showAlphabet = false;
  String _currentCategory = 'numbers';
  final ExpressionHistoryManager _historyManager = ExpressionHistoryManager();
  List<String> _recentExpressions = [];
  List<String> _favoriteExpressions = [];

  // Number and variable buttons (always visible)
  static const List<String> numbers = [
    '7',
    '8',
    '9',
    '4',
    '5',
    '6',
    '1',
    '2',
    '3',
    '0',
  ];
  static const List<String> commonVariables = ['x', 'y', 'z'];
  static const List<String> basicOperators = [
    '+',
    '−',
    '×',
    '÷',
    '=',
    '(',
    ')',
  ];

  // Alphabet layout
  static const List<List<String>> alphabetRows = [
    ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'],
    ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'],
    ['z', 'x', 'c', 'v', 'b', 'n', 'm'],
  ];

  // Mathematical symbol categories
  static const Map<String, List<String>> symbolCategories = {
    'basic': [
      '≠',
      '≈',
      '≤',
      '≥',
      '<',
      '>',
      '±',
      '∓',
      'x²',
      'x³',
      'xⁿ',
      '√',
      '³√',
      'ⁿ√',
      '½',
      '¼',
      '¾',
      '⅓',
      '⅔',
      '⅛',
      '⅜',
      '⅝',
      '⅞',
    ],
    'geometry': [
      '°',
      '∠',
      '△',
      '□',
      '○',
      '◯',
      '⬜',
      '◊',
      '∥',
      '⊥',
      '≅',
      '∼',
      'π',
      '∆',
      '▢',
      '⊿',
    ],
    'algebra': [
      'α',
      'β',
      'γ',
      'δ',
      'θ',
      'λ',
      'μ',
      'σ',
      'φ',
      'ψ',
      'ω',
      'Α',
      'Β',
      'Γ',
      'Δ',
      'Θ',
    ],
    'calculus': [
      '∫',
      '∂',
      '∇',
      '∞',
      'lim',
      'd/dx',
      '∑',
      '∏',
      'log',
      'ln',
      'sin',
      'cos',
      'tan',
      'sec',
      'csc',
      'cot',
    ],
    'sets': [
      '∈',
      '∉',
      '⊂',
      '⊃',
      '⊆',
      '⊇',
      '∪',
      '∩',
      '∅',
      '℘',
      '×',
      '⋃',
      '⋂',
      '∖',
      '△',
      '⊕',
    ],
    'logic': [
      '∀',
      '∃',
      '∧',
      '∨',
      '¬',
      '⇒',
      '⇔',
      '⟹',
      '⟸',
      '⟺',
      '∴',
      '∵',
      '⊢',
      '⊨',
      '⊤',
      '⊥',
    ],
    'templates': [
      'Quadratic',
      'Fraction',
      'Square Root',
      'Integral',
      'Limit',
      'Matrix',
      'System',
      'Derivative',
      'Sum',
      'Equation',
      'Trig Function',
      'Log Function',
      'Exponential',
      'Binomial',
      'Vector',
      'Probability',
      'Statistics',
      'Physics',
    ],
    'recent': [], // Will be populated dynamically
    'favorites': [], // Will be populated dynamically
  };

  // Expression templates
  static const Map<String, String> expressionTemplates = {
    'Quadratic': r'$ax^2 + bx + c = 0$',
    'Fraction': r'$\frac{numerator}{denominator}$',
    'Square Root': r'$\sqrt{expression}$',
    'Integral': r'$\int_{a}^{b} f(x) \, dx$',
    'Limit': r'$\lim_{x \to a} f(x)$',
    'Matrix': r'$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$',
    'System': r'$\begin{cases} equation_1 \\ equation_2 \end{cases}$',
    'Derivative': r'$\frac{d}{dx} f(x)$',
    'Sum': r'$\sum_{i=1}^{n} a_i$',
    'Equation': r'$left\_side = right\_side$',

    // Advanced templates
    'Trig Function': r'$\sin(\theta) = \frac{opposite}{hypotenuse}$',
    'Log Function': r'$\log_b(x) = y \Leftrightarrow b^y = x$',
    'Exponential': r'$e^{i\pi} + 1 = 0$',
    'Binomial': r'$(a + b)^n = \sum_{k=0}^{n} \binom{n}{k} a^{n-k} b^k$',
    'Vector': r'$\vec{v} = \langle x, y, z \rangle$',
    'Probability': r'$P(A \cap B) = P(A) \cdot P(B|A)$',
    'Statistics': r'$\bar{x} = \frac{1}{n} \sum_{i=1}^{n} x_i$',
    'Physics': r'$F = ma$',
  };

  @override
  void initState() {
    super.initState();
    _loadExpressionHistory();
  }

  Future<void> _loadExpressionHistory() async {
    final recent = await _historyManager.getRecentExpressions(limit: 5);
    final favorites = await _historyManager.getFavorites();

    setState(() {
      _recentExpressions = recent;
      _favoriteExpressions = favorites.map((f) => f.expression).toList();
    });
  }

  void _insertSymbol(String symbol) {
    HapticFeedback.lightImpact();

    final text = widget.controller.text;
    final selection = widget.controller.selection;

    String newSymbol = symbol;

    // Handle expression templates
    if (expressionTemplates.containsKey(symbol)) {
      newSymbol = expressionTemplates[symbol]!;
    }

    // Handle special cases for LaTeX formatting
    if (symbol == 'x²') {
      newSymbol = r'$x^2$';
    } else if (symbol == 'x³') {
      newSymbol = r'$x^3$';
    } else if (symbol == 'xⁿ') {
      newSymbol = r'$x^n$';
    } else if (symbol == '√') {
      newSymbol = r'$\sqrt{}$';
    } else if (symbol == '³√') {
      newSymbol = r'$\sqrt[3]{}$';
    } else if (symbol == 'ⁿ√') {
      newSymbol = r'$\sqrt[n]{}$';
    } else if (symbol == '÷') {
      newSymbol = r'$\div$';
    } else if (symbol == '×') {
      newSymbol = r'$\times$';
    } else if (symbol == '½') {
      newSymbol = r'$\frac{1}{2}$';
    } else if (symbol == '¼') {
      newSymbol = r'$\frac{1}{4}$';
    } else if (symbol == '¾') {
      newSymbol = r'$\frac{3}{4}$';
    } else if (symbol == '∞') {
      newSymbol = r'$\infty$';
    } else if (symbol == '∫') {
      newSymbol = r'$\int$';
    } else if (symbol == '∑') {
      newSymbol = r'$\sum$';
    } else if (symbol == 'π') {
      newSymbol = r'$\pi$';
    } else if (symbol == '≤') {
      newSymbol = r'$\leq$';
    } else if (symbol == '≥') {
      newSymbol = r'$\geq$';
    } else if (symbol == '≠') {
      newSymbol = r'$\neq$';
    } else if (symbol == '±') {
      newSymbol = r'$\pm$';
    } else if (symbol == 'sin') {
      newSymbol = r'$\sin()$';
    } else if (symbol == 'cos') {
      newSymbol = r'$\cos()$';
    } else if (symbol == 'tan') {
      newSymbol = r'$\tan()$';
    } else if (symbol == 'log') {
      newSymbol = r'$\log()$';
    } else if (symbol == 'ln') {
      newSymbol = r'$\ln()$';
    }

    // Handle invalid selection positions
    int startPos = selection.start;
    int endPos = selection.end;

    // If no valid selection, insert at the end
    if (startPos < 0 ||
        endPos < 0 ||
        startPos > text.length ||
        endPos > text.length) {
      startPos = text.length;
      endPos = text.length;
    }

    final newText = text.replaceRange(startPos, endPos, newSymbol);

    // Use smart cursor positioning for better UX
    final smartSelection = SmartCursorHelper.getSmartCursorPosition(
      newSymbol,
      startPos,
    );

    widget.controller.value = TextEditingValue(
      text: newText,
      selection: smartSelection,
    );

    widget.onSymbolTap?.call(newSymbol);

    // Add to history if it's a significant expression (templates, LaTeX expressions)
    if (newSymbol.startsWith(r'$') &&
        newSymbol.endsWith(r'$') &&
        newSymbol.length > 3) {
      _historyManager.addToHistory(newSymbol);
      _loadExpressionHistory(); // Refresh the lists
    }
  }

  void _backspace() {
    HapticFeedback.lightImpact();

    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (text.isEmpty) return;

    if (selection.start != selection.end) {
      // Delete selected text
      final newText = text.replaceRange(selection.start, selection.end, '');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start),
      );
    } else if (selection.start > 0) {
      // Delete character before cursor
      final newText = text.replaceRange(
        selection.start - 1,
        selection.start,
        '',
      );
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: selection.start - 1),
      );
    }
  }

  void _moveCursor(int direction) {
    HapticFeedback.lightImpact();

    final text = widget.controller.text;
    final selection = widget.controller.selection;

    if (direction == 0) {
      // Smart jump to next editable position
      final nextPosition = SmartCursorHelper.getNextCursorPosition(
        text,
        selection.start,
      );
      if (nextPosition != null) {
        widget.controller.selection = nextPosition;
      }
    } else if (direction == -2) {
      // Smart jump to previous editable position
      final prevPosition = SmartCursorHelper.getPreviousCursorPosition(
        text,
        selection.start,
      );
      if (prevPosition != null) {
        widget.controller.selection = prevPosition;
      }
    } else {
      // Regular cursor movement
      final newPosition = (selection.start + direction).clamp(0, text.length);
      widget.controller.selection = TextSelection.collapsed(
        offset: newPosition,
      );
    }
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
          _buildHeader(context),
          const SizedBox(height: 8),
          if (_showAlphabet)
            _buildAlphabetKeyboard(context)
          else
            _buildMainKeyboard(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _showAlphabet ? 'Alphabet' : 'Math Keyboard',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            _buildToggleButton(context, 'abc', _showAlphabet, () {
              setState(() {
                _showAlphabet = !_showAlphabet;
              });
            }),
            const SizedBox(width: 8),
            Icon(
              Icons.calculate_outlined,
              size: 16,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleButton(
    BuildContext context,
    String text,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color:
                isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildMainKeyboard(BuildContext context) {
    return Column(
      children: [
        // Category selector for symbols
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                symbolCategories.keys.map((category) {
                  final isSelected = _currentCategory == category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildCategoryChip(
                      context,
                      category,
                      isSelected,
                      () {
                        setState(() {
                          _currentCategory = category;
                        });
                      },
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Main number and variable grid
        _buildNumbersAndVariables(context),
        const SizedBox(height: 8),
        // Symbol grid based on selected category
        _buildSymbolGrid(context, symbolCategories[_currentCategory] ?? []),
        const SizedBox(height: 8),
        // Navigation controls
        _buildNavigationControls(context),
      ],
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    String category,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          category.substring(0, 1).toUpperCase() + category.substring(1),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color:
                isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildNumbersAndVariables(BuildContext context) {
    return Column(
      children: [
        // Numbers grid (3x3 + 0)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 2,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: numbers.length,
          itemBuilder: (context, index) {
            return _buildKeyButton(context, numbers[index], isNumber: true);
          },
        ),
        const SizedBox(height: 8),
        // Variables and basic operators
        Row(
          children: [
            // Variables
            ...commonVariables.map(
              (variable) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _buildKeyButton(context, variable, isVariable: true),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Basic operators
            ...basicOperators
                .take(4)
                .map(
                  (op) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: _buildKeyButton(context, op, isOperator: true),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 4),
        // Remaining operators
        Row(
          children:
              basicOperators
                  .skip(4)
                  .map(
                    (op) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _buildKeyButton(context, op, isOperator: true),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSymbolGrid(BuildContext context, List<String> symbols) {
    // Check if this is a special category
    final isTemplateCategory = _currentCategory == 'templates';
    final isRecentCategory = _currentCategory == 'recent';
    final isFavoritesCategory = _currentCategory == 'favorites';

    // Get the actual symbols to display
    List<String> actualSymbols = symbols;
    if (isRecentCategory) {
      actualSymbols = _recentExpressions;
    } else if (isFavoritesCategory) {
      actualSymbols = _favoriteExpressions;
    }

    if (actualSymbols.isEmpty && (isRecentCategory || isFavoritesCategory)) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Text(
            isRecentCategory
                ? 'No recent expressions'
                : 'No favorite expressions',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height:
          (isTemplateCategory || isRecentCategory || isFavoritesCategory)
              ? 100
              : 64,
      child: SingleChildScrollView(
        child:
            (isTemplateCategory || isRecentCategory || isFavoritesCategory)
                ? Column(
                  children:
                      actualSymbols
                          .map(
                            (item) =>
                                isTemplateCategory
                                    ? _buildTemplateButton(context, item)
                                    : _buildExpressionHistoryButton(
                                      context,
                                      item,
                                      isFavoritesCategory,
                                    ),
                          )
                          .toList(),
                )
                : Wrap(
                  spacing: 4.0,
                  runSpacing: 4.0,
                  children:
                      actualSymbols
                          .map((symbol) => _buildSymbolButton(context, symbol))
                          .toList(),
                ),
      ),
    );
  }

  Widget _buildNavigationControls(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            context,
            Icons.arrow_back_ios,
            () => _moveCursor(-1),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildNavButton(
            context,
            Icons.arrow_forward_ios,
            () => _moveCursor(1),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildNavButton(
            context,
            Icons.skip_previous_outlined,
            () => _moveCursor(-2),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildNavButton(
            context,
            Icons.skip_next_outlined,
            () => _moveCursor(0),
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildNavButton(context, Icons.backspace_outlined, _backspace),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: _buildNavButton(
            context,
            Icons.space_bar,
            () => _insertSymbol(' '),
          ),
        ),
      ],
    );
  }

  Widget _buildAlphabetKeyboard(BuildContext context) {
    return Column(
      children: [
        ...alphabetRows.map(
          (row) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  row
                      .map(
                        (letter) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1),
                            child: _buildKeyButton(context, letter),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildNavigationControls(context),
      ],
    );
  }

  Widget _buildKeyButton(
    BuildContext context,
    String text, {
    bool isNumber = false,
    bool isVariable = false,
    bool isOperator = false,
  }) {
    Color backgroundColor;
    Color textColor;

    if (isNumber) {
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
    } else if (isVariable) {
      backgroundColor = Theme.of(context).colorScheme.secondary;
      textColor = Theme.of(context).colorScheme.onSecondary;
    } else if (isOperator) {
      backgroundColor = Theme.of(context).colorScheme.tertiary;
      textColor = Theme.of(context).colorScheme.onTertiary;
    } else {
      backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
      textColor = Theme.of(context).colorScheme.onSurface;
    }

    return GestureDetector(
      onTap: () => _insertSymbol(text),
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(isNumber ? 4 : 8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isNumber ? 12 : (isVariable ? 14 : 12),
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymbolButton(BuildContext context, String symbol) {
    return GestureDetector(
      onTap: () => _insertSymbol(symbol),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.secondaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateButton(BuildContext context, String template) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => _insertSymbol(template),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.tertiaryContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.description_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  template,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                size: 16,
                color: Theme.of(
                  context,
                ).colorScheme.onTertiaryContainer.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpressionHistoryButton(
    BuildContext context,
    String expression,
    bool isFavorite,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () => _insertSymbol(expression),
        onLongPress:
            isFavorite
                ? () => _removeFromFavorites(expression)
                : () => _addToFavorites(expression),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color:
                isFavorite
                    ? Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withValues(alpha: 0.7)
                    : Theme.of(
                      context,
                    ).colorScheme.surfaceContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isFavorite ? Icons.favorite : Icons.history,
                size: 16,
                color:
                    isFavorite
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  expression,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'monospace',
                    color:
                        isFavorite
                            ? Theme.of(context).colorScheme.onPrimaryContainer
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(
                isFavorite ? Icons.remove_circle_outline : Icons.star_border,
                size: 16,
                color:
                    isFavorite
                        ? Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addToFavorites(String expression) async {
    HapticFeedback.mediumImpact();
    await _historyManager.addToFavorites(expression);
    await _loadExpressionHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Added to favorites'),
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }
  }

  Future<void> _removeFromFavorites(String expression) async {
    HapticFeedback.mediumImpact();
    await _historyManager.removeFromFavorites(expression);
    await _loadExpressionHistory();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Removed from favorites'),
          duration: const Duration(seconds: 1),
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      );
    }
  }

  Widget _buildNavButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
