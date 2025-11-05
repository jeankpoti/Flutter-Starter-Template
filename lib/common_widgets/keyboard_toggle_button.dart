import 'package:flutter/material.dart';

class KeyboardToggleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isActive;
  final String? tooltip;

  const KeyboardToggleButton({
    super.key,
    required this.onPressed,
    this.isActive = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? 'Open Math Keyboard',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            Icons.calculate,
            size: 20,
            color: isActive 
              ? Theme.of(context).colorScheme.onPrimary
              : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class FloatingKeyboardButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isVisible;

  const FloatingKeyboardButton({
    super.key,
    required this.onPressed,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Theme.of(context).colorScheme.primary,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 8,
      mini: true,
      child: const Icon(Icons.calculate, size: 20),
    );
  }
}