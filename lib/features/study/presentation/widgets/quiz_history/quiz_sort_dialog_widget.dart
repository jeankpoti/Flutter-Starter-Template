import 'package:flutter/material.dart';
import '../../models/quiz_history_enums.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../common_widgets/text_widgets.dart';

class QuizSortDialogWidget extends StatelessWidget {
  final SortOption currentSort;
  final Function(SortOption) onSortChanged;
  final String Function(SortOption) getSortLabel;

  // Spacing constants
  static const double _spacing2 = 8.0;
  static const double _spacing4 = 16.0;

  const QuizSortDialogWidget({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    required this.getSortLabel,
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
                  AppLocalizations.of(context)!.sortQuizzes,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: _spacing4),

                ...SortOption.values.map(
                  (sort) => ListTile(
                    leading: Radio<SortOption>(
                      value: sort,
                      groupValue: currentSort,
                      onChanged: (value) {
                        onSortChanged(value!);
                        Navigator.pop(context);
                      },
                      activeColor: Theme.of(context).colorScheme.secondary,
                    ),
                    title: BodyMediumText(getSortLabel(sort)),
                    onTap: () {
                      onSortChanged(sort);
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
    required SortOption currentSort,
    required Function(SortOption) onSortChanged,
    required String Function(SortOption) getSortLabel,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => QuizSortDialogWidget(
        currentSort: currentSort,
        onSortChanged: onSortChanged,
        getSortLabel: getSortLabel,
      ),
    );
  }
}