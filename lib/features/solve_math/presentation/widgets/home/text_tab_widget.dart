import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_expression_preprocessor.dart';
import '../../../../../common_widgets/expression_history_manager.dart';
import '../../../../../common_widgets/dual_input_widget.dart';
import 'package:math_keyboard/math_keyboard.dart';
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
    if (text.trim().isNotEmpty) {
      setState(() {
        _validationResult = MathExpressionPreprocessor.validateExpression(text);
      });
    } else {
      setState(() {
        _validationResult = null;
      });
    }
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

    // Validate and preprocess the expression
    final validationResult = MathExpressionPreprocessor.validateExpression(
      text,
    );

    if (validationResult.hasErrors) {
      _showValidationDialog(validationResult);
      return;
    }

    // Add to history
    await _historyManager.addToHistory(text);

    // Prepare the expression for AI processing
    final processedExpression = MathExpressionPreprocessor.prepareForAI(text);

    // Update the text controller with the processed expression for solving
    final originalText = widget.textController.text;
    widget.textController.text = processedExpression;

    try {
      widget.onSolvePressed();
    } finally {
      // Restore original text after solving
      widget.textController.text = originalText;
    }
  }

  Widget _buildValidationIndicator() {
    if (_validationResult == null) return const SizedBox.shrink();

    final hasErrors = _validationResult!.hasErrors;
    final hasWarnings = _validationResult!.hasWarnings;

    Color indicatorColor;
    IconData indicatorIcon;
    String statusText;

    if (hasErrors) {
      indicatorColor = Theme.of(context).colorScheme.error;
      indicatorIcon = Icons.error_outline;
      statusText = 'Expression has errors';
    } else if (hasWarnings) {
      indicatorColor = Theme.of(context).colorScheme.tertiary;
      indicatorIcon = Icons.warning_amber_outlined;
      statusText = 'Expression has warnings';
    } else {
      indicatorColor = Theme.of(context).colorScheme.primary;
      indicatorIcon = Icons.check_circle_outline;
      statusText = 'Expression looks good';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: indicatorColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(indicatorIcon, size: 16, color: indicatorColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              statusText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (hasErrors || hasWarnings)
            GestureDetector(
              onTap: () => _showValidationDialog(_validationResult!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: indicatorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: indicatorColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
                Text('Expression Issues'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('The following issues were found:'),
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
                child: Text('Fix Expression'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Solve anyway with the processed expression
                  widget.textController.text =
                      validationResult.processedExpression;
                  widget.onSolvePressed();
                },
                child: Text('Solve Anyway'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<SolveMathCubit>().state;

    return MathKeyboardViewInsets(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
            height: constraints.maxHeight,
            child: Column(
              children: [
                // Main content area
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Input Section
                        Container(
                          padding: const EdgeInsets.all(24.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16.0),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_outlined,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  TitleMediumText(
                                    AppLocalizations.of(
                                      context,
                                    )!.typeMathProblem,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16.0),
                              SizedBox(
                                height: 250,
                                child: DualInputWidget(
                                  controller: widget.textController,
                                  hintText:
                                      '${AppLocalizations.of(context)!.enterMathProblem}\n\n${AppLocalizations.of(context)!.exampleProblem}',
                                  onChanged: (value) {
                                    setState(() => _validateExpression());
                                  },
                                  onClearAll: () {
                                    setState(() => _validationResult = null);
                                  },
                                  onSubmit: _handleSolvePressed,
                                ),
                              ),

                              // Validation status indicator
                              if (_validationResult != null) ...[
                                const SizedBox(height: 12),
                                _buildValidationIndicator(),
                              ],

                              // Action buttons row like Mathway
                              const SizedBox(height: 16.0),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  // Voice input button
                                  // IconButton(
                                  //   onPressed: () {
                                  //     // Voice input functionality placeholder
                                  //   },
                                  //   icon: Icon(
                                  //     Icons.mic_outlined,
                                  //     color:
                                  //         Theme.of(context).colorScheme.primary,
                                  //     size: 24,
                                  //   ),
                                  // ),

                                  // const Spacer(),

                                  // Clear all button
                                  // OutlinedButton(
                                  //   onPressed:
                                  //   () {
                                  //     widget.textController.clear();
                                  //     setState(() => _validationResult = null);
                                  //   },
                                  //   style: OutlinedButton.styleFrom(
                                  //     side: BorderSide(
                                  //       color: Theme.of(context).colorScheme.outline,
                                  //       width: 1.5,
                                  //     ),
                                  //     shape: RoundedRectangleBorder(
                                  //       borderRadius: BorderRadius.circular(24),
                                  //     ),
                                  //     padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  //   ),
                                  //   child: Text(
                                  //     'Clear all',
                                  //     style: TextStyle(
                                  //       color: Theme.of(context).colorScheme.onSurface,
                                  //       fontWeight: FontWeight.w500,
                                  //     ),
                                  //   ),
                                  // ),
                                  const SizedBox(width: 12),

                                  // Submit button
                                  ElevatedButton(
                                    onPressed:
                                        (state.isIdentifying ||
                                                state.isShowingAd)
                                            ? null
                                            : _handleSolvePressed,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                      foregroundColor:
                                          Theme.of(
                                            context,
                                          ).colorScheme.onPrimary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 32,
                                        vertical: 12,
                                      ),
                                      elevation: 2,
                                    ),
                                    child:
                                        (state.isIdentifying ||
                                                state.isShowingAd)
                                            ? SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                              ),
                                            )
                                            : Text(
                                              'Submit',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.onPrimary,
                                              ),
                                            ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Tips Section
                        const SizedBox(height: 24.0),
                        _TipsSection(),

                        // Add padding at bottom to prevent keyboard overlap
                        const SizedBox(height: 16.0),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TipsSection extends StatelessWidget {
  static const double _spacing4 = 16.0;

  const _TipsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
              const SizedBox(width: 8),
              TitleSmallText(
                AppLocalizations.of(context)!.tipsForBetterResults,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
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
                      color: Theme.of(context).colorScheme.onSurface,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: BodySmallText(
                      tip,
                      color: Theme.of(context).colorScheme.onSurface,
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
