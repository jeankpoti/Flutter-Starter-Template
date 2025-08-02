import 'package:flutter/material.dart';
import '../../models/quiz_history_enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';

class QuizFilterDialogWidget extends StatelessWidget {
  final FilterOption currentFilter;
  final Function(FilterOption) onFilterChanged;
  final String Function(FilterOption) getFilterLabel;

  // Spacing constants
  static const double _spacing2 = 8.0;
  static const double _spacing4 = 16.0;

  const QuizFilterDialogWidget({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
    required this.getFilterLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(_spacing4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleMediumText(
                  AppLocalizations.of(context)!.filterQuizzes,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: _spacing4),

                ...FilterOption.values.map(
                  (filter) => ListTile(
                    leading: Radio<FilterOption>(
                      value: filter,
                      groupValue: currentFilter,
                      onChanged: (value) {
                        onFilterChanged(value!);
                        Navigator.pop(context);
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                    title: BodyMediumText(getFilterLabel(filter)),
                    onTap: () {
                      onFilterChanged(filter);
                      Navigator.pop(context);
                    },
                  ),
                ),

                const SizedBox(height: _spacing2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void show({
    required BuildContext context,
    required FilterOption currentFilter,
    required Function(FilterOption) onFilterChanged,
    required String Function(FilterOption) getFilterLabel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizFilterDialogWidget(
        currentFilter: currentFilter,
        onFilterChanged: onFilterChanged,
        getFilterLabel: getFilterLabel,
      ),
    );
  }
}