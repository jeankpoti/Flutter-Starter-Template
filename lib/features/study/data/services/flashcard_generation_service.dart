import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../../../solve_math/data/services/image_capture_service.dart';

/// Service for generating flashcards from various sources
class FlashcardGenerationService {
  final ImageCaptureService _imageCaptureService;
  final GenerativeModel _model;
  
  // 10MB file size limit as per CLAUDE.md guidelines
  static const maxFileSizeBytes = 10 * 1024 * 1024; // 10MB

  FlashcardGenerationService({
    ImageCaptureService? imageCaptureService,
  }) : _imageCaptureService = imageCaptureService ?? ImageCaptureService(),
       _model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash-lite');

  /// Capture image from camera and generate multiple flashcard content
  Future<List<FlashcardContent>?> generateFromCamera() async {
    try {
      final File? imageFile = await _imageCaptureService.captureFromCamera();
      if (imageFile == null) return null;

      return await _generateFlashcardsFromImage(imageFile);
    } catch (e) {
      throw FlashcardGenerationException('Failed to generate flashcards from camera: $e');
    }
  }

  /// Select image from gallery and generate multiple flashcard content
  Future<List<FlashcardContent>?> generateFromGallery() async {
    try {
      final File? imageFile = await _imageCaptureService.selectFromGallery();
      if (imageFile == null) return null;

      return await _generateFlashcardsFromImage(imageFile);
    } catch (e) {
      throw FlashcardGenerationException('Failed to generate flashcards from gallery: $e');
    }
  }

  /// Select file and generate flashcard content
  Future<List<FlashcardContent>?> generateFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final PlatformFile platformFile = result.files.first;
      if (platformFile.path == null) {
        throw FlashcardGenerationException('Selected file path is invalid');
      }

      // Validate file size before processing
      if (platformFile.size > maxFileSizeBytes) {
        final fileSizeMB = platformFile.size / (1024 * 1024);
        throw FileSizeException(
          'File size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of ${maxFileSizeBytes ~/ (1024 * 1024)}MB'
        );
      }

