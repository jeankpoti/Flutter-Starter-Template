import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_expression_preprocessor.dart';
import '../../../../../common_widgets/expression_history_manager.dart';
import '../../../../../common_widgets/math_keyboard_widget.dart';
import 'text_input_section_widget.dart';
import '../../solve_math_cubit.dart';

class TextTabWidget extends StatefulWidget {
  final TextEditingController textController;
  final bool isTablet;
  final VoidCallback onSolvePressed;
  final void Function(String, {bool isError}) showSnackBarMessage;

  const TextTabWidget({
    super.key,
    required this.textController,
    required this.isTablet,
    required this.onSolvePressed,
    required this.showSnackBarMessage,
  });

  @override
  State<TextTabWidget> createState() => _TextTabWidgetState();
}

class _TextTabWidgetState extends State<TextTabWidget> {
  final ExpressionHistoryManager _historyManager = ExpressionHistoryManager();
  ExpressionValidationResult? _validationResult;
  bool _showMathKeyboard = false;

  @override
  void initState() {
    super.initState();
    widget.textController.addListener(_validateExpression);
  }

  @override
  void dispose() {
    widget.textController.removeListener(_validateExpression);
    super.dispose();
  }

  void _validateExpression() {
    final text = widget.textController.text;
    setState(() {
      _validationResult =
          text.trim().isNotEmpty
              ? MathExpressionPreprocessor.validateExpression(text)
              : null;
    });
  }

  Future<void> _handleSolvePressed() async {
    final text = widget.textController.text.trim();

    if (text.isEmpty) {
      widget.showSnackBarMessage(
        AppLocalizations.of(context)!.enterMathProblemError,
        isError: true,
      );
      return;
    }

    final validationResult = MathExpressionPreprocessor.validateExpression(
      text,
    );

    if (validationResult.hasErrors) {
      _showValidationDialog(validationResult);
      return;
    }

    await _historyManager.addToHistory(text);
    final processedExpression = MathExpressionPreprocessor.prepareForAI(text);
    final originalText = widget.textController.text;
    widget.textController.text = processedExpression;

    try {
      widget.onSolvePressed();
    } finally {
      widget.textController.text = originalText;
    }
  }

  void _showValidationDialog(ExpressionValidationResult validationResult) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                const Text('Expression Issues'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The following issues were found:'),
                const SizedBox(height: 12),
                ...validationResult.errors.map(
                  (error) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 16,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(error.message)),
                      ],
                    ),
                  ),
                ),
                if (validationResult.suggestions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Suggestions:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  ...validationResult.suggestions
                      .take(3)
                      .map(
                        (suggestion) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(suggestion)),
                            ],
                          ),
                        ),
                      ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fix Expression'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.textController.text =
                      validationResult.processedExpression;
                  widget.onSolvePressed();
                },
                child: const Text('Solve Anyway'),
              ),
            ],
          ),
    );
  }

  Widget _buildActionButtons() {
    final state = context.watch<SolveMathCubit>().state;
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.textController.text.trim().isNotEmpty)
          OutlinedButton(
            onPressed: () {
              widget.textController.clear();
              setState(() => _validationResult = null);
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: theme.colorScheme.outline, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

        const SizedBox(width: 12),

        ElevatedButton(
          onPressed:
              (state.isIdentifying || state.isShowingAd)
                  ? null
                  : _handleSolvePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            elevation: 2,
          ),
          child:
              (state.isIdentifying || state.isShowingAd)
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onSecondary,
                    ),
                  )
                  : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: theme.colorScheme.onSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.solve,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => Stack(
            children: [
              GestureDetector(
                onTap: () {
                  // Hide keyboard when tapping outside
                  if (_showMathKeyboard) {
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _showMathKeyboard = false;
                    });
                  }
                },
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextInputSectionWidget(
                                textController: widget.textController,
                                validationResult: _validationResult,
                                onTextChanged: _validateExpression,
                                onToggleMathKeyboard:
                                    () => setState(
                                      () =>
                                          _showMathKeyboard =
                                              !_showMathKeyboard,
                                    ),
                                showMathKeyboard: _showMathKeyboard,
                                onFocusChanged: (hasFocus) {
                                  setState(() {
                                    _showMathKeyboard = hasFocus;
                                  });
                                },
                              ),
                              // const SizedBox(height: 8.0),
                              _buildActionButtons(),
                              const SizedBox(height: 24.0),
                              _TipsSection(),
                              SizedBox(
                                height:
                                    _showMathKeyboard
                                        ? MediaQuery.of(context).size.height *
                                                0.4 +
                                            kBottomNavigationBarHeight +
                                            32.0
                                        : 16.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Math keyboard overlay
              if (_showMathKeyboard)
                MathKeyboardWidget(
                  textController: widget.textController,
                  isVisible: _showMathKeyboard,
                  onToggleVisibility:
                      () => setState(() => _showMathKeyboard = false),
                ),
            ],
          ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              TitleSmallText(
                AppLocalizations.of(context)!.tipsForBetterResults,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...[
            AppLocalizations.of(context)!.beSpecificTip,
            AppLocalizations.of(context)!.useProperNotationTip,
            AppLocalizations.of(context)!.includeNecessaryInfoTip,
          ].map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 8, right: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: BodySmallText(
                      tip,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
