import 'package:flutter/material.dart';

import 'body_medium_text_widget.dart';

class SuccessMessageWidget {
  static void showSucess(BuildContext context, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: BodyMediumTextWidget(text: successMessage),
      ),
    );
  }
}