      final File file = File(platformFile.path!);
      return await _generateFlashcardsFromFile(file);
    } catch (e) {
      if (e is FileSizeException) {
        rethrow; // Re-throw file size exceptions as-is
      }
      throw FlashcardGenerationException('Failed to generate flashcard from file: $e');
    }
  }

  /// Validate file size against 10MB limit
  Future<void> _validateFileSize(File file) async {
    final fileSize = await file.length();
    if (fileSize > maxFileSizeBytes) {
      final fileSizeMB = fileSize / (1024 * 1024);
      throw FileSizeException(
        'File size (${fileSizeMB.toStringAsFixed(1)}MB) exceeds the maximum allowed size of ${maxFileSizeBytes ~/ (1024 * 1024)}MB'
      );
    }
  }

  /// Generate multiple flashcards from image using AI (optimized for math content)
  Future<List<FlashcardContent>> _generateFlashcardsFromImage(File imageFile) async {
    try {
      // Validate file size before processing
      await _validateFileSize(imageFile);
      
      final imageBytes = await imageFile.readAsBytes();
      
      const String prompt = '''
      Analyze this image and create multiple comprehensive flashcards based on the content. 
      Focus on math concepts, problems, formulas, theorems, and step-by-step solutions.
      
      Generate 4-6 flashcards that cover:
      1. Main concept/theorem identification
      2. Formula or equation recognition
      3. Step-by-step problem solving
      4. Key terminology and definitions
      5. Common mistakes or important notes
      6. Practice variations or related concepts
      
      Return your response as a JSON array in the following format:
      [
        {
          "question": "What is the main mathematical concept shown in this image?",
          "answer": "Detailed explanation of the concept",
          "hint": "A helpful hint to remember the concept",
          "tags": ["concept", "theorem", "algebra"]
        },
        {
          "question": "What is the formula/equation presented?",
          "answer": "The exact formula with explanation",
          "hint": "Memory aid or pattern to remember",
          "tags": ["formula", "equation", "algebra"]
        },
        {
          "question": "How do you solve this step by step?",
          "answer": "Detailed step-by-step solution process",
          "hint": "Key strategy or approach to use",
          "tags": ["problem-solving", "steps", "method"]
        },
        {
          "question": "What does [key term] mean?",
          "answer": "Clear definition of the mathematical term",
          "hint": "Context or example to remember",
          "tags": ["definition", "terminology", "vocabulary"]
        }
      ]
      
      Make sure each flashcard:
      - Tests a different aspect of the mathematical content
      - Has clear, specific questions
      - Provides complete, accurate answers
      - Includes helpful hints for memory
      - Uses relevant mathematical tags
      - Progresses from basic recognition to application
      ''';

      // Add timeout to prevent infinite loading
      final response = await _model.generateContent([
        Content.multi([
          TextPart(prompt),
          InlineDataPart('image/jpeg', imageBytes),
        ])
      ]).timeout(
        const Duration(seconds: 90), // Longer timeout for multiple cards
        onTimeout: () => throw FlashcardGenerationException('AI generation timed out. Please try again.'),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw FlashcardGenerationException('No response from AI model');
      }

      return _parseMultipleFlashcardContent(response.text!);
    } finally {
      // Clean up the temporary file (fire and forget to avoid blocking)
      _imageCaptureService.deleteImage(imageFile).catchError((e) {
        // Ignore cleanup errors to prevent widget disposal issues
      });
    }
  }

  /// Generate flashcard content from file using AI
  Future<List<FlashcardContent>> _generateFlashcardsFromFile(File file) async {
    try {
      // Validate file size before processing
      await _validateFileSize(file);
      
      // Read file content with timeout to prevent hanging
      final String fileContent = await file.readAsString().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw FlashcardGenerationException('File reading timed out'),
      );
      
      if (fileContent.isEmpty) {
        throw FlashcardGenerationException('File appears to be empty or unreadable');
      }
      
      const String prompt = '''
      Analyze this document content and create comprehensive flashcards for studying math concepts.
      Generate 5-8 flashcards that thoroughly cover the mathematical content.
      
      Focus on creating flashcards for:
      1. Mathematical definitions and terminology
      2. Formulas, equations, and theorems
      3. Problem-solving methods and procedures
      4. Key properties and characteristics
      5. Common applications and examples
      6. Important notes, tips, or common mistakes
      7. Related concepts and connections
      8. Practice problems or variations
      
      Return your response as a JSON array in the following format:
      [
        {
          "question": "What is [mathematical concept] and how is it defined?",
          "answer": "Complete definition with mathematical notation if applicable",
          "hint": "Memory aid or key characteristic to remember",
          "tags": ["definition", "concept", "specific-topic"]
        },
        {
          "question": "What is the formula for [specific calculation]?",
          "answer": "Exact formula with variable explanations",
          "hint": "When and how to apply this formula",
          "tags": ["formula", "calculation", "specific-topic"]
        },
        {
          "question": "How do you solve [type of problem]?",
          "answer": "Step-by-step method with clear procedures",
          "hint": "Key strategy or first step to remember",
          "tags": ["problem-solving", "method", "procedure"]
        }
      ]
      
      Make sure each flashcard:
      - Tests deep understanding, not just memorization
      - Uses proper mathematical terminology
      - Provides complete, accurate information
      - Includes helpful memory aids
      - Uses specific, relevant tags
      - Builds from basic concepts to applications
      ''';

      // Add timeout to prevent infinite loading (longer for comprehensive generation)
      final response = await _model.generateContent([
        Content.text('$prompt\n\nDocument content:\n$fileContent')
      ]).timeout(
        const Duration(seconds: 120), // Extended timeout for comprehensive flashcards
        onTimeout: () => throw FlashcardGenerationException('AI generation timed out. Please try again.'),
      );

      if (response.text == null || response.text!.isEmpty) {
        throw FlashcardGenerationException('No response from AI model');
      }

      return _parseMultipleFlashcardContent(response.text!);
    } catch (e) {
      throw FlashcardGenerationException('Failed to process file content: $e');
    }
  }

  /// Parse single flashcard content from AI response
  FlashcardContent _parseFlashcardContent(String response) {
    try {
      // Extract JSON from response (AI might include extra text)
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw FlashcardGenerationException('Invalid response format from AI');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final Map<String, dynamic> data = jsonDecode(jsonString);

      return FlashcardContent(
        question: data['question']?.toString() ?? 'Generated Question',
        answer: data['answer']?.toString() ?? 'Generated Answer',
        hint: data['hint']?.toString(),
        tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      );
    } catch (e) {
      // Fallback: create basic flashcard from response
      return FlashcardContent(
        question: 'What is the main concept in this content?',
        answer: response.length > 200 ? '${response.substring(0, 200)}...' : response,
        hint: null,
        tags: ['AI Generated'],
      );
    }
  }

  /// Parse multiple flashcard content from AI response
  List<FlashcardContent> _parseMultipleFlashcardContent(String response) {
    try {
      // Extract JSON array from response
      final jsonStart = response.indexOf('[');
      final jsonEnd = response.lastIndexOf(']') + 1;
      
      if (jsonStart == -1 || jsonEnd <= jsonStart) {
        throw FlashcardGenerationException('Invalid response format from AI');
      }

      final jsonString = response.substring(jsonStart, jsonEnd);
      final List<dynamic> dataList = jsonDecode(jsonString);

      return dataList.map((data) => FlashcardContent(
        question: data['question']?.toString() ?? 'Generated Question',
        answer: data['answer']?.toString() ?? 'Generated Answer',
        hint: data['hint']?.toString(),
        tags: (data['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      )).toList();
    } catch (e) {
      // Fallback: create single flashcard from response
      return [
        FlashcardContent(
          question: 'What are the main concepts in this document?',
          answer: response.length > 200 ? '${response.substring(0, 200)}...' : response,
          hint: null,
          tags: ['AI Generated', 'Document'],
        )
      ];
    }
  }
}

/// Data class for flashcard content
class FlashcardContent {
  final String question;
  final String answer;
  final String? hint;
  final List<String> tags;

  const FlashcardContent({
    required this.question,
    required this.answer,
    this.hint,
    required this.tags,
  });
}

/// Custom exception for flashcard generation errors
class FlashcardGenerationException implements Exception {
  final String message;
  
  FlashcardGenerationException(this.message);
  
  @override
  String toString() => 'FlashcardGenerationException: $message';
}

/// Custom exception for file size validation errors
class FileSizeException implements Exception {
  final String message;
  
  FileSizeException(this.message);
  
  @override
  String toString() => 'FileSizeException: $message';
}