import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common_widgets/text_widgets.dart';
import '../constants/terms_conditions.dart';
import '../l10n/app_localizations.dart';

class TermsConditionsWidget {
  // TODO: Add localized terms and conditions for each language
  // For now, using the same English template for all languages
  static String _getLocalizedTerms(BuildContext context) {
    return TermsConditions().termsConditions;
  }

  static void termsConditionsWidget({required BuildContext context}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: TitleMediumText(AppLocalizations.of(context)!.termsAndConditions),
              content: SingleChildScrollView(
                child: MarkdownBody(
                  data: _getLocalizedTerms(context),
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
                  icon: FaIcon(
                    FontAwesomeIcons.xmark,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  label: BodyMediumText(AppLocalizations.of(context)!.close),
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
