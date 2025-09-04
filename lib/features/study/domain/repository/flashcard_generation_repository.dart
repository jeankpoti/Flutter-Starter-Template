import '../../data/services/flashcard_generation_service.dart';

/// Repository interface for flashcard generation
abstract class FlashcardGenerationRepository {
  /// Generate multiple flashcards from camera capture
  Future<List<FlashcardContent>?> generateFromCamera();
  
  /// Generate multiple flashcards from gallery image
  Future<List<FlashcardContent>?> generateFromGallery();
  
  /// Generate flashcards from file content
  Future<List<FlashcardContent>?> generateFromFile();
}