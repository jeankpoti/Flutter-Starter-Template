import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/result.dart';
import '../entities/study_material_entity.dart';
import '../repositories/study_material_repository.dart';

/// Parameters for processing text content
class ProcessTextParams {
  final String content;
  final String title;
  final String? description;

  const ProcessTextParams({
    required this.content,
    required this.title,
    this.description,
  });
}

/// Use case for processing text content
class ProcessTextContentUseCase implements UseCase<StudyMaterialEntity, ProcessTextParams> {
  final StudyMaterialRepository repository;

  const ProcessTextContentUseCase(this.repository);

  @override
  Future<Result<StudyMaterialEntity>> call(ProcessTextParams params) async {
    return await repository.processTextContent(
      content: params.content,
      title: params.title,
      description: params.description,
    );
  }
}