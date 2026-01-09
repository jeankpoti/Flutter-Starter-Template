import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'keyboard_preferences.dart';

class MathKeyboardWidget extends StatefulWidget {
  final TextEditingController textController;
  final bool isVisible;
  final VoidCallback? onToggleVisibility;

  const MathKeyboardWidget({
    super.key,
    required this.textController,
    required this.isVisible,
    this.onToggleVisibility,
  });

  @override
  State<MathKeyboardWidget> createState() => _MathKeyboardWidgetState();
}

class _MathKeyboardWidgetState extends State<MathKeyboardWidget>
    with SingleTickerProviderStateMixin {
  String _selectedCategory = 'numbers';
  final KeyboardPreferences _preferences = KeyboardPreferences();
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  static const Map<String, Map<String, dynamic>> _categories = {
    'numbers': {
      'icon': Icons.dialpad,
      'symbols': [
        ['7', '8', '9', '÷', '/'],
        ['4', '5', '6', '×', '%'],
        ['1', '2', '3', '-', '('],
        ['0', '.', '=', '+', ')'],
      ],
    },
    'algebra': {
      'icon': Icons.functions,
      'symbols': [
        ['x', 'y', 'z', 'a', 'b'],
        ['c', 'd', 'n', 'm', 't'],
        ['√', '∛', 'x²', 'x³', '^'],
        ['(', ')', '[', ']', '|'],
      ],
    },
    'calculus': {
      'icon': Icons.trending_up,
      'symbols': [
        ['∫', 'd/dx', '∂', '∇', 'Δ'],
        ['lim', '∞', 'Σ', 'Π', '∏'],
        ['sin', 'cos', 'tan', 'ln', 'log'],
        ['e', 'π', '|x|', '³', 'θ'],
      ],
    },
    'symbols': {
      'icon': Icons.category,
      'symbols': [
        ['±', '∓', '≈', '≠', '≡'],
        ['≤', '≥', '<', '>', '⇒'],
        ['∈', '∉', '⊂', '⊃', '⊆'],
        ['∪', '∩', '∅', '∀', '∃'],
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadLastCategory();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MathKeyboardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      widget.isVisible
          ? _animationController.reverse()
          : _animationController.forward();
    }
  }

  Future<void> _loadLastCategory() async {
    final lastCategory = await _preferences.getLastCategory();
    if (_categories.containsKey(lastCategory)) {
      setState(() => _selectedCategory = lastCategory);
    }
  }

  void _insertSymbol(String symbol) {
    final selection = widget.textController.selection;
    final text = widget.textController.text;
    final newText =
        selection.isValid
            ? text.replaceRange(selection.start, selection.end, symbol)
            : text + symbol;

    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset:
            selection.isValid
                ? selection.start + symbol.length
                : newText.length,
      ),
    );
  }

  void _backspace() {
    final selection = widget.textController.selection;
    final text = widget.textController.text;

    if (!selection.isValid || selection.start == 0) return;

    final newText =
        selection.isCollapsed
            ? text.substring(0, selection.start - 1) +
                text.substring(selection.start)
            : text.replaceRange(selection.start, selection.end, '');

    widget.textController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selection.isCollapsed ? selection.start - 1 : selection.start,
      ),
    );
  }

  String _getCategoryDisplayName(String category) {
    final localization = AppLocalizations.of(context)!;
    switch (category) {
      case 'numbers':
        return localization.numbers;
      case 'algebra':
        return localization.algebra;
      case 'calculus':
        return localization.calculus;
      case 'symbols':
        return localization.symbols;
      default:
        return category;
    }
  }

  Widget _buildCategoryTab(String category) {
    final isSelected = category == _selectedCategory;
    final categoryData = _categories[category]!;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCategory = category);
        _preferences.setLastCategory(category);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.secondary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              categoryData['icon'],
              size: 16,
              color:
                  isSelected
                      ? theme.colorScheme.onSecondary
                      : theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              _getCategoryDisplayName(category),
              style: theme.textTheme.labelSmall?.copyWith(
                color:
                    isSelected
                        ? theme.colorScheme.onSecondary
                        : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymbolButton(String symbol) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: () => _insertSymbol(symbol),
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Center(
            child: Text(
              symbol,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    final symbols =
        (_categories[_selectedCategory]!['symbols'] as List<List<String>>);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Category tabs
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _categories.keys
                      .map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildCategoryTab(category),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),

        // Symbol grid
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children:
                  symbols
                      .map(
                        (row) => Expanded(
                          child: Row(
                            children: row.map(_buildSymbolButton).toList(),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ),

        // Bottom toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: _backspace,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              // const Spacer(),
              // if (widget.onToggleVisibility != null)
              //   GestureDetector(
              //     onTap: widget.onToggleVisibility,
              //     child: Container(
              //       padding: const EdgeInsets.symmetric(
              //         horizontal: 16,
              //         vertical: 8,
              //       ),
              //       decoration: BoxDecoration(
              //         color: theme.colorScheme.secondaryContainer,
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       child: Row(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Icon(
              //             Icons.keyboard_hide,
              //             size: 16,
              //             color: theme.colorScheme.onSecondaryContainer,
              //           ),
              //           const SizedBox(width: 6),
              //           Text(
              //             AppLocalizations.of(context)!.hide,
              //             style: theme.textTheme.labelSmall?.copyWith(
              //               color: theme.colorScheme.onSecondaryContainer,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    // final bottomPadding = mediaQuery.padding.bottom;
    final keyboardHeight =
        screenHeight * 0.34; // Larger keyboard for all symbol buttons

    // Position keyboard directly on top of the navigation bar (no gap)
    // bottom = distance from screen bottom to keyboard bottom
    // final navBarHeight = kBottomNavigationBarHeight;
    // final keyboardBottomOffset =
    //     bottomPadding + navBarHeight; // Directly on nav bar

    // return Positioned(
    //   left: 0,
    //   right: 0,
    //   bottom: keyboardBottomOffset,
    //   height: keyboardHeight,
    //   child:

    return AnimatedBuilder(
      animation: _slideAnimation,
      builder:
          (context, child) => Transform.translate(
            offset: Offset(0, keyboardHeight * _slideAnimation.value),
            child: GestureDetector(
              onTap: () {}, // Prevent taps on keyboard from dismissing it
              child: Container(
                height: keyboardHeight,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                      offset: const Offset(0, -4),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: _buildKeyboard(),
              ),
            ),
          ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
