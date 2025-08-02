import 'package:flutter/material.dart';
import '../domain/models/quiz.dart';
import '../data/services/quiz_service.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../l10n/app_localizations.dart';

// Import models
import 'models/quiz_history_enums.dart';

// Import widgets
import 'widgets/quiz_history/quiz_history_tab_widget.dart';
import 'widgets/quiz_history/quiz_statistics_tab_widget.dart';
import 'widgets/quiz_history/quiz_progress_tab_widget.dart';
import 'widgets/quiz_history/quiz_filter_dialog_widget.dart';
import 'widgets/quiz_history/quiz_sort_dialog_widget.dart';

// Import helpers
import 'helpers/quiz_labels_helper.dart';

class QuizHistoryPage extends StatefulWidget {
  const QuizHistoryPage({super.key});

  @override
  State<QuizHistoryPage> createState() => _QuizHistoryPageState();
}

class _QuizHistoryPageState extends State<QuizHistoryPage>
    with SingleTickerProviderStateMixin {
  final QuizService _quizService = QuizService();
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  List<Quiz> _quizHistory = [];
  List<Quiz> _filteredQuizHistory = [];
  Map<String, dynamic> _statistics = {};
  List<Map<String, dynamic>> _performanceTrends = [];
  bool _isLoading = true;

  SortOption _currentSort = SortOption.dateNewest;
  FilterOption _currentFilter = FilterOption.all;
  String _searchQuery = '';

  // Spacing constants
  static const double _spacing3 = 12.0;
  static const double _spacing4 = 16.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
    _initializeAndLoadData();
  }

  Future<void> _initializeAndLoadData() async {
    try {
      await _quizService.initialize();
      await _loadQuizData();
    } catch (e) {
      debugPrint('Error initializing quiz service: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: BodyMediumText(AppLocalizations.of(context)!.errorInitializingQuizService),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    List<Quiz> filtered = List.from(_quizHistory);

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered.where((quiz) {
            return quiz.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                quiz.difficulty.name.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                );
          }).toList();
    }

    // Apply filter
    switch (_currentFilter) {
      case FilterOption.completed:
        filtered =
            filtered
                .where((quiz) => quiz.status == QuizStatus.completed)
                .toList();
        break;
      case FilterOption.inProgress:
        filtered =
            filtered
                .where((quiz) => quiz.status == QuizStatus.inProgress)
                .toList();
        break;
      case FilterOption.easy:
        filtered =
            filtered
                .where((quiz) => quiz.difficulty == QuizDifficulty.easy)
                .toList();
        break;
      case FilterOption.medium:
        filtered =
            filtered
                .where((quiz) => quiz.difficulty == QuizDifficulty.medium)
                .toList();
        break;
      case FilterOption.hard:
        filtered =
            filtered
                .where((quiz) => quiz.difficulty == QuizDifficulty.hard)
                .toList();
        break;
      case FilterOption.all:
        break;
    }

    // Apply sorting
    switch (_currentSort) {
      case SortOption.dateNewest:
        filtered.sort(
          (a, b) => (b.lastAttemptAt ?? b.createdAt).compareTo(
            a.lastAttemptAt ?? a.createdAt,
          ),
        );
        break;
      case SortOption.dateOldest:
        filtered.sort(
          (a, b) => (a.lastAttemptAt ?? a.createdAt).compareTo(
            b.lastAttemptAt ?? b.createdAt,
          ),
        );
        break;
      case SortOption.scoreHighest:
        filtered.sort(
          (a, b) => (b.lastScore ?? 0.0).compareTo(a.lastScore ?? 0.0),
        );
        break;
      case SortOption.scoreLowest:
        filtered.sort(
          (a, b) => (a.lastScore ?? 0.0).compareTo(b.lastScore ?? 0.0),
        );
        break;
      case SortOption.titleAZ:
        filtered.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        filtered.sort((a, b) => b.title.compareTo(a.title));
        break;
    }

    _filteredQuizHistory = filtered;
  }

  Future<void> _loadQuizData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Loading quiz data...');

      final futures = await Future.wait([
        _quizService.getQuizHistory(),
        _quizService.getQuizStatistics(),
        _quizService.getPerformanceTrends(days: 30),
      ]);

      final quizHistory = futures[0] as List<Quiz>;
      final statistics = futures[1] as Map<String, dynamic>;
      final performanceTrends = futures[2] as List<Map<String, dynamic>>;

      debugPrint('Loaded ${quizHistory.length} quizzes from history');
      debugPrint('Statistics: $statistics');
      debugPrint('Performance trends: ${performanceTrends.length} entries');

      setState(() {
        _quizHistory = quizHistory;
        _filteredQuizHistory = quizHistory;
        _statistics = statistics;
        _performanceTrends = performanceTrends;
        _isLoading = false;
        _applyFiltersAndSort();
      });
    } catch (e) {
      debugPrint('Error loading quiz data: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: BodyMediumText(AppLocalizations.of(context)!.errorLoadingQuizData)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleLargeText(AppLocalizations.of(context)!.quizHistory, fontWeight: FontWeight.bold),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _loadQuizData,
            tooltip: AppLocalizations.of(context)!.refreshData,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48.0),
          child: Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              indicatorColor: Theme.of(context).colorScheme.primary,
              indicatorWeight: 3.0,
              tabs: [
                Tab(icon: const Icon(Icons.history), text: AppLocalizations.of(context)!.history),
                Tab(icon: const Icon(Icons.analytics), text: AppLocalizations.of(context)!.statistics),
                Tab(icon: const Icon(Icons.trending_up), text: AppLocalizations.of(context)!.progress),
              ],
            ),
          ),
        ),
      ),
      body:
          _isLoading
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(_spacing4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: _spacing4),
                      BodyMediumText(
                        AppLocalizations.of(context)!.loadingQuizHistory,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 32),
                      // Loading skeleton for quiz cards
                      ...List.generate(
                        3,
                        (index) => Container(
                          margin: const EdgeInsets.only(bottom: _spacing3),
                          child: const LoadingTitleLargeText(width: 300),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const LoadingBodyMediumText(width: 250, lines: 2),
                    ],
                  ),
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildHistoryTab(),
                  _buildStatisticsTab(),
                  _buildProgressTab(),
                ],
              ),
    );
  }

  Widget _buildHistoryTab() {
    return QuizHistoryTabWidget(
      searchController: _searchController,
      searchQuery: _searchQuery,
      currentFilter: _currentFilter,
      currentSort: _currentSort,
      quizHistory: _quizHistory,
      filteredQuizHistory: _filteredQuizHistory,
      onFilterTap: _showFilterDialog,
      onSortTap: _showSortDialog,
      getFilterLabel: _getFilterLabel,
      getSortLabel: _getSortLabel,
      onRefresh: _loadQuizData,
    );
  }



  Widget _buildStatisticsTab() {
    return QuizStatisticsTabWidget(
      statistics: _statistics,
    );
  }

  Widget _buildProgressTab() {
    return QuizProgressTabWidget(
      performanceTrends: _performanceTrends,
    );
  }



  String _getFilterLabel(FilterOption filter) {
    return QuizLabelsHelper.getFilterLabel(context, filter);
  }

  String _getSortLabel(SortOption sort) {
    return QuizLabelsHelper.getSortLabel(context, sort);
  }

  void _showFilterDialog() {
    QuizFilterDialogWidget.show(
      context: context,
      currentFilter: _currentFilter,
      onFilterChanged: (filter) {
        setState(() {
          _currentFilter = filter;
          _applyFiltersAndSort();
        });
      },
      getFilterLabel: _getFilterLabel,
    );
  }

  void _showSortDialog() {
    QuizSortDialogWidget.show(
      context: context,
      currentSort: _currentSort,
      onSortChanged: (sort) {
        setState(() {
          _currentSort = sort;
          _applyFiltersAndSort();
        });
      },
      getSortLabel: _getSortLabel,
    );
  }
}
