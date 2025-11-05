import 'package:flutter/material.dart';
import 'package:math_keyboard/math_keyboard.dart';

class DualInputWidget extends StatefulWidget {
  final TextEditingController controller;
  final Function(String value)? onChanged;
  final VoidCallback? onClearAll;
  final VoidCallback? onSubmit;
  final String? hintText;
  final int? maxLines;
  final double? minHeight;

  const DualInputWidget({
    super.key,
    required this.controller,
    this.onChanged,
    this.onClearAll,
    this.onSubmit,
    this.hintText,
    this.maxLines,
    this.minHeight,
  });

  @override
  State<DualInputWidget> createState() => _DualInputWidgetState();
}

class _DualInputWidgetState extends State<DualInputWidget> {
  late MathFieldEditingController _mathController;
  late TextEditingController _textController;
  late FocusNode _textFocusNode;
  late FocusNode _mathFocusNode;

  @override
  void initState() {
    super.initState();
    _mathController = MathFieldEditingController();
    _textController = TextEditingController();
    _textFocusNode = FocusNode();
    _mathFocusNode = FocusNode();

    // Listen to text controller changes and combine inputs
    _textController.addListener(() {
      _combineInputs();
    });

    // Listen to math controller changes and combine inputs
    _mathController.addListener(() {
      _combineInputs();
    });
  }

  @override
  void dispose() {
    _mathController.dispose();
    _textController.dispose();
    _textFocusNode.dispose();
    _mathFocusNode.dispose();
    super.dispose();
  }

  /// Clears both text and math input fields
  void clearAll() {
    _textController.clear();
    _mathController.clear();
    widget.controller.clear();
    widget.onChanged?.call('');
    widget.onClearAll?.call();
  }

  /// Combines both text and math inputs and updates the main controller
  void _combineInputs() {
    final textInput = _textController.text.trim();
    final mathInput = _mathController.currentEditingValue().toString().trim();

    String combinedInput = '';

    if (textInput.isNotEmpty && mathInput.isNotEmpty) {
      combinedInput = '$textInput\n\n$mathInput';
    } else if (textInput.isNotEmpty) {
      combinedInput = textInput;
    } else if (mathInput.isNotEmpty) {
      combinedInput = mathInput;
    }

    widget.controller.text = combinedInput;
    widget.onChanged?.call(combinedInput);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text field at the top
        SizedBox(
          height: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.text_fields,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Text Input',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(child: _buildTextField()),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Math field at the bottom
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calculate,
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Math Input',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  // Clear all button
                  TextButton.icon(
                    onPressed: clearAll,
                    icon: Icon(
                      Icons.clear_all,
                      size: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    label: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Submit button
                  if (widget.onSubmit != null)
                    ElevatedButton.icon(
                      onPressed: () {
                        _combineInputs();
                        widget.onSubmit?.call();
                      },
                      icon: Icon(
                        Icons.send,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                      label: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(child: _buildMathField()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextField(
      controller: _textController,
      focusNode: _textFocusNode,
      maxLines: widget.maxLines ?? 3,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Enter text with proper spacing...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 16,
        ),
      ),
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildMathField() {
    return MathField(
      controller: _mathController,
      focusNode: _mathFocusNode,
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
        hintText: 'Enter mathematical expression...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          fontSize: 16,
        ),
      ),
    );
  }
}
