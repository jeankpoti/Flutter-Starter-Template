import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../../l10n/app_localizations.dart';
import '../../../common_widgets/app_snackbar_widget.dart';
import '../../../common_widgets/text_widgets.dart';
import '../../../common_widgets/permission_denied_dialog_widget.dart';
import '../../common/presentation/permission_cubit.dart';
import '../../common/presentation/mixins/permission_lifecycle_mixin.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import '../../subscription/presentation/subscription_state.dart';
import '../../../core/services/ad_service.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../data/repository/study_material_repository.dart';
import '../data/repository/study_plan_repository.dart';
import '../domain/models/study_plan.dart';
import '../domain/models/study_material.dart';
import '../domain/models/quiz.dart';
import 'study_cubit.dart';
import 'study_state.dart';
import 'quiz_page.dart';
import 'quiz_history_page.dart';
import 'widgets/study/material_tab.dart';
import 'widgets/study/modern_tab_bar.dart';
import 'widgets/study/upload_tab.dart';
import 'widgets/study/flashcards_tab.dart';
import 'cubit/flashcard_cubit.dart';
import 'widgets/study/topic_details_dialog_widget.dart';
import 'widgets/study/study_plan_topics_sheet_widget.dart';
import 'widgets/study/study_plan_selection_dialog_widget.dart';

