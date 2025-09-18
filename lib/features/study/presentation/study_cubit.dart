import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../data/repository/study_material_repository.dart';
import '../data/repository/study_plan_repository.dart';
import '../data/services/study_plan_service.dart';
import '../data/services/quiz_service.dart';
import '../data/services/document_processing_service.dart';
import '../domain/models/study_material.dart';
import '../domain/models/study_plan.dart';
import '../domain/models/quiz.dart';
import '../../common/presentation/permission_cubit.dart';
import '../../subscription/presentation/subscription_cubit.dart';
import 'study_state.dart';

class StudyCubit extends Cubit<StudyState> {
  final StudyMaterialRepository _materialRepository;
  final StudyPlanRepository _planRepository;
  final StudyPlanService _studyPlanService;
  final QuizService _quizService;
  final DocumentProcessingService _documentService;
  final ImagePicker _picker;
  final PermissionCubit _permissionCubit;
  final SubscriptionCubit _subscriptionCubit;

  static const int _maxImagesPerSelection = 5;

  StudyCubit({
    required StudyMaterialRepository materialRepository,
    required StudyPlanRepository planRepository,
    required StudyPlanService studyPlanService,
    required QuizService quizService,
    required ImagePicker picker,
    required PermissionCubit permissionCubit,
    required SubscriptionCubit subscriptionCubit,
    DocumentProcessingService? documentService,
  }) : _materialRepository = materialRepository,
       _planRepository = planRepository,
       _studyPlanService = studyPlanService,
       _quizService = quizService,
       _documentService = documentService ?? DocumentProcessingService(),
       _picker = picker,
       _permissionCubit = permissionCubit,
       _subscriptionCubit = subscriptionCubit,
       super(const StudyState());

