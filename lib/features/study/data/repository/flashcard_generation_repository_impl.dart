import '../../domain/repository/flashcard_generation_repository.dart';
import '../services/flashcard_generation_service.dart';

/// Implementation of flashcard generation repository
class FlashcardGenerationRepositoryImpl implements FlashcardGenerationRepository {
  final FlashcardGenerationService _service;

  FlashcardGenerationRepositoryImpl(this._service);

  @override
  Future<List<FlashcardContent>?> generateFromCamera() async {
    return await _service.generateFromCamera();
  }

  @override
  Future<List<FlashcardContent>?> generateFromGallery() async {
    return await _service.generateFromGallery();
  }

  @override
  Future<List<FlashcardContent>?> generateFromFile() async {
    return await _service.generateFromFile();
  }
}