class StudyPage extends StatelessWidget {
  const StudyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create:
              (context) => StudyCubit(
                materialRepository: StudyMaterialRepository(),
                planRepository: StudyPlanRepository(),
                studyPlanService: StudyPlanService(),
                quizService: QuizService(),
                picker: ImagePicker(),
                permissionCubit: context.read<PermissionCubit>(),
                subscriptionCubit: context.read<SubscriptionCubit>(),
                adService: AdService.instance,
              )..initializeServices(),
        ),
        BlocProvider(
          create: (context) => FlashcardCubit(
            subscriptionCubit: context.read<SubscriptionCubit>(),
            adService: AdService.instance,
          ),
        ),
      ],
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, PermissionLifecycleMixin {
  late TabController _tabController;

  static const double _spacing4 = 16.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize permissions
    context.read<PermissionCubit>().initializePermissions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  // Override from PermissionLifecycleMixin - handles showing messages
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // Additional handling for permission state messages
    if (state == AppLifecycleState.resumed) {
      final permissionState = context.read<PermissionCubit>().state;
      if (permissionState.message != null && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showSnackBarMessage(permissionState.message!);
          context.read<PermissionCubit>().clearMessage();
        });
      }
    }
  }
  
  void _showSnackBarMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: BodyMediumText(
          message,
          color:
              isError
                  ? Theme.of(context).colorScheme.onErrorContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        backgroundColor:
            isError
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.surfaceContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        margin: const EdgeInsets.all(_spacing4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<StudyCubit, StudyState>(
          listenWhen:
              (previous, current) =>
                  !previous.studyPlanGenerated && current.studyPlanGenerated,
          listener: (context, state) {
            AppSnackBar.showSuccess(
              context,
              AppLocalizations.of(context)!.studyPlanGeneratedSuccessfully,
            );
            // Clear the flag after showing the message
            context.read<StudyCubit>().clearStudyPlanGenerated();
          },
        ),
        BlocListener<StudyCubit, StudyState>(
          listenWhen:
              (previous, current) =>
                  previous.errorMsg != current.errorMsg && current.errorMsg != null,
          listener: (context, state) {
            if (state.errorMsg != null) {
              String errorMessage = state.errorMsg!;
              
              // Check if it's a non-math content error and localize it
              if (errorMessage == 'NON_MATH_CONTENT_ERROR') {
                errorMessage = AppLocalizations.of(context)!.nonMathContentError;
              } else if (errorMessage == 'NON_MATH_TEXT_ERROR') {
                errorMessage = AppLocalizations.of(context)!.nonMathTextError;
              } else if (errorMessage == 'NON_MATH_DOCUMENT_ERROR') {
                errorMessage = AppLocalizations.of(context)!.nonMathDocumentError;
              } else if (errorMessage == 'adFailedToLoad') {
                errorMessage = AppLocalizations.of(context)!.adFailedToLoad;
              } else if (errorMessage == 'watchAdFirst') {
                errorMessage = AppLocalizations.of(context)!.watchAdFirst;
              }
              
              AppSnackBar.showError(
                context,
                errorMessage,
              );
              // Clear the error message
              context.read<StudyCubit>().clearError();
            }
          },
        ),
        BlocListener<PermissionCubit, PermissionState>(
          listenWhen: (previous, current) => current.message != null,
          listener: (context, state) {
            if (state.message != null) {
              _showSnackBarMessage(state.message!);
              context.read<PermissionCubit>().clearMessage();
            }
          },
        ),
        BlocListener<FlashcardCubit, FlashcardState>(
          listenWhen: (previous, current) =>
              previous.errorMsg != current.errorMsg && current.errorMsg != null,
          listener: (context, state) {
            if (state.errorMsg != null) {
              String errorMessage = state.errorMsg!;
              
              // Localize ad error messages
              if (errorMessage == 'adFailedToLoad') {
                errorMessage = AppLocalizations.of(context)!.adFailedToLoad;
              } else if (errorMessage == 'watchAdFirst') {
                errorMessage = AppLocalizations.of(context)!.watchAdFirst;
              } else if (errorMessage == 'adServiceNotAvailable') {
                errorMessage = AppLocalizations.of(context)!.somethingWentWrong;
              }
              
              AppSnackBar.showError(context, errorMessage);
              context.read<FlashcardCubit>().clearMessages();
            }
          },
        ),
      ],
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
            // Show premium upgrade icon for free users
            BlocBuilder<SubscriptionCubit, SubscriptionState>(
              builder: (context, subscriptionState) {
                if (!subscriptionState.isSubscribed) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    child: IconButton(
                      onPressed: () async {
                        final message = AppLocalizations.of(context)!.premiumNoAds;
                        try {
                          await RevenueCatUI.presentPaywall();
                        } catch (e) {
                          // Fallback: show snackbar with upgrade message
                          if (mounted) {
                            _showSnackBarMessage(message);
                          }
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber,
                              Colors.orange,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amber.withValues(alpha: 0.3),
                              offset: const Offset(0, 2),
                              blurRadius: 4.0,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.block,
                              color: Colors.white,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                      tooltip: AppLocalizations.of(context)!.skipAdsWithPremium,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
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
                                  state.isUploadingText ||
                                  state.isShowingAd,
                              studyMaterials: state.studyMaterials,
                              onPhotoUpload: _handlePhotoUpload,
                              onGalleryUpload: _handleGalleryUpload,
                              onTextInput: _handleTextInput,
                              onDocumentUpload: _handleDocumentUpload,
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
                            FlashcardsTab(
                              studyMaterials: state.studyMaterials,
                              onGenerateFromMaterials: _generateFlashcardsFromMaterials,
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

  Future<void> _handlePhotoUpload() async {
    final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
    final handled = await context.read<StudyCubit>().handlePhotoUpload(isSubscribed: isSubscribed);
    
    if (!mounted) return;
    
    if (!handled) {
      // Show permission dialog
      if (mounted) {
        PermissionDeniedDialogWidget.show(
          context: context,
          permissionType: 'Camera',
        );
      }
    }
  }
  
  Future<void> _handleGalleryUpload() async {
    final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
    final handled = await context.read<StudyCubit>().handleGalleryUpload(isSubscribed: isSubscribed);
    
    if (!mounted) return;
    
    if (!handled) {
      // Show permission dialog
      if (mounted) {
        PermissionDeniedDialogWidget.show(
          context: context,
          permissionType: 'Photo Library',
        );
      }
    }
  }

  void _handleTextInput() async {
    final studyCubit = context.read<StudyCubit>();
    final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
    final result = await showDialog<String>(
      context: context,
      builder:
          (context) => BlocProvider.value(
            value: studyCubit,
            child: const TextInputDialog(),
          ),
    );
    
    if (result != null && result.isNotEmpty) {
      studyCubit.processTextMaterial(result, isSubscribed: isSubscribed);
    }
  }

  Future<void> _handleDocumentUpload() async {
    final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
    final handled = await context.read<StudyCubit>().handleDocumentUpload(isSubscribed: isSubscribed);
    
    if (!mounted) return;
    
    if (!handled) {
      // Show permission dialog for iOS/macOS
      if (mounted) {
        PermissionDeniedDialogWidget.show(
          context: context,
          permissionType: 'Photo Library',
        );
      }
    }
  }

  Future<void> _generateAndStartQuiz({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) async {
    try {
      final studyCubit = context.read<StudyCubit>();
      final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;

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
        isSubscribed: isSubscribed,
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
      final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
      final quiz = await context.read<StudyCubit>().generateAllMaterialsQuiz(
        isSubscribed: isSubscribed,
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

  Future<void> _startQuizFromPlan(StudyPlan plan) async {
    try {
      final isSubscribed = context.read<SubscriptionCubit>().state.isSubscribed;
      final quiz = await context.read<StudyCubit>().generateQuizFromPlan(
        plan,
        difficulty: QuizDifficulty.medium,
        questionCount: 10,
        timeLimit: 15,
        isSubscribed: isSubscribed,
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
            child: BlocListener<StudyCubit, StudyState>(
              listener: (context, state) {
                // Show success message when topic is started
                final updatedPlan = state.studyPlans.firstWhere(
                  (p) => p.id == plan.id,
                  orElse: () => plan,
                );
                if (updatedPlan != plan) {
                  // Check if any topic changed from notStarted to inProgress
                  for (int i = 0; i < plan.topics.length; i++) {
                    if (i < updatedPlan.topics.length &&
                        plan.topics[i].status == StudyTopicStatus.notStarted &&
                        updatedPlan.topics[i].status ==
                            StudyTopicStatus.inProgress) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color:
                                    Theme.of(context).colorScheme.onSecondary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${AppLocalizations.of(context)!.topicStarted}!',
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      updatedPlan.topics[i].title,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSecondary
                                            .withValues(alpha: 0.9),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          duration: const Duration(seconds: 4),
                          action: SnackBarAction(
                            label: AppLocalizations.of(context)!.takeQuiz,
                            textColor:
                                Theme.of(context).colorScheme.onSecondary,
                            onPressed: () {
                              // Close the bottom sheet and start a quiz
                              Navigator.of(context).pop();
                              _generateAndStartQuiz(
                                difficulty: QuizDifficulty.medium,
                                questionCount: 5,
                                timeLimit: 10,
                              );
                            },
                          ),
                        ),
                      );
                      break;
                    }
                  }
                }
              },
              child: BlocBuilder<StudyCubit, StudyState>(
                builder: (context, state) {
                  final currentPlan = state.studyPlans.firstWhere(
                    (p) => p.id == plan.id,
                    orElse: () => plan,
                  );
                  return StudyPlanTopicsSheetWidget(
                    plan: currentPlan,
                    studyPlans: state.studyPlans,
                    onUpdateTopicProgress:
                        (planId, topicId, progress) => studyCubit
                            .updateTopicProgress(planId, topicId, progress),
                    onMarkTopicComplete:
                        (planId, topicId) =>
                            studyCubit.markTopicComplete(planId, topicId),
                    onTopicTap: _showTopicDetailsDialog,
                  );
                },
              ),
            ),
          ),
    );
  }

  void _showTopicDetailsDialog(
    BuildContext context,
    StudyPlan plan,
    StudyTopic topic,
  ) {
    final studyCubit = context.read<StudyCubit>();
    showDialog(
      context: context,
      builder:
          (dialogContext) => BlocProvider.value(
            value: studyCubit,
            child: TopicDetailsDialogWidget(plan: plan, topic: topic),
          ),
    );
  }

  Future<void> _generateFlashcardsFromMaterials(
    List<StudyMaterial> materials, 
    String deckName, 
    String? deckDescription
  ) async {
    await context.read<FlashcardCubit>().generateFlashcardsFromMaterials(
      materials: materials,
      deckName: deckName,
      deckDescription: deckDescription,
    );
    
    if (mounted) {
      AppSnackBar.showSuccess(
        context,
        AppLocalizations.of(context)!.deckUpdatedSuccessfully,
      );
    }
  }

  // Removed _generateFlashcardsFromQuiz method - quiz generation not needed
}
