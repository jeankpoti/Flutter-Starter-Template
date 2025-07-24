import '../../../../core/utils/result.dart';
import '../entities/study_material_entity.dart';

/// Abstract repository interface for study materials
abstract class StudyMaterialRepository {
  /// Get all study materials for the current user
  Future<Result<List<StudyMaterialEntity>>> getUserMaterials();
  
  /// Get a specific study material by ID
  Future<Result<StudyMaterialEntity>> getMaterialById(String id);
  
  /// Save a study material
  Future<Result<void>> saveMaterial(StudyMaterialEntity material);
  
  /// Update an existing study material
  Future<Result<void>> updateMaterial(StudyMaterialEntity material);
  
  /// Delete a study material
  Future<Result<void>> deleteMaterial(String id);
  
  /// Upload an image and process it
  Future<Result<StudyMaterialEntity>> uploadAndProcessImage({
    required String imagePath,
    required String title,
    String? description,
  });
  
  /// Process text content
  Future<Result<StudyMaterialEntity>> processTextContent({
    required String content,
    required String title,
    String? description,
  });
  
  /// Search materials by query
  Future<Result<List<StudyMaterialEntity>>> searchMaterials(String query);
  
  /// Get materials by status
  Future<Result<List<StudyMaterialEntity>>> getMaterialsByStatus(MaterialStatus status);
  
  /// Get materials by type
  Future<Result<List<StudyMaterialEntity>>> getMaterialsByType(MaterialType type);
}