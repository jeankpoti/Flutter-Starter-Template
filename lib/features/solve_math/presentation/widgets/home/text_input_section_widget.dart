import 'package:flutter/material.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../common_widgets/math_expression_preprocessor.dart';

class TextInputSectionWidget extends StatefulWidget {
  final TextEditingController textController;
  final ExpressionValidationResult? validationResult;
  final VoidCallback onTextChanged;
  final VoidCallback onToggleMathKeyboard;
  final bool showMathKeyboard;
  final ValueChanged<bool>? onFocusChanged;

  const TextInputSectionWidget({
    super.key,
    required this.textController,
    required this.validationResult,
    required this.onTextChanged,
    required this.onToggleMathKeyboard,
    required this.showMathKeyboard,
    this.onFocusChanged,
  });

  @override
  State<TextInputSectionWidget> createState() => _TextInputSectionWidgetState();
}

class _TextInputSectionWidgetState extends State<TextInputSectionWidget> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (widget.onFocusChanged != null) {
      widget.onFocusChanged!(_focusNode.hasFocus);
    }
  }

  Widget _buildValidationIndicator(BuildContext context) {
    if (widget.validationResult == null) return const SizedBox.shrink();

    final hasErrors = widget.validationResult!.hasErrors;
    final hasWarnings = widget.validationResult!.hasWarnings;
    final theme = Theme.of(context);

    Color indicatorColor;
    IconData indicatorIcon;
    String statusText;

    if (hasErrors) {
      indicatorColor = theme.colorScheme.error;
      indicatorIcon = Icons.error_outline;
      statusText = 'Expression has errors';
    } else if (hasWarnings) {
      indicatorColor = theme.colorScheme.tertiary;
      indicatorIcon = Icons.warning_amber_outlined;
      statusText = 'Expression has warnings';
    } else {
      indicatorColor = theme.colorScheme.primary;
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: indicatorColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              TitleMediumText(
                AppLocalizations.of(context)!.typeMathProblem,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Text input area
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
              color: theme.colorScheme.surface,
            ),
            child: TextField(
              controller: widget.textController,
              focusNode: _focusNode,
              maxLines: null,
              minLines: 6,
              textInputAction: TextInputAction.newline,
              keyboardType:
                  widget.showMathKeyboard
                      ? TextInputType.none
                      : TextInputType.multiline,
              decoration: InputDecoration(
                hintText:
                    '${AppLocalizations.of(context)!.enterMathProblem}\n\n${AppLocalizations.of(context)!.exampleProblem}',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                height: 1.5,
              ),
              onChanged: (value) => widget.onTextChanged(),
            ),
          ),

          // Validation status indicator
          if (widget.validationResult != null) ...[
            const SizedBox(height: 12),
            _buildValidationIndicator(context),
          ],

          // Math keyboard toggle button
          // const SizedBox(height: 16.0),
          // OutlinedButton.icon(
          //   onPressed: widget.onToggleMathKeyboard,
          //   icon: Icon(
          //     widget.showMathKeyboard ? Icons.keyboard_hide : Icons.keyboard_alt,
          //     size: 16,
          //   ),
          //   label: Text(
          //     widget.showMathKeyboard
          //         ? AppLocalizations.of(context)!.hide
          //         : 'Math',
          //     style: const TextStyle(fontWeight: FontWeight.w500),
          //   ),
          //   style: OutlinedButton.styleFrom(
          //     side: BorderSide(
          //       color: theme.colorScheme.outline,
          //       width: 1.5,
          //     ),
          //     shape: RoundedRectangleBorder(
          //       borderRadius: BorderRadius.circular(24),
          //     ),
          //     padding: const EdgeInsets.symmetric(
          //       horizontal: 16,
          //       vertical: 12,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
