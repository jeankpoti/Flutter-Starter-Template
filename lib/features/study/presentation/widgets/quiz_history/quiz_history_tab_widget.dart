import 'package:flutter/material.dart';
import '../../../domain/models/quiz.dart';
import '../../models/quiz_history_enums.dart';
import 'quiz_search_filter_widget.dart';
import 'quiz_empty_state_widget.dart';
import 'quiz_history_card_widget.dart';
import '../../helpers/date_format_helper.dart';
import '../../helpers/quiz_performance_helper.dart';
import '../../quiz_review_page.dart';
import '../../../../../l10n/app_localizations.dart';

class QuizHistoryTabWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final FilterOption currentFilter;
  final SortOption currentSort;
  final List<Quiz> quizHistory;
  final List<Quiz> filteredQuizHistory;
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;
  final String Function(FilterOption) getFilterLabel;
  final String Function(SortOption) getSortLabel;
  final Future<void> Function() onRefresh;

  // Spacing constants
  static const double _spacing4 = 16.0;

  const QuizHistoryTabWidget({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.currentFilter,
    required this.currentSort,
    required this.quizHistory,
    required this.filteredQuizHistory,
    required this.onFilterTap,
    required this.onSortTap,
    required this.getFilterLabel,
    required this.getSortLabel,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        QuizSearchFilterWidget(
          searchController: searchController,
          searchQuery: searchQuery,
          currentFilter: currentFilter,
          currentSort: currentSort,
          resultCount: filteredQuizHistory.length,
          onFilterTap: onFilterTap,
          onSortTap: onSortTap,
          getFilterLabel: getFilterLabel,
          getSortLabel: getSortLabel,
        ),

        // Quiz List
        Expanded(child: _buildQuizList(context)),
      ],
    );
  }

  Widget _buildQuizList(BuildContext context) {
    if (quizHistory.isEmpty) {
      return QuizEmptyStateWidget(
        icon: Icons.quiz,
        title: AppLocalizations.of(context)!.noQuizHistory,
        subtitle: AppLocalizations.of(context)!.noQuizHistorySubtitle,
      );
    }

    if (filteredQuizHistory.isEmpty) {
      return QuizEmptyStateWidget(
        icon: Icons.search_off,
        title: AppLocalizations.of(context)!.noResultsFound,
        subtitle: AppLocalizations.of(context)!.noResultsFoundSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(_spacing4),
        itemCount: filteredQuizHistory.length,
        itemBuilder: (context, index) {
          final quiz = filteredQuizHistory[index];
          return QuizHistoryCardWidget(
            quiz: quiz,
            index: index,
            onTap: () => _navigateToQuizReview(context, quiz),
            getScoreColor: (score) => QuizPerformanceHelper.getScoreColor(context, score),
            calculateUnansweredCount: QuizPerformanceHelper.calculateUnansweredCount,
            formatDate: (date) => DateFormatHelper.formatDate(context, date),
          );
        },
      ),
    );
  }

  void _navigateToQuizReview(BuildContext context, Quiz quiz) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QuizReviewPage(quiz: quiz)),
    );
  }
}