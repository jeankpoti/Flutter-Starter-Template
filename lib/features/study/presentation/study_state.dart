import 'package:equatable/equatable.dart';
import '../domain/models/study_material.dart';
import '../domain/models/study_plan.dart';

class StudyState extends Equatable {
  final List<StudyMaterial> studyMaterials;
  final List<StudyPlan> studyPlans;
  final bool isLoading; // General loading state
  final bool isProcessing; // Processing materials/plans
  final String? errorMsg;

  // Quiz generation loading states
  final bool isQuickQuizLoading;
  final bool isPracticeTestLoading;
  final bool isChallengeLoading;
  final bool isAllMaterialsQuizLoading;
  final String? processingPlanId; // ID of plan being processed for quiz

  // Upload states
  final bool isUploadingText;
  final bool isUploadingPhoto;
  final bool studyPlanGenerated;

  const StudyState({
    this.studyMaterials = const [],
    this.studyPlans = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.errorMsg,
    this.isQuickQuizLoading = false,
    this.isPracticeTestLoading = false,
    this.isChallengeLoading = false,
    this.isAllMaterialsQuizLoading = false,
    this.processingPlanId,
    this.isUploadingText = false,
    this.isUploadingPhoto = false,
    this.studyPlanGenerated = false,
  });

  StudyState copyWith({
    List<StudyMaterial>? studyMaterials,
    List<StudyPlan>? studyPlans,
    bool? isLoading,
    bool? isProcessing,
    String? errorMsg,
    bool clearError = false,
    bool? isQuickQuizLoading,
    bool? isPracticeTestLoading,
    bool? isChallengeLoading,
    bool? isAllMaterialsQuizLoading,
    String? processingPlanId,
    bool clearProcessingPlanId = false,
    bool? isUploadingText,
    bool? isUploadingPhoto,
    bool? studyPlanGenerated,
  }) {
    return StudyState(
      studyMaterials: studyMaterials ?? this.studyMaterials,
      studyPlans: studyPlans ?? this.studyPlans,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMsg: clearError ? null : (errorMsg ?? this.errorMsg),
      isQuickQuizLoading: isQuickQuizLoading ?? this.isQuickQuizLoading,
      isPracticeTestLoading:
          isPracticeTestLoading ?? this.isPracticeTestLoading,
      isChallengeLoading: isChallengeLoading ?? this.isChallengeLoading,
      isAllMaterialsQuizLoading:
          isAllMaterialsQuizLoading ?? this.isAllMaterialsQuizLoading,
      processingPlanId:
          clearProcessingPlanId
              ? null
              : (processingPlanId ?? this.processingPlanId),
      isUploadingText: isUploadingText ?? this.isUploadingText,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      studyPlanGenerated: studyPlanGenerated ?? this.studyPlanGenerated,
    );
  }

  @override
  List<Object?> get props => [
        studyMaterials,
        studyPlans,
        isLoading,
        isProcessing,
        errorMsg,
        isQuickQuizLoading,
        isPracticeTestLoading,
        isChallengeLoading,
        isAllMaterialsQuizLoading,
        processingPlanId,
        isUploadingText,
        isUploadingPhoto,
        studyPlanGenerated,
      ];
}
