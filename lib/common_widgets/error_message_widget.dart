import 'package:flutter/material.dart';

import 'text_widgets.dart';

class ErrorMessageWidget {
  static void showError(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: BodyMediumText(errorMessage),
      ),
    );
  }
}
