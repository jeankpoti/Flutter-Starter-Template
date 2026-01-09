import 'package:firebase_ai/firebase_ai.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import '../../domain/respository/solve_math_repo.dart';
import '../../domain/models/math_solution.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import 'prompt_localizer.dart';
import '../../../../core/services/ad_config_service.dart';

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

  // Initialize the model
  Future<void> initialize() async {
    if (!_isInitialized) {
      try {
        // Fetch model name from Remote Config (god-mode controlled)
        final modelName = AdConfigService.getMathModelName();

        // Use the configured model (default: gemini-2.5-flash-lite)
        _model = FirebaseAI.googleAI().generativeModel(model: modelName);

        _isInitialized = true;
      } catch (e) {
        rethrow;
      }
    }
  }

  // Check if the service is initialized
  bool get isInitialized => _isInitialized;

  // Method to reinitialize when settings change
  Future<void> reinitialize() async {
    _isInitialized = false;
    await initialize();
  }

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

  // Generate content with image and custom prompt
  Future<GenerateContentResponse> generateContentWithImage(
    String prompt,
    Uint8List imageBytes, {
    String mimeType = 'image/jpeg',
  }) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    // Create the image part with the bytes
    final imagePart = InlineDataPart(mimeType, imageBytes);
    final promptPart = TextPart(prompt);

    // Create content with both text and image
    final content = [
      Content.multi([promptPart, imagePart]),
    ];

    return await _model!.generateContent(content);
  }

  // Method to solve math problems from text input
  @override
  Future<MathSolution> solveMathWithText(String textInput) async {
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

      final prompt = _buildAgeAppropriatePrompt(
        textInput.trim(),
        mathLevel,
        locale,
      );

      // Solve using text prompt
      final response = await generateTextContent(prompt);
      final images = _extractImages(response);

      return MathSolution(
        text: response.text ?? 'Unable to solve the math problem',
        images: images,
      );
    } catch (e) {
      return MathSolution(
        text: 'Error: Failed to solve the math problem. Please try again.',
        images: [],
      );
    }
  }

  // Method to extract images from Gemini response
  List<Uint8List> _extractImages(GenerateContentResponse response) {
    final images = <Uint8List>[];

    for (final candidate in response.candidates) {
      if (candidate.content.parts.isNotEmpty) {
        for (final part in candidate.content.parts) {
          if (part is InlineDataPart) {
            images.add(part.bytes);
          }
        }
      }
    }

    return images;
  }

  String _buildAgeAppropriatePrompt(
    String mathProblem,
    MathLevel level,
    String locale,
  ) {
    final context = level.toPromptContext();
    return PromptLocalizer.getMathSolvingPrompt(
      locale,
      mathProblem,
      context,
      level.displayName,
    );
  }

  String _buildImagePrompt(MathLevel level, String locale) {
    final context = level.toPromptContext();
    return PromptLocalizer.getImageAnalysisPrompt(
      locale,
      context,
      level.displayName,
    );
  }

  // Method to solve math from image
  @override
  Future<MathSolution> solveMath(dynamic imageInput) async {
    if (!_isInitialized || _model == null) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    try {
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

      final promptText = _buildImagePrompt(mathLevel, locale);

      // Create the image part with the bytes
      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final prompt = TextPart(promptText);

      // Create a content item with the image
      final content = [
        Content.multi([prompt, imagePart]),
      ];

      // Generate content with model
      final response = await _model!.generateContent(content);
      final images = _extractImages(response);

      return MathSolution(
        text: response.text ?? 'Unable to solve the math problem',
        images: images,
      );
    } catch (e) {
      return MathSolution(
        text:
            'Error: Failed to solve the math problem. Please try again with a clearer image.',
        images: [],
      );
    }
  }
}
