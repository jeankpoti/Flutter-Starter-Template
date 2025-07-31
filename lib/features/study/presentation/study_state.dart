import 'package:equatable/equatable.dart';
import '../domain/models/study_material.dart';
import '../domain/models/study_plan.dart';

class StudyState extends Equatable {
  final List<StudyMaterial> studyMaterials;
  final List<StudyPlan> studyPlans;
  final bool isLoading; // General loading state
  final bool isProcessing; // Processing materials/plans
  final bool isSuccess;
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

  const StudyState({
    this.studyMaterials = const [],
    this.studyPlans = const [],
    this.isLoading = false,
    this.isProcessing = false,
    this.isSuccess = false,
    this.errorMsg,
    this.isQuickQuizLoading = false,
    this.isPracticeTestLoading = false,
    this.isChallengeLoading = false,
    this.isAllMaterialsQuizLoading = false,
    this.processingPlanId,
    this.isUploadingText = false,
    this.isUploadingPhoto = false,
  });

  StudyState copyWith({
    List<StudyMaterial>? studyMaterials,
    List<StudyPlan>? studyPlans,
    bool? isLoading,
    bool? isProcessing,
    bool? isSuccess,
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
  }) {
    return StudyState(
      studyMaterials: studyMaterials ?? this.studyMaterials,
      studyPlans: studyPlans ?? this.studyPlans,
      isLoading: isLoading ?? this.isLoading,
      isProcessing: isProcessing ?? this.isProcessing,
      isSuccess: isSuccess ?? this.isSuccess,
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
    );
  }

  @override
  List<Object?> get props => [
    studyMaterials,
    studyPlans,
    isLoading,
    isProcessing,
    isSuccess,
    errorMsg,
    isQuickQuizLoading,
    isPracticeTestLoading,
    isChallengeLoading,
    isAllMaterialsQuizLoading,
    processingPlanId,
    isUploadingText,
    isUploadingPhoto,
  ];
}
