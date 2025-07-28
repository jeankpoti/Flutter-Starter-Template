import 'package:flutter/material.dart';
import '../domain/models/quiz.dart';
import '../data/services/quiz_service.dart';
import 'quiz_review_page.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../l10n/app_localizations.dart';

enum SortOption {
  dateNewest,
  dateOldest,
  scoreHighest,
  scoreLowest,
  titleAZ,
  titleZA,
}

enum FilterOption { all, completed, inProgress, easy, medium, hard }

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
  static const double _spacing2 = 8.0;
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
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(_spacing4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.searchQuizzes,
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () {
                                _searchController.clear();
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
                  Expanded(child: _buildFilterChip()),
                  const SizedBox(width: _spacing2),
                  Expanded(child: _buildSortChip()),
                ],
              ),

              // Results count
              if (_searchQuery.isNotEmpty || _currentFilter != FilterOption.all)
                Padding(
                  padding: const EdgeInsets.only(top: _spacing2),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BodySmallText(
                      _filteredQuizHistory.length == 1
                          ? AppLocalizations.of(context)!.resultsCount(_filteredQuizHistory.length)
                          : AppLocalizations.of(context)!.resultsCountPlural(_filteredQuizHistory.length),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Quiz List
        Expanded(child: _buildQuizList()),
      ],
    );
  }

  Widget _buildQuizList() {
    if (_quizHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.quiz,
        title: AppLocalizations.of(context)!.noQuizHistory,
        subtitle: AppLocalizations.of(context)!.noQuizHistorySubtitle,
      );
    }

    if (_filteredQuizHistory.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off,
        title: AppLocalizations.of(context)!.noResultsFound,
        subtitle: AppLocalizations.of(context)!.noResultsFoundSubtitle,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadQuizData,
      child: ListView.builder(
        padding: const EdgeInsets.all(_spacing4),
        itemCount: _filteredQuizHistory.length,
        itemBuilder: (context, index) {
          final quiz = _filteredQuizHistory[index];
          return _buildQuizHistoryCard(quiz, index);
        },
      ),
    );
  }

  Widget _buildQuizHistoryCard(Quiz quiz, int index) {
    final score = quiz.lastScore ?? 0.0;
    final completedAt = quiz.lastAttemptAt;

    return TweenAnimationBuilder(
      duration: Duration(
        milliseconds: 300 + (index * 50),
      ), // Staggered animation
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: _spacing3),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.08),
              offset: const Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToQuizReview(quiz),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(_spacing4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TitleMediumText(
                          quiz.title,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getScoreColor(score).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LabelMediumText(
                          '${score.toStringAsFixed(1)}%',
                          fontWeight: FontWeight.w600,
                          color: _getScoreColor(score),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.quiz,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      BodySmallText(
                        '${quiz.questions.length} ${AppLocalizations.of(context)!.questions}',
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.signal_cellular_alt,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      BodySmallText(
                        quiz.difficulty.name.toUpperCase(),
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      if (quiz.attemptCount > 1) ...[
                        const SizedBox(width: 16),
                        Icon(
                          Icons.repeat,
                          size: 16,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 4),
                        BodySmallText(
                          '${quiz.attemptCount} ${AppLocalizations.of(context)!.attempts}',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (completedAt != null)
                    BodySmallText(
                      '${AppLocalizations.of(context)!.completedOn} ${_formatDate(completedAt)}',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),

                  const SizedBox(height: 12),

                  // Performance summary
                  Row(
                    children: [
                      Expanded(
                        child: _buildPerformanceChip(
                          icon: Icons.check_circle,
                          label: AppLocalizations.of(context)!.correct,
                          value:
                              quiz.userAnswers.where((a) => a.isCorrect).length,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: _spacing2),
                      Expanded(
                        child: _buildPerformanceChip(
                          icon: Icons.cancel,
                          label: AppLocalizations.of(context)!.incorrect,
                          value:
                              quiz.userAnswers
                                  .where((a) => !a.isCorrect)
                                  .length,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(width: _spacing2),
                      Expanded(
                        child: _buildPerformanceChip(
                          icon: Icons.help_outline,
                          label: AppLocalizations.of(context)!.unanswered,
                          value: _calculateUnansweredCount(quiz),
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceChip({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          LabelMediumText(
            value.toString(),
            fontWeight: FontWeight.bold,
            color: color,
          ),
          LabelSmallText(
            label,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview stats
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.analytics,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    TitleLargeText(
                      AppLocalizations.of(context)!.quizStatistics,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: AppLocalizations.of(context)!.totalQuizzes,
                        value: _statistics['totalQuizzes']?.toString() ?? '0',
                        icon: Icons.quiz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: AppLocalizations.of(context)!.averageScore,
                        value:
                            '${(_statistics['averageScore'] ?? 0.0).toStringAsFixed(1)}%',
                        icon: Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: AppLocalizations.of(context)!.bestScore,
                        value:
                            '${(_statistics['bestScore'] ?? 0.0).toStringAsFixed(1)}%',
                        icon: Icons.emoji_events,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: AppLocalizations.of(context)!.currentStreak,
                        value: '${_statistics['streakCount'] ?? 0} ${AppLocalizations.of(context)!.days}',
                        icon: Icons.local_fire_department,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Detailed statistics
          TitleMediumText(
            AppLocalizations.of(context)!.detailedStatistics,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildDetailedStatCard(
                  title: AppLocalizations.of(context)!.questionsAnswered,
                  value:
                      _statistics['totalQuestionsAnswered']?.toString() ?? '0',
                  subtitle: AppLocalizations.of(context)!.totalQuestionsAttempted,
                  icon: Icons.help_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailedStatCard(
                  title: AppLocalizations.of(context)!.correctAnswers,
                  value: _statistics['totalCorrectAnswers']?.toString() ?? '0',
                  subtitle: AppLocalizations.of(context)!.questionsAnsweredCorrectly,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent activity
          if (_statistics['recentActivity'] != null &&
              (_statistics['recentActivity'] as List).isNotEmpty) ...[
            TitleMediumText(
              AppLocalizations.of(context)!.recentActivity,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),

            ...(_statistics['recentActivity'] as List<Map<String, dynamic>>)
                .take(5)
                .map((activity) => _buildRecentActivityCard(activity)),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
          const SizedBox(height: 8),
          TitleLargeText(
            value,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          BodySmallText(
            title,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TitleSmallText(
                  title,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          HeadlineSmallText(
            value,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
          ),
          BodySmallText(
            subtitle,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityCard(Map<String, dynamic> activity) {
    final score = activity['score'] as double?;
    final completedAt = activity['completedAt'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.quiz,
              color: Theme.of(context).colorScheme.secondary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BodyMediumText(
                  activity['title'] ?? AppLocalizations.of(context)!.quiz,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                if (completedAt != null)
                  BodySmallText(
                    _formatDate(DateTime.parse(completedAt)),
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
          if (score != null)
            LabelMediumText(
              '${score.toStringAsFixed(1)}%',
              fontWeight: FontWeight.w600,
              color: _getScoreColor(score),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    if (_performanceTrends.isEmpty) {
      return _buildEmptyState(
        icon: Icons.trending_up,
        title: AppLocalizations.of(context)!.noProgressData,
        subtitle: AppLocalizations.of(context)!.noProgressDataSubtitle,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleMediumText(
            AppLocalizations.of(context)!.performanceTrends,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          // Simple progress chart representation
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TitleSmallText(
                      AppLocalizations.of(context)!.averageScoreTrend,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodySmallText(
                      '${_performanceTrends.length} ${AppLocalizations.of(context)!.daysWithActivity}',
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Simple bar chart representation
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _performanceTrends.length,
                    itemBuilder: (context, index) {
                      final trend = _performanceTrends[index];
                      final score = trend['averageScore'] as double;
                      final height =
                          (score / 100) * 150; // Scale to 150px max height

                      return Container(
                        width: 30,
                        margin: const EdgeInsets.only(right: 8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                color: _getScoreColor(score),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 8),
                            LabelSmallText(
                              '${score.toStringAsFixed(0)}%',
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Progress insights
          TitleMediumText(
            AppLocalizations.of(context)!.progressInsights,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),

          if (_performanceTrends.isNotEmpty) ...[
            _buildInsightCard(
              icon: Icons.show_chart,
              title: AppLocalizations.of(context)!.recentPerformance,
              description: _getPerformanceInsight(),
            ),
            const SizedBox(height: 12),
            _buildInsightCard(
              icon: Icons.calendar_today,
              title: AppLocalizations.of(context)!.activityPattern,
              description:
                  AppLocalizations.of(context)!.activityPatternDescription(_performanceTrends.length),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.secondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TitleSmallText(
                  title,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 4),
                BodySmallText(
                  description,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            TitleMediumText(
              title,
              fontWeight: FontWeight.w600,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 8),
            BodyMediumText(
              subtitle,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Color _getScoreColor(double score) {
    if (score >= 80) return Theme.of(context).colorScheme.secondary;
    if (score >= 60) return Theme.of(context).colorScheme.tertiary;
    return Theme.of(context).colorScheme.error;
  }

  int _calculateUnansweredCount(Quiz quiz) {
    // Count questions that either have no answer entry or have null answers (skipped)
    final answeredQuestionIds =
        quiz.userAnswers
            .where(
              (answer) =>
                  answer.selectedAnswerId != null || answer.textAnswer != null,
            )
            .map((answer) => answer.questionId)
            .toSet();

    return quiz.questions.length - answeredQuestionIds.length;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return AppLocalizations.of(context)!.today;
    } else if (difference == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getPerformanceInsight() {
    if (_performanceTrends.isEmpty) return AppLocalizations.of(context)!.noRecentActivity;

    final recent =
        _performanceTrends.length > 5
            ? _performanceTrends.skip(_performanceTrends.length - 5).toList()
            : _performanceTrends;
    final scores = recent.map((t) => t['averageScore'] as double).toList();

    if (scores.length < 2) {
      return AppLocalizations.of(context)!.takeMoreQuizzes;
    }

    final trend = scores.last - scores.first;

    if (trend > 5) {
      return AppLocalizations.of(context)!.performanceImprovement;
    } else if (trend < -5) {
      return AppLocalizations.of(context)!.performanceDecline;
    } else {
      return AppLocalizations.of(context)!.performanceConsistent;
    }
  }

  Widget _buildFilterChip() {
    return InkWell(
      onTap: _showFilterDialog,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _spacing3,
          vertical: _spacing2,
        ),
        decoration: BoxDecoration(
          color:
              _currentFilter != FilterOption.all
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                _currentFilter != FilterOption.all
                    ? Theme.of(context).colorScheme.secondary
                    : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.filter_list,
              size: 16,
              color:
                  _currentFilter != FilterOption.all
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            LabelMediumText(
              _getFilterLabel(_currentFilter),
              color:
                  _currentFilter != FilterOption.all
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortChip() {
    return InkWell(
      onTap: _showSortDialog,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 4),
            LabelMediumText(
              _getSortLabel(_currentSort),
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ],
        ),
      ),
    );
  }

  String _getFilterLabel(FilterOption filter) {
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

  String _getSortLabel(SortOption sort) {
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

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
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
                            groupValue: _currentFilter,
                            onChanged: (value) {
                              setState(() {
                                _currentFilter = value!;
                                _applyFiltersAndSort();
                              });
                              Navigator.pop(context);
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          title: BodyMediumText(_getFilterLabel(filter)),
                          onTap: () {
                            setState(() {
                              _currentFilter = filter;
                              _applyFiltersAndSort();
                            });
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
          ),
    );
  }

  void _showSortDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
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
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
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
                            groupValue: _currentSort,
                            onChanged: (value) {
                              setState(() {
                                _currentSort = value!;
                                _applyFiltersAndSort();
                              });
                              Navigator.pop(context);
                            },
                            activeColor:
                                Theme.of(context).colorScheme.secondary,
                          ),
                          title: BodyMediumText(_getSortLabel(sort)),
                          onTap: () {
                            setState(() {
                              _currentSort = sort;
                              _applyFiltersAndSort();
                            });
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
          ),
    );
  }

  void _navigateToQuizReview(Quiz quiz) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => QuizReviewPage(quiz: quiz)));
  }
}
