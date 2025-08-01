import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../data/repository/study_material_repository.dart';
import '../data/repository/study_plan_repository.dart';
import '../domain/models/study_plan.dart';
import '../domain/models/quiz.dart';
import 'study_cubit.dart';
import 'study_state.dart';
import 'quiz_page.dart';
import 'quiz_history_page.dart';
import 'widgets/material_tab.dart';
import 'widgets/modern_tab_bar.dart';
import 'widgets/upload_tab.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => StudyCubit(
            materialRepository: StudyMaterialRepository(),
            planRepository: StudyPlanRepository(),
            studyPlanService: StudyPlanService(),
            quizService: QuizService(),
            picker: ImagePicker(),
          )..initializeServices(),
      child: const _StudyPageView(),
    );
  }
}

class _StudyPageView extends StatefulWidget {
  const _StudyPageView();

  @override
  State<_StudyPageView> createState() => _StudyPageViewState();
}

class _StudyPageViewState extends State<_StudyPageView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const double _spacing4 = 16.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<StudyCubit, StudyState>(
      listenWhen:
          (previous, current) =>
              previous.studyPlans.length < current.studyPlans.length,
      listener: (context, state) {
        AppSnackBar.showSuccess(
          context,
          AppLocalizations.of(context)!.studyPlanGeneratedSuccessfully,
        );
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: HeadlineSmallText(
            AppLocalizations.of(context)!.studyMaterialsTitle,
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(
                Icons.refresh_rounded,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              onPressed: () => context.read<StudyCubit>().refreshData(),
              tooltip: AppLocalizations.of(context)!.refreshData,
            ),
          ],
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: _spacing4),
                  child: ModernTabBar(tabController: _tabController),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Padding(
                    padding: const EdgeInsets.all(_spacing4),
                    child: BlocBuilder<StudyCubit, StudyState>(
                      builder: (context, state) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            UploadTab(
                              isProcessing:
                                  state.isProcessing ||
                                  state.isUploadingPhoto ||
                                  state.isUploadingText,
                              studyMaterials: state.studyMaterials,
                              onPhotoUpload:
                                  () =>
                                      context
                                          .read<StudyCubit>()
                                          .handlePhotoUpload(),
                              onGalleryUpload:
                                  () =>
                                      context
                                          .read<StudyCubit>()
                                          .handleGalleryUpload(),
                              onTextInput: _handleTextInput,
                            ),
                            MaterialsTab(
                              studyPlans: state.studyPlans,
                              studyMaterials: state.studyMaterials,
                              isQuickQuizLoading: state.isQuickQuizLoading,
                              isPracticeTestLoading:
                                  state.isPracticeTestLoading,
                              isChallengeLoading: state.isChallengeLoading,
                              isAllMaterialsQuizLoading:
                                  state.isAllMaterialsQuizLoading,
                              processingPlanId: state.processingPlanId,
                              onRefresh:
                                  () =>
                                      context.read<StudyCubit>().refreshData(),
                              onDeletePlan:
                                  (planId) => context
                                      .read<StudyCubit>()
                                      .deletePlan(planId),
                              onShowStudyPlanTopics: _showStudyPlanTopics,
                              onStartQuizFromPlan: _startQuizFromPlan,
                              onGenerateQuiz: _generateAndStartQuiz,
                              onGenerateAllMaterialsQuiz:
                                  _generateQuizFromAllMaterials,
                              onShowHistory: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder:
                                        (context) => const QuizHistoryPage(),
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTextInput() {
    showDialog(context: context, builder: (context) => const TextInputDialog());
  }

  Future<void> _generateAndStartQuiz({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) async {
    try {
      final studyCubit = context.read<StudyCubit>();

      StudyPlan? selectedPlan;

      // Check if we need to show plan selection dialog
      if (studyCubit.shouldShowPlanSelectionDialog()) {
        final dialogResult = await _showStudyPlanSelectionDialog();
        // dialogResult will be:
        // - null if user cancelled (pressed back, outside, or cancel button)
        // - StudyPlan if user selected a specific plan
        // - 'ALL_MATERIALS' if user selected "All Study Materials"
        if (dialogResult == null) {
          // User cancelled selection
          return;
        } else if (dialogResult == 'ALL_MATERIALS') {
          // User selected "All Study Materials", keep selectedPlan as null
          selectedPlan = null;
        } else if (dialogResult is StudyPlan) {
          selectedPlan = dialogResult;
        }
      }

      final quiz = await studyCubit.generateQuiz(
        difficulty: difficulty,
        questionCount: questionCount,
        timeLimit: timeLimit,
        selectedPlan: selectedPlan,
      );

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
      }
    } catch (e) {
      // Error is handled by BlocListener
    }
  }

  Future<dynamic> _showStudyPlanSelectionDialog() async {
    final studyCubit = context.read<StudyCubit>();
    return showDialog<dynamic>(
      context: context,
      builder:
          (context) => StudyPlanSelectionDialog(
            studyPlans: studyCubit.state.studyPlans,
            hasStudyMaterials: studyCubit.state.studyMaterials.isNotEmpty,
          ),
    );
  }

  Future<void> _generateQuizFromAllMaterials() async {
    try {
      final quiz = await context.read<StudyCubit>().generateAllMaterialsQuiz();

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
      }
    } catch (e) {
      // Error is handled by BlocListener
    }
  }

  Future<void> _startQuizFromPlan(StudyPlan plan) async {
    try {
      final quiz = await context.read<StudyCubit>().generateQuizFromPlan(
        plan,
        difficulty: QuizDifficulty.medium,
        questionCount: 10,
        timeLimit: 15,
      );

      if (mounted) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => QuizPage(quiz: quiz)));
      }
    } catch (e) {
      // Error is handled by BlocListener
    }
  }

  void _showStudyPlanTopics(StudyPlan plan) {
    final studyCubit = context.read<StudyCubit>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => BlocProvider.value(
            value: studyCubit,
            child: StudyPlanTopicsSheet(
              plan: plan,
              studyPlans: studyCubit.state.studyPlans,
              onUpdateTopicProgress:
                  (planId, topicId, progress) =>
                      studyCubit.updateTopicProgress(planId, topicId, progress),
              onMarkTopicComplete:
                  (planId, topicId) =>
                      studyCubit.markTopicComplete(planId, topicId),
              onStartTopic:
                  (planId, topicId) => studyCubit.startTopic(planId, topicId),
            ),
          ),
    );
  }
}

