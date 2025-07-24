import 'package:freezed_annotation/freezed_annotation.dart';

part 'study_event.freezed.dart';

/// Events for StudyBloc
@freezed
class StudyEvent with _$StudyEvent {
  /// Load user study materials
  const factory StudyEvent.loadMaterials() = _LoadMaterials;
  
  /// Refresh materials
  const factory StudyEvent.refreshMaterials() = _RefreshMaterials;
  
  /// Upload and process image
  const factory StudyEvent.uploadImage({
    required String imagePath,
    required String title,
    String? description,
  }) = _UploadImage;
  
  /// Process text content
  const factory StudyEvent.processText({
    required String content,
    required String title,
    String? description,
  }) = _ProcessText;
  
  /// Delete material
  const factory StudyEvent.deleteMaterial({
    required String materialId,
  }) = _DeleteMaterial;
  
  /// Search materials
  const factory StudyEvent.searchMaterials({
    required String query,
  }) = _SearchMaterials;
  
  /// Clear search
  const factory StudyEvent.clearSearch() = _ClearSearch;
}