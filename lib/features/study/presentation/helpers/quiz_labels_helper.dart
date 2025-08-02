import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../models/quiz_history_enums.dart';

class QuizLabelsHelper {
  static String getFilterLabel(BuildContext context, FilterOption filter) {
    switch (filter) {
      case FilterOption.all:
        return AppLocalizations.of(context)!.allFilter;
      case FilterOption.completed:
        return AppLocalizations.of(context)!.completedFilter;
      case FilterOption.inProgress:
        return AppLocalizations.of(context)!.inProgressFilter;
      case FilterOption.easy:
        return AppLocalizations.of(context)!.easyFilter;
      case FilterOption.medium:
        return AppLocalizations.of(context)!.mediumFilter;
      case FilterOption.hard:
        return AppLocalizations.of(context)!.hardFilter;
    }
  }

  static String getSortLabel(BuildContext context, SortOption sort) {
    switch (sort) {
      case SortOption.dateNewest:
        return AppLocalizations.of(context)!.newestSort;
      case SortOption.dateOldest:
        return AppLocalizations.of(context)!.oldestSort;
      case SortOption.scoreHighest:
        return AppLocalizations.of(context)!.highScoreSort;
      case SortOption.scoreLowest:
        return AppLocalizations.of(context)!.lowScoreSort;
      case SortOption.titleAZ:
        return AppLocalizations.of(context)!.azSort;
      case SortOption.titleZA:
        return AppLocalizations.of(context)!.zaSort;
    }
  }
}