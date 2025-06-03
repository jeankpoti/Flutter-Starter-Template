import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common_widgets/body_medium_text_widget.dart';
import '../common_widgets/title_medium_text_widget.dart';
import '../constants/terms_conditions.dart';

class TermsConditionsWidget {
  static void termsConditionsWidget({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: TitleMediumTextWidget(text: 'Terms and Conditions'),
              content: SingleChildScrollView(
                child: MarkdownBody(
                  data: TermsConditions().termsConditions,
                  styleSheet: MarkdownStyleSheet.fromTheme(
                    Theme.of(context),
                  ).copyWith(
                    p: Theme.of(context).textTheme.bodyMedium,
                    h1: Theme.of(context).textTheme.titleLarge,
                    h2: Theme.of(context).textTheme.titleMedium,
                    h3: Theme.of(context).textTheme.titleSmall,
                    listBullet: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  icon: Icon(
                    FontAwesomeIcons.xmark,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: BodyMediumTextWidget(text: 'Close'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
