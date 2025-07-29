import 'package:firebase_ai/firebase_ai.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import '../../domain/respository/solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import 'prompt_localizer.dart';

class GeminiSolveMathRepo implements SolveMathRepo {
  static final GeminiSolveMathRepo _instance = GeminiSolveMathRepo._internal();
  GenerativeModel? _model;
  bool _isInitialized = false;

  // Factory constructor to return the same instance every time
  factory GeminiSolveMathRepo() {
    return _instance;
  }

  // Private constructor
  GeminiSolveMathRepo._internal();

  // Initialize the service
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        _model = FirebaseAI.googleAI().generativeModel(
          model: 'gemini-2.5-flash-lite',
        );
        _isInitialized = true;
      } catch (e) {
        print('Failed to initialize Gemini service: $e');
        rethrow;
      }
    }
  }

  // Check if the service is initialized
  bool get isInitialized => _isInitialized;

  // Generate content from text prompt
  Future<GenerateContentResponse> generateTextContent(String prompt) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    final contentItems = [Content.text(prompt)];
    return await _model!.generateContent(contentItems);
  }

  // Method to solve math problems from text input
  @override
  Future<String> solveMathWithText(String textInput) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    try {
      // Get user's math level preference and locale
      final prefs = await PreferencesService.getInstance();
      final mathLevel = prefs.getMathLevel();
      final locale = prefs.getLocale();

      final prompt = _buildAgeAppropriatePrompt(textInput.trim(), mathLevel, locale);

      final response = await generateTextContent(prompt);
      return response.text ?? 'Unable to solve the math problem';
    } catch (e) {
      print('Error solving math problem: $e');
      return 'Error: Failed to solve the math problem. Please try again.';
    }
  }

  String _buildAgeAppropriatePrompt(String mathProblem, MathLevel level, String locale) {
    return PromptLocalizer.getMathSolvingPrompt(
      locale,
      mathProblem,
      level.toPromptContext(),
      level.displayName,
    );
  }

  String _buildImagePrompt(MathLevel level, String locale) {
    return PromptLocalizer.getImageAnalysisPrompt(
      locale,
      level.toPromptContext(),
      level.displayName,
    );
  }

  // Method to solve math from image
  @override
  Future<String> solveMath(dynamic imageInput) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    try {
      // print('Identifying : ${imageFile.runtimeType}');
      // final image = await File(imageFile).readAsBytes();
      // print('Identifying 2 : ${image.runtimeType}');
      // Handle different types of input
      Uint8List imageBytes;

      if (imageInput is File) {
        // Handle File input
        imageBytes = await imageInput.readAsBytes();
      } else if (imageInput is Uint8List) {
        // Handle direct byte array input
        imageBytes = imageInput;
      } else if (imageInput is List<int>) {
        // Handle regular List<int>
        imageBytes = Uint8List.fromList(imageInput);
      } else {
        throw ArgumentError(
          'Unsupported image input type: ${imageInput.runtimeType}',
        );
      }

      // Get user's math level preference and locale for image solving
      final prefs = await PreferencesService.getInstance();
      final mathLevel = prefs.getMathLevel();
      final locale = prefs.getLocale();

      // Create the image part with the bytes
      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final prompt = TextPart(_buildImagePrompt(mathLevel, locale));

      // Convert file to bytes first
      // final imageBytes = await imageFile!.readAsBytes(); I
      // Create a content item with the image
      final content = [
        Content.multi([prompt, imagePart]),
      ];

      // Generate content
      final response = await _model!.generateContent(content);
      return response.text ?? 'Unable to solve the math problem';
    } catch (e) {
      print('Error solving math problem: $e');
      return 'Error: Failed to solve the math problem. Please try again with a clearer image.';
    }
  }
}
