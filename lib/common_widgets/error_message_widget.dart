import 'package:flutter/material.dart';

import 'body_medium_text_widget.dart';

class ErrorMessageWidget {
  static void showError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: BodyMediumTextWidget(text: errorMessage),
      ),
    );
  }
}
