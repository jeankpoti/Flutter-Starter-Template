import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common_widgets/text_widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/study_plan.dart';
import '../study_cubit.dart';
import '../study_state.dart';

class StudyPlanTopicsSheetWidget extends StatelessWidget {
  final StudyPlan plan;
  final List<StudyPlan> studyPlans;
  final Function(String, String, double) onUpdateTopicProgress;
  final Function(String, String) onMarkTopicComplete;
  final Function(BuildContext, StudyPlan, StudyTopic) onTopicTap;

  const StudyPlanTopicsSheetWidget({
    super.key,
    required this.plan,
    required this.studyPlans,
    required this.onUpdateTopicProgress,
    required this.onMarkTopicComplete,
    required this.onTopicTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        // Get the current plan state
        final currentPlan = state.studyPlans.firstWhere(
          (p) => p.id == plan.id,
          orElse: () => plan,
        );
        
        final overallProgress = currentPlan.topics.isEmpty
            ? 0.0
            : currentPlan.topics.map((t) => t.progressPercentage).reduce((a, b) => a + b) / currentPlan.topics.length;
        final completedTopics = currentPlan.topics.where((t) => t.status == StudyTopicStatus.completed).length;

        return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header with drag handle
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeadlineMediumText(
                            currentPlan.title,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 4),
                          BodyMediumText(
                            '$completedTopics of ${currentPlan.topics.length} topics completed',
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Overall progress card
                _buildOverallProgressCard(context, overallProgress),
              ],
            ),
          ),

          // Topics list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              itemCount: currentPlan.topics.length,
              itemBuilder: (context, index) {
                final topic = currentPlan.topics[index];
                return _buildTopicCard(context, currentPlan, topic);
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildOverallProgressCard(BuildContext context, double overallProgress) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
            Theme.of(context).colorScheme.secondaryContainer.withValues(alpha: 0.2),
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
                Icons.trending_up,
                color: Theme.of(context).colorScheme.secondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              TitleMediumText(
                AppLocalizations.of(context)!.overallProgress,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const Spacer(),
              LabelLargeText(
                '${overallProgress.toStringAsFixed(1)}%',
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: overallProgress / 100,
              minHeight: 8,
              backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(BuildContext context, StudyPlan currentPlan, StudyTopic topic) {
    final isCompleted = topic.status == StudyTopicStatus.completed;
    final isInProgress = topic.status == StudyTopicStatus.inProgress;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isCompleted ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onTopicTap(context, currentPlan, topic),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status icon
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? Theme.of(context).colorScheme.secondary
                          : isInProgress
                              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2)
                              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isCompleted
                          ? Icons.check
                          : isInProgress
                              ? Icons.play_arrow
                              : Icons.circle_outlined,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.onSecondary
                          : Theme.of(context).colorScheme.secondary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Topic info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleMediumText(
                          topic.title,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        const SizedBox(height: 4),
                        BodySmallText(
                          topic.description,
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Action button
                  if (!isCompleted) ...[
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        // Open the dialog first
                        onTopicTap(context, currentPlan, topic);
                        
                        // Start the topic after a short delay if it hasn't been started yet
                        if (topic.status == StudyTopicStatus.notStarted) {
                          await Future.delayed(const Duration(milliseconds: 300));
                          if (context.mounted) {
                            await context.read<StudyCubit>().startTopic(currentPlan.id, topic.id);
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                        minimumSize: const Size(80, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: LabelMediumText(
                        isInProgress
                            ? AppLocalizations.of(context)!.continueText
                            : AppLocalizations.of(context)!.start,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              // Progress bar
              if (topic.progressPercentage > 0) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: topic.progressPercentage / 100,
                          minHeight: 6,
                          backgroundColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    LabelSmallText(
                      '${topic.progressPercentage.toInt()}%',
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}