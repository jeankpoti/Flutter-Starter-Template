import 'package:flutter/material.dart';
import 'text_widgets.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class AppSnackBar {
  /// Shows a success SnackBar with proper theming
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      type: SnackBarType.success,
      duration: duration,
      action: action,
    );
  }

  /// Shows an error SnackBar with proper theming
  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      type: SnackBarType.error,
      duration: duration,
      action: action,
    );
  }

  /// Shows a warning SnackBar with proper theming
  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      type: SnackBarType.warning,
      duration: duration,
      action: action,
    );
  }

  /// Shows an info SnackBar with proper theming
  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    _showSnackBar(
      context,
      message,
      type: SnackBarType.info,
      duration: duration,
      action: action,
    );
  }

  /// Generic method to show a custom SnackBar
  static void showCustom(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    IconData? icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: BodyMediumText(
                  message,
                  color: textColor ?? Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
          duration: duration,
          action: action,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  static void _showSnackBar(
    BuildContext context,
    String message, {
    required SnackBarType type,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    Color backgroundColor;
    Color textColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        backgroundColor = colorScheme.secondaryContainer;
        textColor = colorScheme.onSecondaryContainer;
        icon = Icons.check_circle_outline;
        break;
      case SnackBarType.error:
        backgroundColor = colorScheme.errorContainer;
        textColor = colorScheme.onErrorContainer;
        icon = Icons.error_outline;
        break;
      case SnackBarType.warning:
        backgroundColor = colorScheme.surfaceContainerHighest;
        textColor = colorScheme.onSurface;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackBarType.info:
        backgroundColor = colorScheme.surfaceContainer;
        textColor = colorScheme.onSurface;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                icon,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: BodyMediumText(
                  message,
                  color: textColor,
                ),
              ),
            ],
          ),
          backgroundColor: backgroundColor,
          duration: duration,
          action: action != null
              ? SnackBarAction(
                  label: action.label,
                  onPressed: action.onPressed,
                  textColor: textColor,
                  disabledTextColor: action.disabledTextColor,
                )
              : null,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  /// Hides the current SnackBar if any
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clears all SnackBars
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }
}