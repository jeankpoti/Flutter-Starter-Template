import 'package:flutter/material.dart';
import 'enhanced_math_keyboard_widget.dart';
import 'keyboard_animations.dart';

class FloatingMathKeyboard extends StatelessWidget {
  final TextEditingController controller;
  final Function(String symbol)? onSymbolTap;
  final VoidCallback? onClose;

  const FloatingMathKeyboard({
    super.key,
    required this.controller,
    this.onSymbolTap,
    this.onClose,
  });

  static Future<void> show(
    BuildContext context, {
    required TextEditingController controller,
    Function(String symbol)? onSymbolTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => FloatingMathKeyboard(
        controller: controller,
        onSymbolTap: onSymbolTap,
        onClose: () => Navigator.of(context).pop(),
      ),
    ).then((_) {});
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardSlideTransition(
      isVisible: true,
      onDismiss: onClose,
      child: ResizableContainer(
        minHeight: 280,
        maxHeight: 400,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: EnhancedMathKeyboardWidget(
                    controller: controller,
                    onSymbolTap: onSymbolTap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.calculate_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Math Keyboard',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.keyboard_hide,
                    size: 16,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}