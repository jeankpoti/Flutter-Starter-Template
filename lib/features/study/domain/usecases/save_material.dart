import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/study_material_entity.dart';
import '../repositories/study_material_repository.dart';

/// Parameters for saving a study material
class SaveMaterialParams {
  final StudyMaterialEntity material;

  const SaveMaterialParams({required this.material});
}

/// Use case for saving a study material
class SaveMaterialUseCase implements UseCase<void, SaveMaterialParams> {
  final StudyMaterialRepository repository;

  const SaveMaterialUseCase(this.repository);

  @override
  Future<Result<void>> call(SaveMaterialParams params) async {
    return await repository.saveMaterial(params.material);
  }
}