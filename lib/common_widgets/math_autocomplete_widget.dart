import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathAutocompleteWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String)? onSuggestionSelected;

  const MathAutocompleteWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onSuggestionSelected,
  });

  @override
  State<MathAutocompleteWidget> createState() => _MathAutocompleteWidgetState();
}

class _MathAutocompleteWidgetState extends State<MathAutocompleteWidget> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<MathSuggestion> _suggestions = [];
  String _currentQuery = '';

  // Mathematical function suggestions
  static const List<MathSuggestion> _mathFunctions = [
    // Trigonometric functions
    MathSuggestion('sin', r'$\sin()$', 'Sine function'),
    MathSuggestion('cos', r'$\cos()$', 'Cosine function'),
    MathSuggestion('tan', r'$\tan()$', 'Tangent function'),
    MathSuggestion('arcsin', r'$\arcsin()$', 'Inverse sine'),
    MathSuggestion('arccos', r'$\arccos()$', 'Inverse cosine'),
    MathSuggestion('arctan', r'$\arctan()$', 'Inverse tangent'),
    MathSuggestion('sec', r'$\sec()$', 'Secant function'),
    MathSuggestion('csc', r'$\csc()$', 'Cosecant function'),
    MathSuggestion('cot', r'$\cot()$', 'Cotangent function'),
    
    // Logarithmic functions
    MathSuggestion('log', r'$\log()$', 'Logarithm base 10'),
    MathSuggestion('ln', r'$\ln()$', 'Natural logarithm'),
    MathSuggestion('log_', r'$\log_{}()$', 'Logarithm with custom base'),
    
    // Exponential and power functions
    MathSuggestion('exp', r'$e^{}$', 'Exponential function'),
    MathSuggestion('sqrt', r'$\sqrt{}$', 'Square root'),
    MathSuggestion('cbrt', r'$\sqrt[3]{}$', 'Cube root'),
    MathSuggestion('pow', r'${}^{}$', 'Power function'),
    
    // Calculus
    MathSuggestion('lim', r'$\lim_{x \to a}$', 'Limit'),
    MathSuggestion('int', r'$\int$', 'Integral'),
    MathSuggestion('iint', r'$\iint$', 'Double integral'),
    MathSuggestion('iiint', r'$\iiint$', 'Triple integral'),
    MathSuggestion('oint', r'$\oint$', 'Contour integral'),
    MathSuggestion('sum', r'$\sum_{i=1}^{n}$', 'Summation'),
    MathSuggestion('prod', r'$\prod_{i=1}^{n}$', 'Product'),
    MathSuggestion('deriv', r'$\frac{d}{dx}$', 'Derivative'),
    MathSuggestion('partial', r'$\frac{\partial}{\partial x}$', 'Partial derivative'),
    
    // Statistics
    MathSuggestion('mean', r'$\bar{x}$', 'Sample mean'),
    MathSuggestion('variance', r'$\sigma^2$', 'Variance'),
    MathSuggestion('stddev', r'$\sigma$', 'Standard deviation'),
    MathSuggestion('prob', r'$P()$', 'Probability'),
    MathSuggestion('choose', r'$\binom{n}{k}$', 'Binomial coefficient'),
    
    // Set theory
    MathSuggestion('in', r'$\in$', 'Element of'),
    MathSuggestion('notin', r'$\notin$', 'Not element of'),
    MathSuggestion('subset', r'$\subset$', 'Subset'),
    MathSuggestion('union', r'$\cup$', 'Union'),
    MathSuggestion('intersect', r'$\cap$', 'Intersection'),
    MathSuggestion('emptyset', r'$\emptyset$', 'Empty set'),
    
    // Linear algebra
    MathSuggestion('matrix', r'$\begin{pmatrix} a & b \\ c & d \end{pmatrix}$', '2x2 Matrix'),
    MathSuggestion('matrix3', r'$\begin{pmatrix} a & b & c \\ d & e & f \\ g & h & i \end{pmatrix}$', '3x3 Matrix'),
    MathSuggestion('vector', r'$\begin{pmatrix} x \\ y \\ z \end{pmatrix}$', 'Column vector'),
    MathSuggestion('det', r'$\det()$', 'Determinant'),
    MathSuggestion('trace', r'$\text{tr}()$', 'Trace'),
    
    // Common constants
    MathSuggestion('pi', r'$\pi$', 'Pi constant'),
    MathSuggestion('e', r'$e$', 'Euler\'s number'),
    MathSuggestion('phi', r'$\phi$', 'Golden ratio'),
    MathSuggestion('infinity', r'$\infty$', 'Infinity'),
    
    // Fractions and common expressions
    MathSuggestion('frac', r'$\frac{}{}$', 'Fraction'),
    MathSuggestion('half', r'$\frac{1}{2}$', 'One half'),
    MathSuggestion('quarter', r'$\frac{1}{4}$', 'One quarter'),
    MathSuggestion('third', r'$\frac{1}{3}$', 'One third'),
    
    // Inequalities
    MathSuggestion('leq', r'$\leq$', 'Less than or equal'),
    MathSuggestion('geq', r'$\geq$', 'Greater than or equal'),
    MathSuggestion('neq', r'$\neq$', 'Not equal'),
    MathSuggestion('approx', r'$\approx$', 'Approximately equal'),
    
    // Logic
    MathSuggestion('forall', r'$\forall$', 'For all'),
    MathSuggestion('exists', r'$\exists$', 'There exists'),
    MathSuggestion('and', r'$\land$', 'Logical AND'),
    MathSuggestion('or', r'$\lor$', 'Logical OR'),
    MathSuggestion('not', r'$\lnot$', 'Logical NOT'),
    MathSuggestion('implies', r'$\Rightarrow$', 'Implies'),
    MathSuggestion('iff', r'$\Leftrightarrow$', 'If and only if'),
  ];

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;
    
    if (cursorPosition >= 0 && cursorPosition <= text.length) {
      final query = _extractQueryAtCursor(text, cursorPosition);
      if (query != _currentQuery) {
        _currentQuery = query;
        _updateSuggestions(query);
      }
    }
  }

  void _onFocusChanged() {
    if (!widget.focusNode.hasFocus) {
      _removeOverlay();
    }
  }

  String _extractQueryAtCursor(String text, int cursorPosition) {
    // Find the start of the current word/query
    int start = cursorPosition;
    while (start > 0 && _isValidQueryChar(text[start - 1])) {
      start--;
    }
    
    // Extract the query from start to cursor position
    if (start < cursorPosition) {
      return text.substring(start, cursorPosition);
    }
    
    return '';
  }

  bool _isValidQueryChar(String char) {
    return RegExp(r'[a-zA-Z_]').hasMatch(char);
  }

  void _updateSuggestions(String query) {
    if (query.length < 2) {
      _removeOverlay();
      return;
    }

    final filteredSuggestions = _mathFunctions
        .where((suggestion) => 
            suggestion.trigger.toLowerCase().startsWith(query.toLowerCase()))
        .take(5)
        .toList();

    setState(() {
      _suggestions = filteredSuggestions;
    });

    if (_suggestions.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return _buildSuggestionItem(_suggestions[index]);
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildSuggestionItem(MathSuggestion suggestion) {
    return ListTile(
      dense: true,
      leading: Container(
        width: 40,
        height: 32,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            suggestion.trigger,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ),
      title: Text(
        suggestion.description,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        suggestion.latex,
        style: TextStyle(
          fontSize: 11,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontFamily: 'monospace',
        ),
      ),
      onTap: () => _selectSuggestion(suggestion),
    );
  }

  void _selectSuggestion(MathSuggestion suggestion) {
    HapticFeedback.lightImpact();
    
    final text = widget.controller.text;
    final cursorPosition = widget.controller.selection.baseOffset;
    
    // Find the start of the current query
    int start = cursorPosition;
    while (start > 0 && _isValidQueryChar(text[start - 1])) {
      start--;
    }
    
    // Replace the query with the suggestion
    final newText = text.replaceRange(start, cursorPosition, suggestion.latex);
    
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: start + suggestion.latex.length,
      ),
    );
    
    _removeOverlay();
    widget.onSuggestionSelected?.call(suggestion.latex);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: const SizedBox.shrink(),
    );
  }
}

class MathSuggestion {
  final String trigger;
  final String latex;
  final String description;

  const MathSuggestion(this.trigger, this.latex, this.description);
}