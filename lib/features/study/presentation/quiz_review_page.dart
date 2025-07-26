import 'package:flutter/material.dart';
import '../../../common_widgets/text_widgets.dart';
import '../domain/models/quiz.dart';

class QuizReviewPage extends StatelessWidget {
  final Quiz quiz;

  const QuizReviewPage({
    super.key,
    required this.quiz,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TitleLargeText('Quiz Review: ${quiz.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQuizResults(context),
            tooltip: 'Share Results',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Summary Card
            _buildQuizSummaryCard(context),
            
            const SizedBox(height: 24),
            
            // Questions Review
            TitleLargeText(
              'Questions Review',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            
            // Question Cards
            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionCard(context, question, index + 1);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizSummaryCard(BuildContext context) {
    final score = quiz.lastScore ?? 0.0;
    final summary = quiz.getPerformanceSummary();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.2),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getScoreIcon(score),
                  color: _getScoreColor(score),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(
                      quiz.title,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    TitleSmallText(
                      'Score: ${score.toStringAsFixed(1)}%',
                      fontWeight: FontWeight.w600,
                      color: _getScoreColor(score),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Performance Breakdown
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Correct',
                  summary['correct']!,
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Incorrect',
                  summary['incorrect']!,
                  Colors.red,
                  Icons.cancel,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Unanswered',
                  summary['unanswered']!,
                  Colors.orange,
                  Icons.help_outline,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Additional Info
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              BodySmallText(
                'Completed: ${_formatDate(quiz.lastAttemptAt ?? quiz.createdAt)}',
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.quiz,
                size: 16,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 4),
              BodySmallText(
                '${quiz.questions.length} questions',
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    int value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        const SizedBox(height: 4),
        TitleMediumText(
          value.toString(),
          fontWeight: FontWeight.bold,
          color: color,
        ),
        LabelSmallText(
          label,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(BuildContext context, QuizQuestion question, int questionNumber) {
    final userAnswer = quiz.userAnswers
        .where((ua) => ua.questionId == question.id)
        .firstOrNull;
    
    final isAnswered = userAnswer != null && 
        (userAnswer.selectedAnswerId != null || userAnswer.textAnswer != null);
    final isCorrect = userAnswer?.isCorrect ?? false;
    
    Color cardColor;
    IconData statusIcon;
    Color statusColor;
    
    if (!isAnswered) {
      cardColor = Colors.orange.withValues(alpha: 0.1);
      statusIcon = Icons.help_outline;
      statusColor = Colors.orange;
    } else if (isCorrect) {
      cardColor = Colors.green.withValues(alpha: 0.1);
      statusIcon = Icons.check_circle;
      statusColor = Colors.green;
    } else {
      cardColor = Colors.red.withValues(alpha: 0.1);
      statusIcon = Icons.cancel;
      statusColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: LabelMediumText(
                  'Q$questionNumber',
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                statusIcon,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: LabelMediumText(
                  _getStatusText(isAnswered, isCorrect),
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              if (question.pointValue > 1)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: LabelSmallText(
                    '${question.pointValue} pts',
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Question Text
          TitleMediumText(
            question.questionText,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          
          const SizedBox(height: 16),
          
          // Answer Section
          if (question.type == QuestionType.multipleChoice || 
              question.type == QuestionType.trueFalse)
            _buildMultipleChoiceAnswers(context, question, userAnswer)
          else
            _buildTextAnswers(context, question, userAnswer),
          
          // Topics
          if (question.relatedTopics.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: question.relatedTopics.map((topic) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LabelSmallText(
                  topic,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                ),
              )).toList(),
            ),
          ],
          
          // Explanation
          if (question.explanation != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(width: 6),
                      LabelMediumText(
                        'Explanation',
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  BodySmallText(
                    question.explanation!,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceAnswers(
    BuildContext context,
    QuizQuestion question,
    UserQuizAnswer? userAnswer,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: question.answers.map((answer) {
        final isUserSelected = userAnswer?.selectedAnswerId == answer.id;
        final isCorrectAnswer = answer.isCorrect;
        
        Color backgroundColor;
        Color borderColor;
        Color textColor;
        IconData? icon;
        
        if (isCorrectAnswer) {
          backgroundColor = Colors.green.withValues(alpha: 0.1);
          borderColor = Colors.green;
          textColor = Colors.green;
          icon = Icons.check_circle;
        } else if (isUserSelected && !isCorrectAnswer) {
          backgroundColor = Colors.red.withValues(alpha: 0.1);
          borderColor = Colors.red;
          textColor = Colors.red;
          icon = Icons.cancel;
        } else {
          backgroundColor = Theme.of(context).colorScheme.surface;
          borderColor = Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);
          textColor = Theme.of(context).colorScheme.onSurface;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: textColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: BodyMediumText(
                  answer.text,
                  color: textColor,
                  fontWeight: (isUserSelected || isCorrectAnswer) 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
              if (isUserSelected && !isCorrectAnswer)
                LabelSmallText(
                  'Your answer',
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              if (isCorrectAnswer)
                LabelSmallText(
                  'Correct answer',
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextAnswers(
    BuildContext context,
    QuizQuestion question,
    UserQuizAnswer? userAnswer,
  ) {
    final userAnswerText = userAnswer?.textAnswer ?? '';
    final correctAnswer = question.correctAnswerId ?? '';
    final isCorrect = userAnswer?.isCorrect ?? false;
    final wasAnswered = userAnswerText.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Your Answer
        if (wasAnswered) ...[
          LabelMediumText(
            'Your Answer:',
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCorrect 
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isCorrect ? Colors.green : Colors.red,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isCorrect ? Icons.check_circle : Icons.cancel,
                  color: isCorrect ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: BodyMediumText(
                    userAnswerText,
                    color: isCorrect ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.help_outline,
                  color: Colors.orange,
                  size: 20,
                ),
                const SizedBox(width: 8),
                BodyMediumText(
                  'Question was not answered',
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Correct Answer
        LabelMediumText(
          'Correct Answer:',
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BodyMediumText(
                  correctAnswer,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(bool isAnswered, bool isCorrect) {
    if (!isAnswered) return 'Unanswered';
    return isCorrect ? 'Correct' : 'Incorrect';
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.emoji_events;
    if (score >= 60) return Icons.trending_up;
    return Icons.trending_down;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today at ${_formatTime(date)}';
    } else if (difference == 1) {
      return 'Yesterday at ${_formatTime(date)}';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _shareQuizResults(BuildContext context) {
    final score = quiz.lastScore ?? 0.0;
    final summary = quiz.getPerformanceSummary();
    
    final shareText = '''
Quiz Results: ${quiz.title}
Score: ${score.toStringAsFixed(1)}%

✅ Correct: ${summary['correct']}
❌ Incorrect: ${summary['incorrect']}
⚪ Unanswered: ${summary['unanswered']}

Total Questions: ${quiz.questions.length}
''';

    // In a real app, you would use share_plus package
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BodyMediumText('Share functionality would open here\n\n$shareText'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}