  Future<void> initializeServices() async {
    try {
      await _studyPlanService.initialize();
      await _quizService.initialize();
      await loadData();
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error initializing services: $e'));
      }
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

      if (!isClosed) {
        emit(
          state.copyWith(
            studyMaterials: materials,
            studyPlans: plans,
            isLoading: false,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isLoading: false,
            errorMsg: 'Error loading study data: $e',
          ),
        );
      }
    }
  }

  Future<void> refreshData() async {
    await loadData();
  }

  // Upload Methods
  Future<bool> handlePhotoUpload() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;

      if (!isSubscribed) {
        try {
          // Show paywall
          await RevenueCatUI.presentPaywall();

          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;

          if (!newStatus) {
            // User didn't subscribe, don't proceed
            return true;
          }
          // User subscribed, continue with photo capture
        } catch (e) {
          // Error showing paywall
          if (!isClosed) {
            emit(
              state.copyWith(
                errorMsg: 'Subscription required to generate study materials',
              ),
            );
          }
          return true;
        }
      }

      // Check if we should show dialog BEFORE making the request
      final shouldShowDialogBeforeRequest =
          _permissionCubit.state.hasCameraBeenDenied;

      // Request camera permission
      final cameraStatus = await _permissionCubit.requestCameraPermission();

      // Check if should show dialog based on the state before the request
      if (shouldShowDialogBeforeRequest &&
          (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied)) {
        _permissionCubit.setPendingCameraPermission(true);
        return false; // Caller should show permission dialog
      }

      // If permission is denied, don't proceed
      if (cameraStatus.isDenied || cameraStatus.isPermanentlyDenied) {
        return true; // Permission was handled, but denied
      }

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 85,
      );

      if (photo != null) {
        emit(state.copyWith(isUploadingPhoto: true));
        await _processUploadedMaterial(File(photo.path), MaterialType.image);
      } else {
        emit(state.copyWith(isUploadingPhoto: false));
      }

      return true; // Permission was handled successfully
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            errorMsg: 'Error capturing photo: $e',
          ),
        );
      }
      return true;
    }
  }

  Future<bool> handleGalleryUpload() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;

      if (!isSubscribed) {
        try {
          // Show paywall
          await RevenueCatUI.presentPaywall();

          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;

          if (!newStatus) {
            // User didn't subscribe, don't proceed
            return true;
          }
          // User subscribed, continue with gallery selection
        } catch (e) {
          // Error showing paywall
          if (!isClosed) {
            emit(
              state.copyWith(
                errorMsg: 'Subscription required to generate study materials',
              ),
            );
          }
          return true;
        }
      }

      // Check if we should show dialog BEFORE making the request
      final shouldShowDialogBeforeRequest =
          _permissionCubit.state.hasGalleryBeenDenied;

      // Request gallery permission
      final photoStatus = await _permissionCubit.requestGalleryPermission();

      // Check if should show dialog based on the state before the request
      if (shouldShowDialogBeforeRequest &&
          (photoStatus.isDenied || photoStatus.isPermanentlyDenied)) {
        _permissionCubit.setPendingGalleryPermission(true);
        return false; // Caller should show permission dialog
      }

      // If permission is denied, don't proceed
      if (photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
        return true; // Permission was handled, but denied
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
          emit(
            state.copyWith(
              errorMsg:
                  'Only $_maxImagesPerSelection images can be processed per selection',
            ),
          );
        }

        for (final xFile in imagesToProcess) {
          await _processUploadedMaterial(File(xFile.path), MaterialType.image);
        }
      } else {
        emit(state.copyWith(isUploadingPhoto: false));
      }

      return true; // Permission was handled successfully
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            errorMsg: 'Error uploading from gallery: $e',
          ),
        );
      }
      return true;
    }
  }

  Future<void> processTextMaterial(String text) async {
    emit(state.copyWith(isUploadingText: true));
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;

      if (!isSubscribed) {
        emit(state.copyWith(isUploadingText: false));
        try {
          // Show paywall
          await RevenueCatUI.presentPaywall();

          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;

          if (!newStatus) {
            // User didn't subscribe, don't proceed
            return;
          }
          // User subscribed, continue with text processing
        } catch (e) {
          // Error showing paywall
          if (!isClosed) {
            emit(
              state.copyWith(
                errorMsg: 'Subscription required to generate study materials',
              ),
            );
          }
          return;
        }
      }

      await _processUploadedMaterial(
        null,
        MaterialType.text,
        textContent: text,
      );
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingText: false,
            errorMsg: 'Error processing text material: $e',
          ),
        );
      }
    }
  }

  Future<bool> handleDocumentUpload() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;

      if (!isSubscribed) {
        try {
          // Show paywall
          await RevenueCatUI.presentPaywall();

          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;

          if (!newStatus) {
            // User didn't subscribe, don't proceed
            return true;
          }
          // User subscribed, continue with document selection
        } catch (e) {
          // Error showing paywall
          if (!isClosed) {
            emit(
              state.copyWith(
                errorMsg: 'Subscription required to generate study materials',
              ),
            );
          }
          return true;
        }
      }

      // For iOS/macOS, file picker might need photo library permission for accessing files from Photos
      // This is because users might select PDFs saved in their Photos app
      if (Platform.isIOS || Platform.isMacOS) {
        // Check if we should show dialog BEFORE making the request
        final shouldShowDialogBeforeRequest =
            _permissionCubit.state.hasGalleryBeenDenied;

        // Request gallery permission (needed for accessing files from Photos on iOS)
        final photoStatus = await _permissionCubit.requestGalleryPermission();

        // Check if should show dialog based on the state before the request
        if (shouldShowDialogBeforeRequest &&
            (photoStatus.isDenied || photoStatus.isPermanentlyDenied)) {
          _permissionCubit.setPendingGalleryPermission(true);
          return false; // Caller should show permission dialog
        }

        // If permission is denied, don't proceed
        if (photoStatus.isDenied || photoStatus.isPermanentlyDenied) {
          return true; // Permission was handled, but denied
        }
      }

      // Open file picker for PDF files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        // Set loading state only after file is selected
        emit(state.copyWith(isUploadingPhoto: true));

        final file = File(result.files.single.path!);

        // Validate file
        if (!_documentService.isValidPdfFile(file.path)) {
          emit(state.copyWith(isUploadingPhoto: false));
          throw Exception('Please select a valid PDF file');
        }

        // Check file size
        final sizeMB = await _documentService.getFileSizeInMB(file);
        if (sizeMB > 10) {
          emit(state.copyWith(isUploadingPhoto: false));
          throw Exception(
            'PDF file size (${sizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of 10MB',
          );
        }

        // Process the PDF as a document
        await _processUploadedMaterial(file, MaterialType.document);
      }

      return true; // File picker was handled successfully
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isUploadingPhoto: false,
            errorMsg: 'Error uploading PDF: $e',
          ),
        );
      }
      return true;
    }
  }

  Future<void> _processUploadedMaterial(
    File? file,
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
      final title = _getMaterialTitle(type, state.studyMaterials.length + 1);

      // Prepare document bytes if it's a PDF
      Uint8List? documentBytes;
      if (type == MaterialType.document && file != null) {
        documentBytes = await _documentService.processPdfFile(file);
      }

      // Analyze the material
      final studyMaterial = await _studyPlanService.analyzeMaterial(
        materialId: materialId,
        type: type,
        content: textContent,
        imageFile: type == MaterialType.image ? file : null,
        documentBytes: documentBytes,
        title: title,
      );

      // Handle file upload to Firebase Storage if needed
      StudyMaterial finalMaterial = studyMaterial;
      if (file != null &&
          (type == MaterialType.image || type == MaterialType.document)) {
        try {
          final downloadUrl = await _materialRepository.uploadImage(
            file,
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

      // Update state with new material (add to beginning for newest first)
      final updatedMaterials = [finalMaterial, ...state.studyMaterials];
      if (!isClosed) {
        emit(
          state.copyWith(
            studyMaterials: updatedMaterials,
            isProcessing: false,
            isUploadingPhoto: false,
            isUploadingText: false,
          ),
        );
      }

      // Generate individual study plan for this material
      await _generateIndividualStudyPlan(finalMaterial);
    } catch (e) {
      if (!isClosed) {
        String errorMessage = 'Error processing material: $e';

        // Error processing material

        // Check if it's a non-math content error and localize it
        if (e.toString().contains('does not contain mathematical material') ||
            e.toString().contains('ne contient pas de matériel mathématique') ||
            e.toString().contains('no contiene material matemático')) {
          // We need BuildContext to get localized strings
          // For now, we'll use the error message as is
          // The UI layer should handle localization when displaying this error
          // Differentiate between different material type errors
          if (type == MaterialType.text) {
            errorMessage = 'NON_MATH_TEXT_ERROR';
          } else if (type == MaterialType.document) {
            errorMessage = 'NON_MATH_DOCUMENT_ERROR';
          } else {
            errorMessage = 'NON_MATH_CONTENT_ERROR';
          }
        }

        emit(
          state.copyWith(
            isProcessing: false,
            isUploadingPhoto: false,
            isUploadingText: false,
            errorMsg: errorMessage,
          ),
        );
      }
    }
  }

  String _getMaterialTitle(MaterialType type, int count) {
    switch (type) {
      case MaterialType.image:
        return 'Study Material $count';
      case MaterialType.text:
        return 'Text Material $count';
      case MaterialType.document:
        return 'Document Material $count';
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

      // Update state with new plan (add to beginning for newest first)
      final updatedPlans = [studyPlan, ...state.studyPlans];
      if (!isClosed) {
        emit(
          state.copyWith(
            studyPlans: updatedPlans,
            isProcessing: false,
            studyPlanGenerated: true,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isProcessing: false,
            errorMsg: 'Error generating study plan: $e',
          ),
        );
      }
    }
  }

  // Quiz Generation Methods
  Future<Quiz> generateQuiz({
    required QuizDifficulty difficulty,
    required int questionCount,
    required int timeLimit,
    StudyPlan? selectedPlan,
  }) async {
    _setQuizLoading(difficulty, true);

    try {
      // Check if we have no materials or plans
      if (state.studyMaterials.isEmpty && state.studyPlans.isEmpty) {
        _setQuizLoading(difficulty, false);
        emit(
          state.copyWith(
            errorMsg:
                'No study materials or plans available for quiz generation',
          ),
        );
        throw Exception(
          'No study materials or plans available for quiz generation',
        );
      }

      Quiz quiz;

      // If a specific plan was selected (from dialog), use it
      if (selectedPlan != null) {
        quiz = await _quizService.generateQuizFromStudyPlan(
          studyPlan: selectedPlan,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      }
      // If we have exactly one study plan, use it automatically
      else if (state.studyPlans.length == 1) {
        quiz = await _quizService.generateQuizFromStudyPlan(
          studyPlan: state.studyPlans.first,
          difficulty: difficulty,
          questionCount: questionCount,
          timeLimit: timeLimit,
        );
      }
      // Otherwise, generate from study materials
      else {
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
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error generating quiz: $e'));
      }
      rethrow;
    }
  }

  // Check if we need to show study plan selection dialog
  bool shouldShowPlanSelectionDialog() {
    return state.studyPlans.length > 1;
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

      if (!isClosed) {
        emit(state.copyWith(clearProcessingPlanId: true));
      }
      return quiz;
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            clearProcessingPlanId: true,
            errorMsg: 'Error generating quiz: $e',
          ),
        );
      }
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

      if (!isClosed) {
        emit(state.copyWith(isAllMaterialsQuizLoading: false));
      }
      return quiz;
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isAllMaterialsQuizLoading: false,
            errorMsg: 'Error generating comprehensive quiz: $e',
          ),
        );
      }
      rethrow;
    }
  }

  void _setQuizLoading(QuizDifficulty difficulty, bool isLoading) {
    if (!isClosed) {
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
  }

  // Plan Management Methods
  Future<void> deletePlan(String planId) async {
    try {
      await _planRepository.deletePlan(planId);

      final updatedPlans =
          state.studyPlans.where((plan) => plan.id != planId).toList();
      if (!isClosed) {
        emit(state.copyWith(studyPlans: updatedPlans));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error deleting study plan: $e'));
      }
    }
  }

  // Topic Management Methods
  Future<void> updateTopicProgress(
    String planId,
    String topicId,
    double progress,
  ) async {
    try {
      final planIndex = state.studyPlans.indexWhere(
        (plan) => plan.id == planId,
      );
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
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error updating progress: $e'));
      }
    }
  }

  Future<void> markTopicComplete(String planId, String topicId) async {
    try {
      final planIndex = state.studyPlans.indexWhere(
        (plan) => plan.id == planId,
      );
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
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error marking topic complete: $e'));
      }
    }
  }

  Future<void> markTopicIncomplete(String planId, String topicId) async {
    try {
      final planIndex = state.studyPlans.indexWhere(
        (plan) => plan.id == planId,
      );
      if (planIndex == -1) return;

      final plan = state.studyPlans[planIndex];
      final updatedPlan = plan.markTopicIncomplete(topicId);

      // Update local state
      final updatedPlans = [...state.studyPlans];
      updatedPlans[planIndex] = updatedPlan;

      emit(state.copyWith(studyPlans: updatedPlans));

      // Persist to database
      await _planRepository.updatePlan(updatedPlan);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error marking topic incomplete: $e'));
      }
    }
  }

  Future<void> startTopic(String planId, String topicId) async {
    try {
      final planIndex = state.studyPlans.indexWhere(
        (plan) => plan.id == planId,
      );
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
      if (!isClosed) {
        emit(state.copyWith(errorMsg: 'Error starting topic: $e'));
      }
    }
  }

  void clearError() {
    if (!isClosed) {
      emit(state.copyWith(clearError: true));
    }
  }

  void clearStudyPlanGenerated() {
    if (!isClosed) {
      emit(state.copyWith(studyPlanGenerated: false));
    }
  }
}
