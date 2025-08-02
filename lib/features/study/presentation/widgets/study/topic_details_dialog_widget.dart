import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../common_widgets/text_widgets.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../domain/models/study_plan.dart';
import '../../study_cubit.dart';
import '../../study_state.dart';

class TopicDetailsDialogWidget extends StatefulWidget {
  final StudyPlan plan;
  final StudyTopic topic;

  const TopicDetailsDialogWidget({
    super.key,
    required this.plan,
    required this.topic,
  });

  @override
  State<TopicDetailsDialogWidget> createState() =>
      _TopicDetailsDialogWidgetState();
}

class _TopicDetailsDialogWidgetState extends State<TopicDetailsDialogWidget> {
  Color _getTopicStatusColor(StudyTopicStatus status) {
    switch (status) {
      case StudyTopicStatus.completed:
        return Colors.green;
      case StudyTopicStatus.inProgress:
        return Theme.of(context).colorScheme.secondary;
      case StudyTopicStatus.needsReview:
        return Colors.orange;
      case StudyTopicStatus.notStarted:
        return Theme.of(context).colorScheme.outline;
    }
  }

  IconData _getTopicStatusIcon(StudyTopicStatus status) {
    switch (status) {
      case StudyTopicStatus.completed:
        return Icons.check_circle;
      case StudyTopicStatus.inProgress:
        return Icons.play_circle;
      case StudyTopicStatus.needsReview:
        return Icons.refresh;
      case StudyTopicStatus.notStarted:
        return Icons.circle_outlined;
    }
  }

  Widget _buildTopicSection(
    String title,
    IconData icon, {
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 12),
            TitleMediumText(title, fontWeight: FontWeight.w600),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudyCubit, StudyState>(
      builder: (context, state) {
        // Get the current topic state from the plan
        final studyCubit = context.read<StudyCubit>();
        final currentPlan = state.studyPlans.firstWhere(
          (p) => p.id == widget.plan.id,
          orElse: () => widget.plan,
        );
        final currentTopic = currentPlan.topics.firstWhere(
          (t) => t.id == widget.topic.id,
          orElse: () => widget.topic,
        );

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getTopicStatusColor(
                        currentTopic.status,
                      ).withValues(alpha: 0.1),
                      _getTopicStatusColor(
                        currentTopic.status,
                      ).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _getTopicStatusColor(
                              currentTopic.status,
                            ).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _getTopicStatusIcon(currentTopic.status),
                            color: _getTopicStatusColor(currentTopic.status),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: HeadlineLargeText(
                            currentTopic.title,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.surface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress indicator
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: currentTopic.progressPercentage / 100,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.outline.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getTopicStatusColor(currentTopic.status),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        LabelLargeText(
                          '${currentTopic.progressPercentage.toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
                          color: _getTopicStatusColor(currentTopic.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    BodySmallText(
                      AppLocalizations.of(
                        context,
                      )!.estimatedTime(currentTopic.estimatedMinutes),
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Description
                      if (currentTopic.description.isNotEmpty) ...[
                        _buildTopicSection(
                          AppLocalizations.of(context)!.topicDescription,
                          Icons.description,
                          child: BodyMediumText(currentTopic.description),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Key Concepts
                      if (currentTopic.keyConceptsList.isNotEmpty) ...[
                        _buildTopicSection(
                          AppLocalizations.of(context)!.keyConceptsTitle,
                          Icons.lightbulb_outline,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                currentTopic.keyConceptsList
                                    .map(
                                      (concept) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondaryContainer
                                              .withValues(alpha: 0.3),
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: BodyMediumText(
                                          concept,
                                          color:
                                              Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Practice Problems
                      if (currentTopic.practiceProblems.isNotEmpty) ...[
                        _buildTopicSection(
                          AppLocalizations.of(context)!.practiceProblemsTitle,
                          Icons.quiz,
                          child: Column(
                            children:
                                currentTopic.practiceProblems
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                      final index = entry.key;
                                      final problem = entry.value;
                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .outline
                                                .withValues(alpha: 0.2),
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.secondary,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Center(
                                                child: LabelSmallText(
                                                  '${index + 1}',
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.onSecondary,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: BodyMediumText(problem),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                    .toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Completion info
                      if (currentTopic.completedAt != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.green.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.celebration,
                                color: Colors.green,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TitleMediumText(
                                      AppLocalizations.of(
                                        context,
                                      )!.topicCompleted,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                    BodySmallText(
                                      '${AppLocalizations.of(context)!.completedOn} ${_formatDate(currentTopic.completedAt!)}',
                                      color: Colors.green.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child:
                      currentTopic.status != StudyTopicStatus.completed
                          ? ElevatedButton.icon(
                            onPressed: () async {
                              await studyCubit.markTopicComplete(
                                widget.plan.id,
                                currentTopic.id,
                              );
                            },
                            icon: const Icon(Icons.check_circle),
                            label: LabelLargeText(
                              AppLocalizations.of(context)!.markComplete,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          )
                          : ElevatedButton.icon(
                            onPressed: () async {
                              await studyCubit.markTopicIncomplete(
                                widget.plan.id,
                                currentTopic.id,
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: LabelLargeText(
                              AppLocalizations.of(context)!.markIncomplete,
                              color: Theme.of(context).colorScheme.onSecondary,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSecondary,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
