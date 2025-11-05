import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

class MathKeyboardWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String value)? onChanged;
  final String? hintText;
  final int? maxLines;
  final double? minHeight;

  const MathKeyboardWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.hintText,
    this.maxLines,
    this.minHeight,
  });

  @override
  State<MathKeyboardWidget> createState() => _MathKeyboardWidgetState();
}

class _MathKeyboardWidgetState extends State<MathKeyboardWidget> {
  late MathFieldEditingController _mathController;
  late VoidCallback _mathControllerListener;
  bool _isInternalUpdate = false;

  @override
  void initState() {
    super.initState();
    _mathController = MathFieldEditingController();

    // Sync changes from math controller -> external TextEditingController
    _mathControllerListener = () {
      if (_isInternalUpdate) return;
      final value = _mathController.currentEditingValue().toString();
      if (value != widget.controller.text) {
        _isInternalUpdate = true;
        widget.controller.value = TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        );
        widget.onChanged?.call(value);
        _isInternalUpdate = false;
      }
    };
    _mathController.addListener(_mathControllerListener);

    // NOTE: We intentionally do NOT sync external TextEditingController ->
    // MathFieldEditingController because the math controller implementation
    // in the `math_keyboard` package does not expose a stable public API
    // for programmatically updating the editing value across all versions.
    // We keep one-way sync (math controller -> external controller) which
    // covers user input via the math keyboard. External edits to the
    // provided TextEditingController will NOT update the math field.
  }

  @override
  void dispose() {
    _mathController.removeListener(_mathControllerListener);
    _mathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: MathField(
            controller: _mathController,
            variables: const [
              'a',
              'b',
              'c',
              'd',
              'e',
              'f',
              'g',
              'h',
              'i',
              'j',
              'k',
              'l',
              'm',
              'n',
              'o',
              'p',
              'q',
              'r',
              's',
              't',
              'u',
              'v',
              'w',
              'x',
              'y',
              'z',
              'A',
              'B',
              'C',
              'D',
              'E',
              'F',
              'G',
              'H',
              'I',
              'J',
              'K',
              'L',
              'M',
              'N',
              'O',
              'P',
              'Q',
              'R',
              'S',
              'T',
              'U',
              'V',
              'W',
              'X',
              'Y',
              'Z',
            ],
            keyboardType: MathKeyboardType.expression,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Enter mathematical expression...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(16),
              hintStyle: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
                fontSize: 16,
              ),
            ),
          ),
        ),

        // Add spacing and additional controls if needed
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(
              context,
              'Space',
              Icons.space_bar,
              () => _addSpace(),
            ),
            _buildActionButton(context, 'Clear', Icons.clear, () {
              // clear both controllers and notify
              _mathController.clear();
              widget.controller.clear();
              widget.onChanged?.call('');
            }),
          ],
        ),
      ],
    );
  }

  void _addSpace() {
    // Add space character directly to TextEditingController like the enhanced keyboard
    final text = widget.controller.text;
    final selection = widget.controller.selection;

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

    final newText = text.replaceRange(startPos, endPos, ' ');
    _isInternalUpdate = true;
    widget.controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: startPos + 1),
    );
    widget.onChanged?.call(newText);

    // Try to update the math controller visually using a best-effort dynamic
    // call. The `math_keyboard` package does not guarantee a stable API for
    // programmatically inserting text, so we attempt common method names via
    // dynamic invocation and silently ignore failures. This makes the Space
    // button work visually when the package supports an insert method.
    try {
      // Most implementations expose something like `insertText` or `write`.
      // We attempt `insertText` first.
      (_mathController as dynamic).insertText(' ');
    } catch (_) {
      try {
        (_mathController as dynamic).write(' ');
      } catch (_) {
        // ignore: no-op if the API isn't available
      }
    }
    _isInternalUpdate = false;
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(80, 32),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class MathKeyboardViewInsetsWidget extends StatelessWidget {
  final Widget child;

  const MathKeyboardViewInsetsWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MathKeyboardViewInsets(child: child);
  }
}
