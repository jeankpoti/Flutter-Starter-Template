import 'dart:async';
import 'package:flutter/material.dart';
import '../domain/models/quiz.dart';
import '../data/services/quiz_service.dart';
import 'quiz_review_page.dart';
import '../../../common_widgets/math_symbols_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../l10n/app_localizations.dart';

class QuizPage extends StatefulWidget {
  final Quiz quiz;

  const QuizPage({super.key, required this.quiz});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final QuizService _quizService = QuizService();
  final PageController _pageController = PageController();

  late Quiz _currentQuiz;
  int _currentQuestionIndex = 0;
  Timer? _timer;
  int _remainingTime = 0; // in seconds
  bool _isQuizCompleted = false;

  // User answers tracking
  final Map<String, String?> _selectedAnswers = {};
  final Map<String, String?> _textAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};

  @override
  void initState() {
    super.initState();
    _currentQuiz = widget.quiz;
    _initializeQuiz();
  }

  void _initializeQuiz() {
    if (_currentQuiz.timeLimit > 0) {
      _remainingTime =
          _currentQuiz.timeLimit * 60; // Convert minutes to seconds
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        _finishQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    // Dispose all text controllers
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: TitleLargeText(AppLocalizations.of(context)!.quiz)),
        body: Center(child: BodyMediumText(AppLocalizations.of(context)!.noQuestionsAvailable)),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmation();
        if (shouldExit && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: TitleLargeText(_currentQuiz.title),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldExit = await _showExitConfirmation();
              if (shouldExit && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
        body: Column(
          children: [
            _buildQuizHeader(),
            Expanded(
              child:
                  _isQuizCompleted ? _buildQuizResults() : _buildQuizContent(),
            ),
            if (!_isQuizCompleted) _buildQuizNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizHeader() {
    final progress =
        (_currentQuestionIndex + 1) / _currentQuiz.questions.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Progress bar
          Row(
            children: [
              TitleMediumText(
                AppLocalizations.of(context)!.questionProgress(_currentQuestionIndex + 1, _currentQuiz.questions.length),
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const Spacer(),
              if (_currentQuiz.timeLimit > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        _remainingTime <
                                300 // Less than 5 minutes
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        size: 16,
                        color:
                            _remainingTime < 300
                                ? Theme.of(context).colorScheme.onErrorContainer
                                : Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                      ),
                      const SizedBox(width: 4),
                      LabelLargeText(
                        _formatTime(_remainingTime),
                        fontWeight: FontWeight.w600,
                        color:
                            _remainingTime < 300
                                ? Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer
                                : Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizContent() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentQuestionIndex = index;
        });
      },
      itemCount: _currentQuiz.questions.length,
      itemBuilder: (context, index) {
        final question = _currentQuiz.questions[index];
        return _buildQuestionCard(question);
      },
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LabelSmallText(
                        _getQuestionTypeLabel(question.type),
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.onSecondaryContainer,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: LabelSmallText(
                        AppLocalizations.of(context)!.pointsDisplay(question.pointValue, question.pointValue == 1 ? AppLocalizations.of(context)!.point : AppLocalizations.of(context)!.points),
                        fontWeight: FontWeight.w600,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AppTextWidget(
                  question.questionText,
                  style: Theme.of(context).textTheme.titleMedium,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                  height: 1.4,
                ),
                if (question.hint != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppTextWidget(
                            AppLocalizations.of(context)!.hintLabel(question.hint!),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Answer options
          _buildAnswerSection(question),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(QuizQuestion question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return _buildMultipleChoiceAnswers(question);
      case QuestionType.trueFalse:
        return _buildTrueFalseAnswers(question);
      case QuestionType.shortAnswer:
        return _buildShortAnswerInput(question);
      case QuestionType.fillInTheBlank:
        return _buildFillInBlankInput(question);
    }
  }

  Widget _buildMultipleChoiceAnswers(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.selectCorrectAnswer,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        ...question.answers.asMap().entries.map((entry) {
          final index = entry.key;
          final answer = entry.value;
          final isSelected = _selectedAnswers[question.id] == answer.id;
          final optionLetter = String.fromCharCode(65 + index); // A, B, C, D

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedAnswers[question.id] = answer.id;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.secondaryContainer
                              .withValues(alpha: 0.5)
                          : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.transparent,
                        border: Border.all(
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.secondary
                                  : Theme.of(context).colorScheme.outline,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: TitleSmallText(
                          optionLetter,
                          fontWeight: FontWeight.bold,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.onSecondary
                                  : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BodyMediumText(
                        answer.text,
                        color: Theme.of(context).colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTrueFalseAnswers(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.selectTrueFalse,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Row(
          children:
              question.answers.map((answer) {
                final isSelected = _selectedAnswers[question.id] == answer.id;
                final isTrue = answer.text.toLowerCase() == 'true';

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      right: isTrue ? 8 : 0,
                      left: isTrue ? 0 : 8,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedAnswers[question.id] = answer.id;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? (isTrue
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1))
                                  : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                isSelected
                                    ? (isTrue ? Colors.green : Colors.red)
                                    : Theme.of(context).colorScheme.outline
                                        .withValues(alpha: 0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                isTrue ? Icons.check_circle : Icons.cancel,
                                color:
                                    isSelected
                                        ? (isTrue ? Colors.green : Colors.red)
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              TitleMediumText(
                                answer.text,
                                fontWeight: FontWeight.w600,
                                color:
                                    isSelected
                                        ? (isTrue ? Colors.green : Colors.red)
                                        : Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildShortAnswerInput(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.enterYourAnswer,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            TextField(
              onChanged: (value) {
                _textAnswers[question.id] = value;
              },
              controller: _getTextController(question.id),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.typeAnswerHere,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            MathSymbolsWidget(controller: _getTextController(question.id)),
          ],
        ),
      ],
    );
  }

  Widget _buildFillInBlankInput(QuizQuestion question) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleMediumText(
          AppLocalizations.of(context)!.fillInBlank,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            TextField(
              onChanged: (value) {
                _textAnswers[question.id] = value;
              },
              controller: _getTextController(question.id),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.enterMissingWord,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            MathSymbolsWidget(controller: _getTextController(question.id)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuizNavigation() {
    final canGoBack = _currentQuestionIndex > 0;
    final isLastQuestion =
        _currentQuestionIndex == _currentQuiz.questions.length - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (canGoBack)
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _goToPreviousQuestion,
                icon: const Icon(Icons.arrow_back),
                label: LabelLargeText(AppLocalizations.of(context)!.previous),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 16),

          Expanded(
            child: ElevatedButton.icon(
              onPressed: isLastQuestion ? _finishQuiz : _goToNextQuestion,
              icon: Icon(isLastQuestion ? Icons.check : Icons.arrow_forward),
              label: LabelLargeText(isLastQuestion ? AppLocalizations.of(context)!.finishQuiz : AppLocalizations.of(context)!.next),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizResults() {
    final score = _currentQuiz.calculateScore();
    final summary = _currentQuiz.getPerformanceSummary();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Score card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  score >= 80
                      ? Icons.celebration
                      : score >= 60
                      ? Icons.thumb_up
                      : Icons.refresh,
                  size: 64,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                HeadlineSmallText(
                  AppLocalizations.of(context)!.quizCompleted,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(height: 8),
                DisplayMediumText(
                  '${score.toStringAsFixed(1)}%',
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(height: 16),
                BodyLargeText(
                  _getScoreMessage(score),
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Performance breakdown
          _buildPerformanceBreakdown(summary),

          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.home),
                  label: LabelLargeText(AppLocalizations.of(context)!.backToStudy),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _retakeQuiz,
                  icon: const Icon(Icons.refresh),
                  label: LabelLargeText(AppLocalizations.of(context)!.retakeQuiz),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown(Map<String, int> summary) {
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
          TitleMediumText(
            AppLocalizations.of(context)!.performanceBreakdown,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                label: AppLocalizations.of(context)!.correct,
                value: summary['correct']!,
                color: Colors.green,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                label: AppLocalizations.of(context)!.incorrect,
                value: summary['incorrect']!,
                color: Colors.red,
              ),
              _buildStatItem(
                icon: Icons.help_outline,
                label: AppLocalizations.of(context)!.unanswered,
                value: summary['unanswered']!,
                color: Colors.orange,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // View Detailed Review Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToDetailedReview(),
              icon: const Icon(Icons.visibility),
              label: LabelLargeText(AppLocalizations.of(context)!.viewDetailedReview),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          TitleLargeText(
            value.toString(),
            fontWeight: FontWeight.bold,
            color: color,
          ),
          LabelMediumText(
            label,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  // Navigation methods
  void _goToPreviousQuestion() {
    if (_currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNextQuestion() {
    if (_currentQuestionIndex < _currentQuiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _navigateToDetailedReview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => QuizReviewPage(quiz: _currentQuiz),
      ),
    );
  }

  void _finishQuiz() {
    _timer?.cancel();

    // Process all answers
    final userAnswers = <UserQuizAnswer>[];

    for (final question in _currentQuiz.questions) {
      final userAnswer = _quizService.submitAnswer(
        questionId: question.id,
        question: question,
        selectedAnswerId: _selectedAnswers[question.id],
        textAnswer: _textAnswers[question.id],
      );
      userAnswers.add(userAnswer);
    }

    // Update quiz with results
    final quizWithAnswers = _currentQuiz.copyWith(userAnswers: userAnswers);

    final completedQuiz = quizWithAnswers.copyWith(
      status: QuizStatus.completed,
      lastScore: quizWithAnswers.calculateScore(),
      lastAttemptAt: DateTime.now(),
      attemptCount: _currentQuiz.attemptCount + 1,
    );

    setState(() {
      _currentQuiz = completedQuiz;
      _isQuizCompleted = true;
    });

    // Save quiz to history
    _saveQuizToHistory(completedQuiz);
  }

  void _retakeQuiz() {
    setState(() {
      _currentQuiz = _currentQuiz.copyWith(
        status: QuizStatus.notStarted,
        userAnswers: [],
        lastScore: null,
      );
      _currentQuestionIndex = 0;
      _selectedAnswers.clear();
      _textAnswers.clear();
      _isQuizCompleted = false;
    });

    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    _initializeQuiz();
  }

  // Text controller management
  TextEditingController _getTextController(String questionId) {
    if (!_textControllers.containsKey(questionId)) {
      _textControllers[questionId] = TextEditingController(
        text: _textAnswers[questionId] ?? '',
      );
      _textControllers[questionId]!.addListener(() {
        _textAnswers[questionId] = _textControllers[questionId]!.text;
      });
    }
    return _textControllers[questionId]!;
  }

  // Helper methods
  String _getQuestionTypeLabel(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return AppLocalizations.of(context)!.multipleChoice;
      case QuestionType.shortAnswer:
        return AppLocalizations.of(context)!.shortAnswer;
      case QuestionType.trueFalse:
        return AppLocalizations.of(context)!.trueFalse;
      case QuestionType.fillInTheBlank:
        return AppLocalizations.of(context)!.fillInTheBlank;
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getScoreMessage(double score) {
    if (score >= 90) {
      return AppLocalizations.of(context)!.excellentWork;
    } else if (score >= 80) {
      return AppLocalizations.of(context)!.greatJob;
    } else if (score >= 70) {
      return AppLocalizations.of(context)!.goodWork;
    } else if (score >= 60) {
      return AppLocalizations.of(context)!.fairPerformance;
    } else {
      return AppLocalizations.of(context)!.reviewMaterial;
    }
  }

  Future<bool> _showExitConfirmation() async {
    if (_isQuizCompleted) return true;

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: TitleMediumText(AppLocalizations.of(context)!.exitQuiz),
                content: BodyMediumText(
                  AppLocalizations.of(context)!.exitQuizConfirmation,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: LabelLargeText(AppLocalizations.of(context)!.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: LabelLargeText(AppLocalizations.of(context)!.exit),
                  ),
                ],
              ),
        ) ??
        false;
  }

  Future<void> _saveQuizToHistory(Quiz quiz) async {
    try {
      debugPrint(
        'Saving quiz to history: ${quiz.id}, attemptCount: ${quiz.attemptCount}',
      );
      debugPrint('Quiz status: ${quiz.status}, score: ${quiz.lastScore}');

      if (quiz.attemptCount == 1) {
        // First attempt - save new quiz
        await _quizService.saveQuizToHistory(quiz);
        debugPrint('Quiz saved successfully as new quiz');
      } else {
        // Retake - update existing quiz
        await _quizService.updateQuizInHistory(quiz);
        debugPrint('Quiz updated successfully');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: BodyMediumText(
              AppLocalizations.of(context)!.quizResultsSaved,
              color: Theme.of(context).colorScheme.onSecondary,
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving quiz to history: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: BodyMediumText(AppLocalizations.of(context)!.failedToSaveResults(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
