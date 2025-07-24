import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/result.dart';
import '../../domain/usecases/get_user_materials.dart';
import '../../domain/usecases/upload_and_process_image.dart';
import '../../domain/usecases/process_text_content.dart';
import '../../domain/repositories/study_material_repository.dart';
import 'study_event.dart';
import 'study_state.dart';

/// BLoC for managing study materials
class StudyBloc extends Bloc<StudyEvent, StudyState> {
  final GetUserMaterialsUseCase _getUserMaterials;
  final UploadAndProcessImageUseCase _uploadAndProcessImage;
  final ProcessTextContentUseCase _processTextContent;
  final StudyMaterialRepository _repository;

  StudyBloc({
    required GetUserMaterialsUseCase getUserMaterials,
    required UploadAndProcessImageUseCase uploadAndProcessImage,
    required ProcessTextContentUseCase processTextContent,
    required StudyMaterialRepository repository,
  })  : _getUserMaterials = getUserMaterials,
        _uploadAndProcessImage = uploadAndProcessImage,
        _processTextContent = processTextContent,
        _repository = repository,
        super(const StudyState.initial()) {
    
    // Register event handlers
    on<StudyEvent>(_onStudyEvent);
  }

  /// Handle all study events using pattern matching
  Future<void> _onStudyEvent(
    StudyEvent event,
    Emitter<StudyState> emit,
  ) async {
    await event.when(
      loadMaterials: () => _handleLoadMaterials(emit),
      refreshMaterials: () => _handleRefreshMaterials(emit),
      uploadImage: (imagePath, title, description) => 
          _handleUploadImage(imagePath, title, description, emit),
      processText: (content, title, description) => 
          _handleProcessText(content, title, description, emit),
      deleteMaterial: (materialId) => 
          _handleDeleteMaterial(materialId, emit),
      searchMaterials: (query) => 
          _handleSearchMaterials(query, emit),
      clearSearch: () => _handleClearSearch(emit),
    );
  }

  /// Handle loading materials
  Future<void> _handleLoadMaterials(Emitter<StudyState> emit) async {
    emit(const StudyState.loading());
    
    final result = await _getUserMaterials();
    
    result.when(
      success: (materials) => emit(StudyState.materialsLoaded(
        materials: materials,
      )),
      error: (failure) => emit(StudyState.error(failure: failure)),
    );
  }

  /// Handle refreshing materials
  Future<void> _handleRefreshMaterials(Emitter<StudyState> emit) async {
    // Keep current materials visible while refreshing
    final currentMaterials = state.currentMaterials;
    emit(StudyState.processing(
      message: 'Refreshing materials...',
      materials: currentMaterials,
    ));
    
    final result = await _getUserMaterials();
    
    result.when(
      success: (materials) => emit(StudyState.materialsLoaded(
        materials: materials,
      )),
      error: (failure) => emit(StudyState.error(
        failure: failure,
        materials: currentMaterials,
      )),
    );
  }

  /// Handle uploading image
  Future<void> _handleUploadImage(
    String imagePath,
    String title,
    String? description,
    Emitter<StudyState> emit,
  ) async {
    final currentMaterials = state.currentMaterials;
    emit(StudyState.processing(
      message: 'Uploading and processing image...',
      materials: currentMaterials,
    ));

    final result = await _uploadAndProcessImage(UploadImageParams(
      imagePath: imagePath,
      title: title,
      description: description,
    ));

    result.when(
      success: (material) async {
        // Reload all materials to get updated list
        final allMaterialsResult = await _getUserMaterials();
        allMaterialsResult.when(
          success: (allMaterials) => emit(StudyState.materialUploaded(
            material: material,
            allMaterials: allMaterials,
          )),
          error: (failure) => emit(StudyState.error(
            failure: failure,
            materials: currentMaterials,
          )),
        );
      },
      error: (failure) => emit(StudyState.error(
        failure: failure,
        materials: currentMaterials,
      )),
    );
  }

  /// Handle processing text
  Future<void> _handleProcessText(
    String content,
    String title,
    String? description,
    Emitter<StudyState> emit,
  ) async {
    final currentMaterials = state.currentMaterials;
    emit(StudyState.processing(
      message: 'Processing text content...',
      materials: currentMaterials,
    ));

    final result = await _processTextContent(ProcessTextParams(
      content: content,
      title: title,
      description: description,
    ));

    result.when(
      success: (material) async {
        // Reload all materials to get updated list
        final allMaterialsResult = await _getUserMaterials();
        allMaterialsResult.when(
          success: (allMaterials) => emit(StudyState.materialUploaded(
            material: material,
            allMaterials: allMaterials,
          )),
          error: (failure) => emit(StudyState.error(
            failure: failure,
            materials: currentMaterials,
          )),
        );
      },
      error: (failure) => emit(StudyState.error(
        failure: failure,
        materials: currentMaterials,
      )),
    );
  }

  /// Handle deleting material
  Future<void> _handleDeleteMaterial(
    String materialId,
    Emitter<StudyState> emit,
  ) async {
    final currentMaterials = state.currentMaterials ?? [];
    emit(StudyState.processing(
      message: 'Deleting material...',
      materials: currentMaterials,
    ));

    final result = await _repository.deleteMaterial(materialId);

    result.when(
      success: (_) {
        final remainingMaterials = currentMaterials
            .where((material) => material.id != materialId)
            .toList();
        emit(StudyState.materialDeleted(
          materialId: materialId,
          remainingMaterials: remainingMaterials,
        ));
      },
      error: (failure) => emit(StudyState.error(
        failure: failure,
        materials: currentMaterials,
      )),
    );
  }

  /// Handle searching materials
  Future<void> _handleSearchMaterials(
    String query,
    Emitter<StudyState> emit,
  ) async {
    state.maybeWhen(
      materialsLoaded: (materials, filteredMaterials, searchQuery) {
        final queryLower = query.toLowerCase();
        
        if (queryLower.isEmpty) {
          emit(StudyState.materialsLoaded(materials: materials));
          return;
        }

        final filtered = materials.where((material) {
          return material.title.toLowerCase().contains(queryLower) ||
                 (material.description?.toLowerCase().contains(queryLower) ?? false) ||
                 material.extractedTopics.any((topic) => 
                   topic.toLowerCase().contains(queryLower));
        }).toList();

        emit(StudyState.materialsLoaded(
          materials: materials,
          filteredMaterials: filtered,
          searchQuery: query,
        ));
      },
      orElse: () {
        // If not in materialsLoaded state, do nothing
      },
    );
  }

  /// Handle clearing search
  Future<void> _handleClearSearch(Emitter<StudyState> emit) async {
    state.maybeWhen(
      materialsLoaded: (materials, filteredMaterials, searchQuery) {
        emit(StudyState.materialsLoaded(materials: materials));
      },
      orElse: () {
        // If not in materialsLoaded state, do nothing
      },
    );
  }
}