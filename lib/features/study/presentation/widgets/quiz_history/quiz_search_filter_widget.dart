import 'package:flutter/material.dart';
import '../../../../../../common_widgets/text_widgets.dart';
import '../../../../../../l10n/app_localizations.dart';
import '../../models/quiz_history_enums.dart';

class QuizSearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final FilterOption currentFilter;
  final SortOption currentSort;
  final int resultCount;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final String Function(FilterOption) getFilterLabel;
  final String Function(SortOption) getSortLabel;

  const QuizSearchFilterWidget({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.currentFilter,
    required this.currentSort,
    required this.resultCount,
    required this.onFilterTap,
    required this.onSortTap,
    required this.getFilterLabel,
    required this.getSortLabel,
  });

  static const double _spacing2 = 8.0;
  static const double _spacing3 = 12.0;
  static const double _spacing4 = 16.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(_spacing4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.searchQuizzes,
                hintStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: _spacing4,
                  vertical: _spacing3,
                ),
              ),
            ),
          ),

          const SizedBox(height: _spacing3),

          // Filter and Sort Row
          Row(
            children: [
              Expanded(child: _buildFilterChip(context)),
              const SizedBox(width: _spacing2),
              Expanded(child: _buildSortChip(context)),
            ],
          ),

          // Results count
          if (searchQuery.isNotEmpty || currentFilter != FilterOption.all)
            Padding(
              padding: const EdgeInsets.only(top: _spacing2),
              child: Align(
                alignment: Alignment.centerLeft,
                child: BodySmallText(
                  resultCount == 1
                      ? AppLocalizations.of(context)!.resultsCount(resultCount)
                      : AppLocalizations.of(context)!.resultsCountPlural(resultCount),
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context) {
    return InkWell(
      onTap: onFilterTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _spacing3,
          vertical: _spacing2,
        ),
        decoration: BoxDecoration(
          color: currentFilter != FilterOption.all
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: currentFilter != FilterOption.all
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color: currentFilter != FilterOption.all
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            LabelMediumText(
              getFilterLabel(currentFilter),
              color: currentFilter != FilterOption.all
                  ? Theme.of(context).colorScheme.onSecondary
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip(BuildContext context) {
    return InkWell(
      onTap: onSortTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _spacing3,
          vertical: _spacing2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sort,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            LabelMediumText(
              getSortLabel(currentSort),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ],
        ),
      ),
    );
  }
}