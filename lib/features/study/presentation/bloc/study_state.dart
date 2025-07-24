import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/study_material_entity.dart';

part 'study_state.freezed.dart';

/// States for StudyBloc
@freezed
class StudyState with _$StudyState {
  /// Initial state
  const factory StudyState.initial() = _Initial;
  
  /// Loading state
  const factory StudyState.loading() = _Loading;
  
  /// Materials loaded successfully
  const factory StudyState.materialsLoaded({
    required List<StudyMaterialEntity> materials,
    List<StudyMaterialEntity>? filteredMaterials,
    String? searchQuery,
  }) = _MaterialsLoaded;
  
  /// Material uploaded successfully
  const factory StudyState.materialUploaded({
    required StudyMaterialEntity material,
    required List<StudyMaterialEntity> allMaterials,
  }) = _MaterialUploaded;
  
  /// Material deleted successfully
  const factory StudyState.materialDeleted({
    required String materialId,
    required List<StudyMaterialEntity> remainingMaterials,
  }) = _MaterialDeleted;
  
  /// Error state
  const factory StudyState.error({
    required Failure failure,
    List<StudyMaterialEntity>? materials, // Keep previous materials if available
  }) = _Error;
  
  /// Processing state (for uploads)
  const factory StudyState.processing({
    required String message,
    List<StudyMaterialEntity>? materials, // Keep current materials visible
  }) = _Processing;
}

/// Extension to provide helper methods
extension StudyStateX on StudyState {
  /// Get current materials if available
  List<StudyMaterialEntity>? get currentMaterials => maybeWhen(
    materialsLoaded: (materials, filteredMaterials, searchQuery) => 
        filteredMaterials ?? materials,
    materialUploaded: (material, allMaterials) => allMaterials,
    materialDeleted: (materialId, remainingMaterials) => remainingMaterials,
    error: (failure, materials) => materials,
    processing: (message, materials) => materials,
    orElse: () => null,
  );
  
  /// Check if currently loading
  bool get isLoading => maybeWhen(
    loading: () => true,
    processing: (message, materials) => true,
    orElse: () => false,
  );
  
  /// Get current search query
  String? get searchQuery => maybeWhen(
    materialsLoaded: (materials, filteredMaterials, searchQuery) => searchQuery,
    orElse: () => null,
  );
}