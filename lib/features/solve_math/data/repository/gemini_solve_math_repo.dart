import 'package:firebase_ai/firebase_ai.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import '../../domain/respository/solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';

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
      // Get user's math level preference
      final prefs = await PreferencesService.getInstance();
      final mathLevel = prefs.getMathLevel();

      final prompt = _buildAgeAppropriatePrompt(textInput.trim(), mathLevel);

      final response = await generateTextContent(prompt);
      return response.text ?? 'Unable to solve the math problem';
    } catch (e) {
      print('Error solving math problem: $e');
      return 'Error: Failed to solve the math problem. Please try again.';
    }
  }

  String _buildAgeAppropriatePrompt(String mathProblem, MathLevel level) {
    final basePrompt =
        '''You are a math tutor AI. Solve this math problem and provide a complete solution.

Problem: $mathProblem

Please follow this format:
1. **Problem**: Restate the math problem clearly
2. **Solution Steps**: Show detailed step-by-step solution
3. **Final Answer**: Use the format "The final answer is \$\\boxed{answer}\$"

${level.toPromptContext()}

Requirements:
- Show ALL working steps clearly
- Use LaTeX math notation inside \$ symbols (e.g., \$x^2 + 1\$, \$\\frac{1}{2}\$)
- For final answers, always use \$\\boxed{answer}\$ format
- For word problems, identify given information first
- Double-check your calculations

Examples of proper formatting:
- Simple: The final answer is \$\\boxed{42}\$
- Fraction: The final answer is \$\\boxed{\\frac{3}{4}}\$
- Expression: The final answer is \$\\boxed{2x + 5}\$

Make the explanation appropriate for ${level.displayName} level students.''';

    return basePrompt;
  }

  String _buildImagePrompt(MathLevel level) {
    return '''You are a math tutor AI. Analyze this image containing a math problem and provide a complete solution.

Please follow this format:
1. **Problem**: State what math problem you see
2. **Solution Steps**: Show detailed step-by-step solution
3. **Final Answer**: Use the format "The final answer is \$\\boxed{answer}\$"

${level.toPromptContext()}

Requirements:
- Show ALL working steps clearly
- Use LaTeX math notation inside \$ symbols (e.g., \$x^2 + 1\$, \$\\frac{1}{2}\$)
- For final answers, always use \$\\boxed{answer}\$ format
- If the image is unclear, ask for a clearer photo
- If no math problem is visible, politely explain what you see instead
- For word problems, identify given information first
- Double-check your calculations

Examples of proper formatting:
- Simple: The final answer is \$\\boxed{42}\$
- Fraction: The final answer is \$\\boxed{\\frac{3}{4}}\$
- Expression: The final answer is \$\\boxed{2x + 5}\$

Make the explanation appropriate for ${level.displayName} level students.''';
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

      // Get user's math level preference for image solving too
      final prefs = await PreferencesService.getInstance();
      final mathLevel = prefs.getMathLevel();

      // Create the image part with the bytes
      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final prompt = TextPart(_buildImagePrompt(mathLevel));

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