class TextInputDialog extends StatefulWidget {
  const TextInputDialog({super.key});

  @override
  State<TextInputDialog> createState() => _TextInputDialogState();
}

class _TextInputDialogState extends State<TextInputDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: HeadlineSmallText(AppLocalizations.of(context)!.typeText),
      content: SizedBox(
        width: double.maxFinite,
        child: TextField(
          controller: _textController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.typeTextSubtitle,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final text = _textController.text.trim();
            if (text.isNotEmpty) {
              context.read<StudyCubit>().processTextMaterial(text);
              Navigator.of(context).pop();
            }
          },
          child: LabelLargeText(AppLocalizations.of(context)!.process),
        ),
      ],
    );
  }
}

class StudyPlanSelectionDialog extends StatelessWidget {
  final List<StudyPlan> studyPlans;
  final bool hasStudyMaterials;

  const StudyPlanSelectionDialog({
    super.key,
    required this.studyPlans,
    required this.hasStudyMaterials,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: HeadlineSmallText(AppLocalizations.of(context)!.selectStudyPlan),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12,
          children: [
            ...studyPlans.map(
              (plan) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  title: BodyLargeText(plan.title),
                  subtitle: BodyMediumText('${plan.topics.length} topics'),
                  onTap: () => Navigator.of(context).pop(plan),
                ),
              ),
            ),
            if (hasStudyMaterials) ...[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.library_books,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: BodyLargeText(
                    AppLocalizations.of(context)!.allStudyMaterials,
                  ),
                  subtitle: BodyMediumText(
                    AppLocalizations.of(context)!.generateFromAllMaterials,
                  ),
                  onTap:
                      () => Navigator.of(context).pop(
                        'ALL_MATERIALS',
                      ), // Return special string to indicate "all materials"
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: LabelLargeText(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }
}

class StudyPlanTopicsSheet extends StatelessWidget {
  final StudyPlan plan;
  final List<StudyPlan> studyPlans;
  final Function(String, String, double) onUpdateTopicProgress;
  final Function(String, String) onMarkTopicComplete;
  final Function(String, String) onStartTopic;

  const StudyPlanTopicsSheet({
    super.key,
    required this.plan,
    required this.studyPlans,
    required this.onUpdateTopicProgress,
    required this.onMarkTopicComplete,
    required this.onStartTopic,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HeadlineSmallText(plan.title),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: plan.topics.length,
              itemBuilder: (context, index) {
                final topic = plan.topics[index];
                return Card(
                  child: ListTile(
                    title: BodyLargeText(topic.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BodyMediumText(topic.description),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: topic.progressPercentage / 100,
                          backgroundColor:
                              Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        BodySmallText(
                          '${topic.progressPercentage.toInt()}% complete',
                        ),
                      ],
                    ),
                    trailing:
                        topic.status == StudyTopicStatus.completed
                            ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                            : ElevatedButton(
                              onPressed: () => onStartTopic(plan.id, topic.id),
                              child: LabelMediumText(
                                AppLocalizations.of(context)!.start,
                              ),
                            ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
