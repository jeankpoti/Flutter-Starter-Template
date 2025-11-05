import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'math_text_widget.dart';
import 'math_autocomplete_widget.dart';
import 'expression_sharing_widget.dart';

class VisualMathExpressionWidget extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final bool showLatexPreview;
  final double minHeight;
  final int maxLines;

  const VisualMathExpressionWidget({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.showLatexPreview = true,
    this.minHeight = 100,
    this.maxLines = 3,
  });

  @override
  State<VisualMathExpressionWidget> createState() => _VisualMathExpressionWidgetState();
}

class _VisualMathExpressionWidgetState extends State<VisualMathExpressionWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _showRawText = false;
  bool _hasLatexError = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _validateLatexExpression();
    });
    widget.onChanged?.call(widget.controller.text);
  }

  void _onFocusChanged() {
    setState(() {});
  }

  void _validateLatexExpression() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      _hasLatexError = false;
      return;
    }

    try {
      // Try to parse the expression to check for LaTeX errors
      if (_containsLatex(text)) {
        // Validate LaTeX expressions
        final latexMatches = RegExp(r'\$([^$]+)\$').allMatches(text);
        for (final match in latexMatches) {
          final latex = match.group(1) ?? '';
          // This will throw if LaTeX is invalid
          Math.tex(latex);
        }
      }
      _hasLatexError = false;
    } catch (e) {
      _hasLatexError = true;
    }
  }

  bool _containsLatex(String text) {
    return text.contains(RegExp(r'\$[^$]*\$'));
  }

  bool _shouldShowLatexPreview() {
    return widget.showLatexPreview && 
           widget.controller.text.isNotEmpty && 
           !_focusNode.hasFocus && 
           !_showRawText &&
           !_hasLatexError;
  }

  Widget _buildLatexPreview() {
    final text = widget.controller.text;
    if (text.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: widget.minHeight),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _hasLatexError 
              ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _hasLatexError ? Icons.error_outline : Icons.visibility_outlined,
                      size: 16,
                      color: _hasLatexError 
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _hasLatexError ? 'Invalid Expression' : 'Preview',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: _hasLatexError 
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showRawText = !_showRawText;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _showRawText 
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _showRawText ? 'Math' : 'Raw',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: _showRawText 
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => ExpressionSharingWidget.shareExpression(
                        context,
                        expression: text,
                        title: 'Mathematical Expression',
                        description: 'Created with Math AI',
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.share,
                              size: 12,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Share',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 12,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Tap to Edit',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_hasLatexError)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Expression contains syntax errors. Check LaTeX formatting.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (_showRawText)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: Theme.of(context).colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: MathTextWidget(
                  text,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.6,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField() {
    return Stack(
      children: [
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
        contentPadding: const EdgeInsets.all(16),
        suffixIcon: widget.controller.text.isNotEmpty
          ? IconButton(
              onPressed: () {
                widget.controller.clear();
              },
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            )
          : null,
      ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
          ),
        ),
        // Math autocomplete overlay
        MathAutocompleteWidget(
          controller: widget.controller,
          focusNode: _focusNode,
          onSuggestionSelected: (suggestion) {
            setState(() {
              _validateLatexExpression();
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LaTeX Preview (when not focused and has content)
        if (_shouldShowLatexPreview()) ...[
          _buildLatexPreview(),
        ] else ...[
          // Raw text input field
          _buildTextField(),
        ],
        
        // Expression help text
        if (_focusNode.hasFocus || widget.controller.text.isEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'LaTeX Tips',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Use \$...\$ for math expressions. Examples: \$x^2\$, \$\\frac{a}{b}\$, \$\\sqrt{x}\$',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class MathExpressionField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final bool readOnly;
  final double minHeight;

  const MathExpressionField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.readOnly = false,
    this.minHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (readOnly && controller.text.isNotEmpty) {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: MathTextWidget(
          controller.text,
          textAlign: TextAlign.left,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
        ),
      );
    }

    return VisualMathExpressionWidget(
      controller: controller,
      hintText: hintText,
      onChanged: onChanged,
      minHeight: minHeight,
    );
  }
}