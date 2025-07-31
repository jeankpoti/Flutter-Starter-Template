import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../common_widgets/text_widgets.dart';
import '../../domain/models/study_material.dart' as study;
import '../../domain/models/study_plan.dart';
import '../../domain/models/quiz.dart';

class MaterialsTab extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final List<study.StudyMaterial> studyMaterials;
  final bool isQuickQuizLoading;
  final bool isPracticeTestLoading;
  final bool isChallengeLoading;
  final bool isAllMaterialsQuizLoading;
  final String? processingPlanId;
  final Future<void> Function() onRefresh;
  final void Function(String) onDeletePlan;
  final void Function(StudyPlan) onShowStudyPlanTopics;
  final void Function(StudyPlan) onStartQuizFromPlan;
  final void Function({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  })
  onGenerateQuiz;
  final VoidCallback onGenerateAllMaterialsQuiz;
  final VoidCallback onShowHistory;

  const MaterialsTab({
    super.key,
    required this.studyPlans,
    required this.studyMaterials,
    required this.isQuickQuizLoading,
    required this.isPracticeTestLoading,
    required this.isChallengeLoading,
    required this.isAllMaterialsQuizLoading,
    this.processingPlanId,
    required this.onRefresh,
    required this.onDeletePlan,
    required this.onShowStudyPlanTopics,
    required this.onStartQuizFromPlan,
    required this.onGenerateQuiz,
    required this.onGenerateAllMaterialsQuiz,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (studyPlans.isNotEmpty) ...[
              _StudyPlansSection(
                studyPlans: studyPlans,
                onDeletePlan: onDeletePlan,
                onShowStudyPlanTopics: onShowStudyPlanTopics,
                onStartQuizFromPlan: onStartQuizFromPlan,
                processingPlanId: processingPlanId,
              ),
              const SizedBox(height: 32.0),
            ],
            if (studyMaterials.isNotEmpty) ...[
              _QuizSection(
                studyPlans: studyPlans,
                studyMaterials: studyMaterials,
                isQuickQuizLoading: isQuickQuizLoading,
                isPracticeTestLoading: isPracticeTestLoading,
                isChallengeLoading: isChallengeLoading,
                isAllMaterialsQuizLoading: isAllMaterialsQuizLoading,
                onGenerateQuiz: onGenerateQuiz,
                onGenerateAllMaterialsQuiz: onGenerateAllMaterialsQuiz,
                onShowHistory: onShowHistory,
              ),
              const SizedBox(height: 32.0),
            ],
            _MaterialsList(studyMaterials: studyMaterials),
          ],
        ),
      ),
    );
  }
}

