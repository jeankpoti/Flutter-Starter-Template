import 'package:flutter/material.dart';

import 'text_widgets.dart';

class SuccessMessageWidget {
  static void showSucess(BuildContext context, String successMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        content: BodyMediumText(successMessage),
      ),
    );
  }
}
