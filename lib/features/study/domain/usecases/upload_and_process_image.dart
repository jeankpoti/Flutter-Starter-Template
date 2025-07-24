import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/study_material_entity.dart';
import '../repositories/study_material_repository.dart';

/// Parameters for uploading and processing an image
class UploadImageParams {
  final String imagePath;
  final String title;
  final String? description;

  const UploadImageParams({
    required this.imagePath,
    required this.title,
    this.description,
  });
}

/// Use case for uploading and processing an image
class UploadAndProcessImageUseCase implements UseCase<StudyMaterialEntity, UploadImageParams> {
  final StudyMaterialRepository repository;

  const UploadAndProcessImageUseCase(this.repository);

  @override
  Future<Result<StudyMaterialEntity>> call(UploadImageParams params) async {
    return await repository.uploadAndProcessImage(
      imagePath: params.imagePath,
      title: params.title,
      description: params.description,
    );
  }
}