class _StudyPlansSection extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final void Function(String) onDeletePlan;
  final void Function(StudyPlan) onShowStudyPlanTopics;
  final void Function(StudyPlan) onStartQuizFromPlan;
  final String? processingPlanId;

  const _StudyPlansSection({
    required this.studyPlans,
    required this.onDeletePlan,
    required this.onShowStudyPlanTopics,
    required this.onStartQuizFromPlan,
    this.processingPlanId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadlineSmallText(
          AppLocalizations.of(context)!.myStudyPlans,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: studyPlans.length,
            itemBuilder: (context, index) {
              return _StudyPlanCard(
                plan: studyPlans[index],
                onDelete: () => onDeletePlan(studyPlans[index].id),
                onShowTopics: () => onShowStudyPlanTopics(studyPlans[index]),
                onStartQuiz: () => onStartQuizFromPlan(studyPlans[index]),
                isProcessing: processingPlanId == studyPlans[index].id,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StudyPlanCard extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onDelete;
  final VoidCallback onShowTopics;
  final VoidCallback onStartQuiz;
  final bool isProcessing;

  const _StudyPlanCard({
    required this.plan,
    required this.onDelete,
    required this.onShowTopics,
    required this.onStartQuiz,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 2,
        child: InkWell(
          onTap: onShowTopics,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
                  Theme.of(
                    context,
                  ).colorScheme.tertiaryContainer.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StudyPlanCardHeader(plan: plan, onDelete: onDelete),
                const SizedBox(height: 6),
                _StudyPlanCardDetails(plan: plan, onShowTopics: onShowTopics),
                const Spacer(),
                _StudyPlanCardActions(
                  onShowTopics: onShowTopics,
                  onStartQuiz: onStartQuiz,
                  isProcessing: isProcessing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StudyPlanCardHeader extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onDelete;

  const _StudyPlanCardHeader({required this.plan, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.auto_awesome,
          color: Theme.of(context).colorScheme.secondary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TitleMediumText(
            plan.title,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            size: 20,
          ),
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: LabelLargeText(
                    AppLocalizations.of(context)!.deletePlan,
                  ),
                ),
              ],
        ),
      ],
    );
  }
}

class _StudyPlanCardDetails extends StatelessWidget {
  final StudyPlan plan;
  final VoidCallback onShowTopics;

  const _StudyPlanCardDetails({required this.plan, required this.onShowTopics});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodySmallText(
          plan.description,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: onShowTopics,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: plan.calculateProgress() / 100,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                LabelSmallText(
                  '${plan.calculateProgress().toStringAsFixed(0)}%',
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Flexible(
              child: _StatChip(
                icon: Icons.list_alt,
                label:
                    '${plan.topics.length} ${AppLocalizations.of(context)!.topics}',
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: _StatChip(
                icon: Icons.schedule,
                label: '${plan.totalEstimatedHours}h',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StudyPlanCardActions extends StatelessWidget {
  final VoidCallback onShowTopics;
  final VoidCallback onStartQuiz;
  final bool isProcessing;

  const _StudyPlanCardActions({
    required this.onShowTopics,
    required this.onStartQuiz,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextButton.icon(
            onPressed: onShowTopics,
            icon: const Icon(Icons.list, size: 16),
            label: LabelMediumText(
              AppLocalizations.of(context)!.viewTopics,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.secondary,
              padding: const EdgeInsets.symmetric(vertical: 6),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: ElevatedButton(
            onPressed: isProcessing ? null : onStartQuiz,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isProcessing
                      ? Theme.of(context).colorScheme.secondary.withOpacity(0.6)
                      : Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
              padding: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child:
                isProcessing
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        LabelSmallText(AppLocalizations.of(context)!.loading),
                      ],
                    )
                    : LabelMediumText(AppLocalizations.of(context)!.takeQuiz),
          ),
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
          const SizedBox(width: 6),
          LabelSmallText(
            label,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ],
      ),
    );
  }
}

class _QuizSection extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final List<study.StudyMaterial> studyMaterials;
  final bool isQuickQuizLoading;
  final bool isPracticeTestLoading;
  final bool isChallengeLoading;
  final bool isAllMaterialsQuizLoading;
  final void Function({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  })
  onGenerateQuiz;
  final VoidCallback onGenerateAllMaterialsQuiz;
  final VoidCallback onShowHistory;

  const _QuizSection({
    required this.studyPlans,
    required this.studyMaterials,
    required this.isQuickQuizLoading,
    required this.isPracticeTestLoading,
    required this.isChallengeLoading,
    required this.isAllMaterialsQuizLoading,
    required this.onGenerateQuiz,
    required this.onGenerateAllMaterialsQuiz,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: HeadlineSmallText(
                AppLocalizations.of(context)!.practiceQuizzes,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: onShowHistory,
              icon: const Icon(Icons.history),
              label: LabelLargeText(AppLocalizations.of(context)!.history),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                Theme.of(
                  context,
                ).colorScheme.secondaryContainer.withOpacity(0.2),
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
                    Icons.quiz,
                    color: Theme.of(context).colorScheme.secondary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TitleLargeText(
                      AppLocalizations.of(context)!.testYourKnowledge,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              BodyMediumText(
                AppLocalizations.of(context)!.testKnowledgeDescription,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _QuizOptionButton(
                      icon: Icons.flash_on,
                      title: AppLocalizations.of(context)!.quickQuiz,
                      subtitle: AppLocalizations.of(context)!.quickQuizSubtitle,
                      onTap:
                          () => onGenerateQuiz(
                            difficulty: QuizDifficulty.easy,
                            questionCount: 5,
                            timeLimit: 10,
                          ),
                      isLoading: isQuickQuizLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuizOptionButton(
                      icon: Icons.school,
                      title: AppLocalizations.of(context)!.practiceTest,
                      subtitle:
                          AppLocalizations.of(context)!.practiceTestSubtitle,
                      onTap:
                          () => onGenerateQuiz(
                            difficulty: QuizDifficulty.medium,
                            questionCount: 10,
                            timeLimit: 20,
                          ),
                      isLoading: isPracticeTestLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (studyPlans.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: _QuizOptionButton(
                    icon: Icons.emoji_events,
                    title: AppLocalizations.of(context)!.challengeMode,
                    subtitle:
                        AppLocalizations.of(context)!.challengeModeSubtitle,
                    onTap:
                        () => onGenerateQuiz(
                          difficulty: QuizDifficulty.hard,
                          questionCount: 15,
                          timeLimit: 30,
                        ),
                    isFullWidth: true,
                    isLoading: isChallengeLoading,
                  ),
                ),
              const SizedBox(height: 12),
              if (studyMaterials.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: _AllMaterialsQuizButton(
                    onTap: onGenerateAllMaterialsQuiz,
                    isLoading: isAllMaterialsQuizLoading,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuizOptionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isFullWidth;
  final bool isLoading;

  const _QuizOptionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isFullWidth = false,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              isFullWidth
                  ? Row(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          icon,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 24,
                        ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TitleMediumText(
                              title,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            BodySmallText(
                              subtitle,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                        size: 16,
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      if (isLoading)
                        const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        Icon(
                          icon,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 32,
                        ),
                      const SizedBox(height: 8),
                      TitleSmallText(
                        title,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      LabelSmallText(
                        subtitle,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}

class _AllMaterialsQuizButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLoading;

  const _AllMaterialsQuizButton({required this.onTap, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.quiz_outlined,
                  color: Theme.of(context).colorScheme.secondary,
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
                      )!.generateQuizWithAllMaterials,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodySmallText(
                      AppLocalizations.of(context)!.allMaterialsQuizDescription,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MaterialsList extends StatelessWidget {
  final List<study.StudyMaterial> studyMaterials;

  const _MaterialsList({required this.studyMaterials});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeadlineSmallText(
          AppLocalizations.of(context)!.myStudyMaterials,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(height: 16),
        if (studyMaterials.isEmpty)
          const _EmptyMaterials()
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: studyMaterials.length,
            itemBuilder: (context, index) {
              final material = studyMaterials[index];
              return _MaterialCard(material: material);
            },
          ),
      ],
    );
  }
}

class _EmptyMaterials extends StatelessWidget {
  const _EmptyMaterials();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.library_books,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          const SizedBox(height: 16),
          TitleMediumText(
            AppLocalizations.of(context)!.noStudyMaterials,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 8),
          BodyMediumText(
            AppLocalizations.of(context)!.noStudyMaterialsDescription,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MaterialCard extends StatelessWidget {
  final study.StudyMaterial material;

  const _MaterialCard({required this.material});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  material.type == study.MaterialType.image
                      ? Icons.image
                      : Icons.text_snippet,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TitleMediumText(
                      material.title,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    BodySmallText(
                      material.difficultyLevel,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:
                      material.status == study.MaterialStatus.completed
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  material.status == study.MaterialStatus.completed
                      ? Icons.check
                      : Icons.access_time,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StudyPlanSelectionDialog extends StatelessWidget {
  final List<StudyPlan> studyPlans;

  const StudyPlanSelectionDialog({super.key, required this.studyPlans});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: TitleLargeText(
        AppLocalizations.of(context)!.selectStudyPlan,
        fontWeight: FontWeight.bold,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BodyMediumText(
              AppLocalizations.of(context)!.chooseStudyPlanForQuiz,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: studyPlans.length,
                itemBuilder: (context, index) {
                  final plan = studyPlans[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      onTap: () => Navigator.of(context).pop(plan),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.school,
                          color: Theme.of(context).colorScheme.secondary,
                          size: 20,
                        ),
                      ),
                      title: TitleMediumText(
                        plan.title,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BodySmallText(
                            '${plan.topics.length} ${AppLocalizations.of(context)!.topics} • ${plan.calculateProgress().toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: plan.calculateProgress() / 100,
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(
            AppLocalizations.of(context)!.cancel,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}

class StudyPlanTopicsSheet extends StatefulWidget {
  final StudyPlan plan;
  final List<StudyPlan> studyPlans;
  final Future<void> Function(String, String, double) onUpdateTopicProgress;
  final Future<void> Function(String, String) onMarkTopicComplete;
  final Future<void> Function(String, String) onStartTopic;

  const StudyPlanTopicsSheet({
    super.key,
    required this.plan,
    required this.studyPlans,
    required this.onUpdateTopicProgress,
    required this.onMarkTopicComplete,
    required this.onStartTopic,
  });

  @override
  State<StudyPlanTopicsSheet> createState() => _StudyPlanTopicsSheetState();
}

class _StudyPlanTopicsSheetState extends State<StudyPlanTopicsSheet> {
  late StudyPlan _currentPlan;

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.studyPlans.firstWhere(
      (p) => p.id == widget.plan.id,
      orElse: () => widget.plan,
    );
  }

  void _showTopicDetailsDialog(StudyTopic topic) {
    showDialog(
      context: context,
      builder:
          (context) => TopicDetailsDialog(
            plan: _currentPlan,
            topic: topic,
            onUpdate: () {
              setState(() {
                _currentPlan = widget.studyPlans.firstWhere(
                  (p) => p.id == widget.plan.id,
                  orElse: () => widget.plan,
                );
              });
            },
            onUpdateTopicProgress: widget.onUpdateTopicProgress,
            onMarkTopicComplete: widget.onMarkTopicComplete,
            onStartTopic: widget.onStartTopic,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeadlineSmallText(
                    _currentPlan.title,
                    fontWeight: FontWeight.bold,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _currentPlan.calculateProgress() / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      LabelMediumText(
                        '${_currentPlan.calculateProgress().toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _TopicStat(
                        label: AppLocalizations.of(context)!.totalTopics,
                        value: _currentPlan.topics.length.toString(),
                        icon: Icons.list_alt,
                      ),
                      const SizedBox(width: 16),
                      _TopicStat(
                        label: AppLocalizations.of(context)!.completedStatus,
                        value:
                            _currentPlan
                                .getCompletionStats()['completed']
                                .toString(),
                        icon: Icons.check_circle,
                      ),
                      const SizedBox(width: 16),
                      _TopicStat(
                        label: AppLocalizations.of(context)!.inProgress,
                        value:
                            _currentPlan
                                .getCompletionStats()['inProgress']
                                .toString(),
                        icon: Icons.play_circle,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _currentPlan.topics.length,
                itemBuilder: (context, index) {
                  final topic = _currentPlan.topics[index];
                  return _TopicListItem(
                    plan: _currentPlan,
                    topic: topic,
                    onTap: () => _showTopicDetailsDialog(topic),
                    onUpdate: () {
                      setState(() {
                        _currentPlan = widget.studyPlans.firstWhere(
                          (p) => p.id == widget.plan.id,
                          orElse: () => widget.plan,
                        );
                      });
                    },
                    onMarkTopicComplete: widget.onMarkTopicComplete,
                    onStartTopic: widget.onStartTopic,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopicStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TopicStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 4),
        LabelMediumText(
          value,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 2),
        LabelSmallText(
          label,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
      ],
    );
  }
}

class _TopicListItem extends StatelessWidget {
  final StudyPlan plan;
  final StudyTopic topic;
  final VoidCallback onTap;
  final VoidCallback onUpdate;
  final Future<void> Function(String, String) onMarkTopicComplete;
  final Future<void> Function(String, String) onStartTopic;

  const _TopicListItem({
    required this.plan,
    required this.topic,
    required this.onTap,
    required this.onUpdate,
    required this.onMarkTopicComplete,
    required this.onStartTopic,
  });

  Color _getTopicStatusColor(BuildContext context, StudyTopicStatus status) {
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
        return Icons.radio_button_unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getTopicStatusColor(context, topic.status);
    final statusIcon = _getTopicStatusIcon(topic.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(statusIcon, size: 16, color: statusColor),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TitleMediumText(
                      topic.title,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  LabelMediumText(
                    '${topic.progressPercentage.toStringAsFixed(0)}%',
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.4),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: topic.progressPercentage / 100,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.outline.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
              const SizedBox(height: 8),
              BodySmallText(
                topic.description,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  LabelSmallText(
                    '${topic.estimatedMinutes} ${AppLocalizations.of(context)!.minutes}',
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.lightbulb_outline,
                    size: 14,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  LabelSmallText(
                    '${topic.keyConceptsList.length} ${AppLocalizations.of(context)!.concepts}',
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const Spacer(),
                  if (topic.status != StudyTopicStatus.completed) ...[
                    if (topic.status == StudyTopicStatus.notStarted)
                      InkWell(
                        onTap: () async {
                          await onStartTopic(plan.id, topic.id);
                          onUpdate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: LabelSmallText(
                            AppLocalizations.of(context)!.start,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        await onMarkTopicComplete(plan.id, topic.id);
                        onUpdate();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: LabelSmallText(
                          AppLocalizations.of(context)!.complete,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ] else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check,
                            size: 12,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 4),
                          LabelSmallText(
                            AppLocalizations.of(context)!.done,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicDetailsDialog extends StatefulWidget {
  final StudyPlan plan;
  final StudyTopic topic;
  final VoidCallback onUpdate;
  final Future<void> Function(String, String, double) onUpdateTopicProgress;
  final Future<void> Function(String, String) onMarkTopicComplete;
  final Future<void> Function(String, String) onStartTopic;

  const TopicDetailsDialog({
    super.key,
    required this.plan,
    required this.topic,
    required this.onUpdate,
    required this.onUpdateTopicProgress,
    required this.onMarkTopicComplete,
    required this.onStartTopic,
  });

  @override
  State<TopicDetailsDialog> createState() => _TopicDetailsDialogState();
}

class _TopicDetailsDialogState extends State<TopicDetailsDialog> {
  late StudyTopic _currentTopic;

  @override
  void initState() {
    super.initState();
    _currentTopic = widget.topic;
  }

  Color _getTopicStatusColor(BuildContext context, StudyTopicStatus status) {
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
        return Icons.radio_button_unchecked;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getTopicStatusColor(context, _currentTopic.status);
    final statusIcon = _getTopicStatusIcon(_currentTopic.status);

    return Dialog(
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    statusColor.withOpacity(0.1),
                    statusColor.withOpacity(0.05),
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
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: HeadlineSmallText(
                          _currentTopic.title,
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
                          ).colorScheme.surface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: _currentTopic.progressPercentage / 100,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            statusColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      LabelLargeText(
                        '${_currentTopic.progressPercentage.toStringAsFixed(0)}% ${AppLocalizations.of(context)!.complete}',
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _TopicMetadata(
                        icon: Icons.schedule,
                        text:
                            '${_currentTopic.estimatedMinutes} ${AppLocalizations.of(context)!.minutes}',
                      ),
                      const SizedBox(width: 24),
                      _TopicMetadata(
                        icon: Icons.lightbulb_outline,
                        text:
                            '${_currentTopic.keyConceptsList.length} ${AppLocalizations.of(context)!.concepts}',
                      ),
                      if (_currentTopic.practiceProblems.isNotEmpty) ...[
                        const SizedBox(width: 24),
                        _TopicMetadata(
                          icon: Icons.quiz,
                          text:
                              '${_currentTopic.practiceProblems.length} ${AppLocalizations.of(context)!.problems}',
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TopicSection(
                      title: AppLocalizations.of(context)!.description,
                      icon: Icons.description,
                      child: BodyLargeText(
                        _currentTopic.description,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    if (_currentTopic.keyConceptsList.isNotEmpty) ...[
                      _TopicSection(
                        title: AppLocalizations.of(context)!.keyConcepts,
                        icon: Icons.lightbulb_outline,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _currentTopic.keyConceptsList
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
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary
                                              .withOpacity(0.2),
                                        ),
                                      ),
                                      child: BodyMediumText(
                                        concept,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                    if (_currentTopic.practiceProblems.isNotEmpty) ...[
                      _TopicSection(
                        title: AppLocalizations.of(context)!.practiceProblems,
                        icon: Icons.quiz,
                        child: Column(
                          children:
                              _currentTopic.practiceProblems
                                  .asMap()
                                  .entries
                                  .map((entry) {
                                    final index = entry.key;
                                    final problem = entry.value;
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline
                                              .withOpacity(0.2),
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
                      const SizedBox(height: 24.0),
                    ],
                    if (_currentTopic.completedAt != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.2),
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
                                    '${AppLocalizations.of(context)!.completedOn} ${_formatDate(context, _currentTopic.completedAt!)}',
                                    color: Colors.green.withOpacity(0.8),
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
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  if (_currentTopic.status != StudyTopicStatus.completed) ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await widget.onStartTopic(
                            widget.plan.id,
                            _currentTopic.id,
                          );
                          setState(() {
                            _currentTopic = widget.plan.topics.firstWhere(
                              (t) => t.id == _currentTopic.id,
                            );
                          });
                          widget.onUpdate();
                        },
                        icon: Icon(
                          _currentTopic.status == StudyTopicStatus.notStarted
                              ? Icons.play_arrow
                              : Icons.play_circle,
                        ),
                        label: LabelLargeText(
                          _currentTopic.status == StudyTopicStatus.notStarted
                              ? AppLocalizations.of(context)!.startTopic
                              : AppLocalizations.of(context)!.continueAction,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await widget.onMarkTopicComplete(
                            widget.plan.id,
                            _currentTopic.id,
                          );
                          setState(() {
                            _currentTopic = widget.plan.topics.firstWhere(
                              (t) => t.id == _currentTopic.id,
                            );
                          });
                          widget.onUpdate();
                        },
                        icon: const Icon(Icons.check_circle),
                        label: LabelLargeText(
                          AppLocalizations.of(context)!.markComplete,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await widget.onUpdateTopicProgress(
                            widget.plan.id,
                            _currentTopic.id,
                            0.0,
                          );
                          setState(() {
                            _currentTopic = widget.plan.topics.firstWhere(
                              (t) => t.id == _currentTopic.id,
                            );
                          });
                          widget.onUpdate();
                        },
                        icon: const Icon(Icons.refresh),
                        label: LabelLargeText(
                          AppLocalizations.of(context)!.markIncomplete,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                          foregroundColor:
                              Theme.of(context).colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicMetadata extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TopicMetadata({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 4),
        BodySmallText(
          text,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

class _TopicSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _TopicSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 8),
            TitleMediumText(
              title,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
