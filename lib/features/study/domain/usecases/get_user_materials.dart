import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/study_material_entity.dart';
import '../repositories/study_material_repository.dart';

/// Use case for getting all user study materials
class GetUserMaterialsUseCase implements NoParamsUseCase<List<StudyMaterialEntity>> {
  final StudyMaterialRepository repository;

  const GetUserMaterialsUseCase(this.repository);

  @override
  Future<Result<List<StudyMaterialEntity>>> call() async {
    return await repository.getUserMaterials();
  }
}