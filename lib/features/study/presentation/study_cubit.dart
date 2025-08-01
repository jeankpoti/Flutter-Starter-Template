import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../data/repository/study_material_repository.dart';
import '../data/repository/study_plan_repository.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../domain/models/study_material.dart';
import '../domain/models/study_plan.dart';
import '../domain/models/quiz.dart';
import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyMaterialRepository _materialRepository;
  final StudyPlanRepository _planRepository;
  final StudyPlanService _studyPlanService;
  final QuizService _quizService;
  final ImagePicker _picker;

  static const int _maxImagesPerSelection = 5;

  StudyCubit({
    required StudyMaterialRepository materialRepository,
    required StudyPlanRepository planRepository,
    required StudyPlanService studyPlanService,
    required QuizService quizService,
    required ImagePicker picker,
  })  : _materialRepository = materialRepository,
        _planRepository = planRepository,
        _studyPlanService = studyPlanService,
        _quizService = quizService,
        _picker = picker,
        super(const StudyState());

  Future<void> initializeServices() async {
    try {
      await _studyPlanService.initialize();
      await _quizService.initialize();
      await loadData();
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Error initializing services: $e'));
    }
  }

  Future<void> loadData() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final futures = await Future.wait([
        _materialRepository.getUserMaterials(),
        _planRepository.getUserPlans(),
      ]);

      final materials = futures[0] as List<StudyMaterial>;
      final plans = futures[1] as List<StudyPlan>;

      emit(state.copyWith(
        studyMaterials: materials,
        studyPlans: plans,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMsg: 'Error loading study data: $e',
      ));
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Upload Methods
  Future<void> handlePhotoUpload() async {
    try {
      if (Platform.isAndroid) {
        final cameraStatus = await Permission.camera.request();
        if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
          emit(state.copyWith(errorMsg: 'Camera permission required'));
          return;
        }
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (photo != null) {
        emit(state.copyWith(isUploadingPhoto: true));
        await _processUploadedMaterial(
          File(photo.path),
          MaterialType.image,
        );
      } else {
        emit(state.copyWith(isUploadingPhoto: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isUploadingPhoto: false,
        errorMsg: 'Error capturing photo: $e',
      ));
    }
  }

  Future<void> handleGalleryUpload() async {
    try {
      if (Platform.isAndroid) {
        final photosStatus = await Permission.photos.request();
        if (photosStatus.isDenied || photosStatus.isPermanentlyDenied) {
          emit(state.copyWith(errorMsg: 'Photos permission required'));
          return;
        }
      }

      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
        limit: _maxImagesPerSelection,
      );

      if (images.isNotEmpty) {
        emit(state.copyWith(isUploadingPhoto: true));
        final imagesToProcess = images.take(_maxImagesPerSelection).toList();

        if (images.length > _maxImagesPerSelection) {
          emit(state.copyWith(
            errorMsg: 'Only $_maxImagesPerSelection images can be processed per selection',
          ));
        }

        for (final xFile in imagesToProcess) {
          await _processUploadedMaterial(
            File(xFile.path),
            MaterialType.image,
          );
        }
      } else {
        emit(state.copyWith(isUploadingPhoto: false));
      }
    } catch (e) {
      emit(state.copyWith(
        isUploadingPhoto: false,
        errorMsg: 'Error uploading from gallery: $e',
      ));
    }
  }

  Future<void> processTextMaterial(String text) async {
    emit(state.copyWith(isUploadingText: true));
    try {
      await _processUploadedMaterial(null, MaterialType.text, textContent: text);
    } catch (e) {
      emit(state.copyWith(
        isUploadingText: false,
        errorMsg: 'Error processing text material: $e',
      ));
    }
  }

  Future<void> _processUploadedMaterial(
    File? imageFile,
    MaterialType type, {
    String? textContent,
  }) async {
    if (type == MaterialType.text) {
      emit(state.copyWith(isProcessing: true, isUploadingPhoto: false));
    } else {
      emit(state.copyWith(isProcessing: true));
    }

    try {
      final materialId = DateTime.now().millisecondsSinceEpoch.toString();
      final title = type == MaterialType.image
          ? 'Study Material ${state.studyMaterials.length + 1}'
          : 'Text Material ${state.studyMaterials.length + 1}';

      // Analyze the material
      final studyMaterial = await _studyPlanService.analyzeMaterial(
        materialId: materialId,
        type: type,
        content: textContent,
        imageFile: imageFile,
        title: title,
      );

      // Handle image upload to Firebase Storage if needed
      StudyMaterial finalMaterial = studyMaterial;
      if (imageFile != null && type == MaterialType.image) {
        try {
          final downloadUrl = await _materialRepository.uploadImage(
            imageFile,
            materialId,
          );
          finalMaterial = studyMaterial.copyWith(
            firebaseStoragePath: downloadUrl,
          );
        } catch (e) {
          // Continue without Firebase Storage URL
        }
      }

      // Save material to database
      await _materialRepository.saveMaterial(finalMaterial);

      // Update state with new material
      final updatedMaterials = [...state.studyMaterials, finalMaterial];
      emit(state.copyWith(
        studyMaterials: updatedMaterials,
        isProcessing: false,
        isUploadingPhoto: false,
        isUploadingText: false,
      ));

      // Generate individual study plan for this material
      await _generateIndividualStudyPlan(finalMaterial);
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        isUploadingPhoto: false,
        isUploadingText: false,
        errorMsg: 'Error processing material: $e',
      ));
    }
  }

  Future<void> _generateIndividualStudyPlan(StudyMaterial material) async {
    try {
      emit(state.copyWith(isProcessing: true));

      final studyPlan = await _studyPlanService.generateStudyPlan(
        materials: [material],
        customTitle: "Plan: ${material.title}",
      );

      // Save study plan to database
      await _planRepository.savePlan(studyPlan);

      // Update state with new plan
      final updatedPlans = [...state.studyPlans, studyPlan];
      emit(state.copyWith(
        studyPlans: updatedPlans,
        isProcessing: false,
        studyPlanGenerated: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isProcessing: false,
        errorMsg: 'Error generating study plan: $e',
      ));
    }
  }

  // Quiz Generation Methods
  Future<Quiz> generateQuiz({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) async {
    _setQuizLoading(difficulty, true);

    try {
      Quiz quiz;

      if (state.studyPlans.length == 1) {
        quiz = await _quizService.generateQuizFromStudyPlan(
          studyPlan: state.studyPlans.first,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      } else {
        quiz = await _quizService.generateQuizFromMaterials(
          materials: state.studyMaterials,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      }

      _setQuizLoading(difficulty, false);
      return quiz;
    } catch (e) {
      _setQuizLoading(difficulty, false);
      emit(state.copyWith(errorMsg: 'Error generating quiz: $e'));
      rethrow;
    }
  }

  Future<Quiz> generateQuizFromPlan(
    StudyPlan plan, {
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
  }) async {
    emit(state.copyWith(processingPlanId: plan.id));

    try {
      final quiz = await _quizService.generateQuizFromStudyPlan(
        studyPlan: plan,
        difficulty: difficulty,
        questionCount: questionCount,
        timeLimit: timeLimit,
      );

      emit(state.copyWith(clearProcessingPlanId: true));
      return quiz;
    } catch (e) {
      emit(state.copyWith(
        clearProcessingPlanId: true,
        errorMsg: 'Error generating quiz: $e',
      ));
      rethrow;
    }
  }

  Future<Quiz> generateAllMaterialsQuiz() async {
    emit(state.copyWith(isAllMaterialsQuizLoading: true));

    try {
      final quiz = await _quizService.generateQuizFromMaterials(
        materials: state.studyMaterials,
        difficulty: QuizDifficulty.medium,
        questionCount: 12,
        timeLimit: 25,
        customTitle: 'Comprehensive Quiz - All Materials',
      );

      emit(state.copyWith(isAllMaterialsQuizLoading: false));
      return quiz;
    } catch (e) {
      emit(state.copyWith(
        isAllMaterialsQuizLoading: false,
        errorMsg: 'Error generating comprehensive quiz: $e',
      ));
      rethrow;
    }
  }

  void _setQuizLoading(QuizDifficulty difficulty, bool isLoading) {
    switch (difficulty) {
      case QuizDifficulty.easy:
        emit(state.copyWith(isQuickQuizLoading: isLoading));
        break;
      case QuizDifficulty.medium:
        emit(state.copyWith(isPracticeTestLoading: isLoading));
        break;
      case QuizDifficulty.hard:
        emit(state.copyWith(isChallengeLoading: isLoading));
        break;
    }
  }

  // Plan Management Methods
  Future<void> deletePlan(String planId) async {
    try {
      await _planRepository.deletePlan(planId);

      final updatedPlans = state.studyPlans.where((plan) => plan.id != planId).toList();
      emit(state.copyWith(
        studyPlans: updatedPlans,
      ));
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Error deleting study plan: $e'));
    }
  }

  // Topic Management Methods
  Future<void> updateTopicProgress(
    String planId,
    String topicId,
    double progress,
  ) async {
    try {
      final planIndex = state.studyPlans.indexWhere((plan) => plan.id == planId);
      if (planIndex == -1) return;

      final plan = state.studyPlans[planIndex];
      final updatedPlan = plan.updateTopicProgress(topicId, progress);

      // Update local state
      final updatedPlans = [...state.studyPlans];
      updatedPlans[planIndex] = updatedPlan;

      emit(state.copyWith(studyPlans: updatedPlans));

      // Persist to database
      await _planRepository.updatePlan(updatedPlan);
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Error updating progress: $e'));
    }
  }

  Future<void> markTopicComplete(String planId, String topicId) async {
    try {
      final planIndex = state.studyPlans.indexWhere((plan) => plan.id == planId);
      if (planIndex == -1) return;

      final plan = state.studyPlans[planIndex];
      final updatedPlan = plan.markTopicComplete(topicId);

      // Update local state
      final updatedPlans = [...state.studyPlans];
      updatedPlans[planIndex] = updatedPlan;

      emit(state.copyWith(studyPlans: updatedPlans));

      // Persist to database
      await _planRepository.updatePlan(updatedPlan);
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Error marking topic complete: $e'));
    }
  }

  Future<void> startTopic(String planId, String topicId) async {
    try {
      final planIndex = state.studyPlans.indexWhere((plan) => plan.id == planId);
      if (planIndex == -1) return;

      final plan = state.studyPlans[planIndex];
      final updatedPlan = plan.startTopic(topicId);

      // Update local state
      final updatedPlans = [...state.studyPlans];
      updatedPlans[planIndex] = updatedPlan;

      emit(state.copyWith(studyPlans: updatedPlans));

      // Persist to database
      await _planRepository.updatePlan(updatedPlan);
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Error starting topic: $e'));
    }
  }

  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  void clearStudyPlanGenerated() {
    emit(state.copyWith(studyPlanGenerated: false));
  }
}
