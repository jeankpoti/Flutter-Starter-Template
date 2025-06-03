import 'package:firebase_ai/firebase_ai.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

import '../../domain/respository/solve_math_repo.dart';

class GeminiSolveMathRepo implements SolveMathRepo {
  static final GeminiSolveMathRepo _instance = GeminiSolveMathRepo._internal();
  late final GenerativeModel _model;
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
          model: 'gemini-2.0-flash',
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
    if (!_isInitialized) {
      throw Exception(
        'GeminiService not initialized. Call initialize() first.',
      );
    }

    final contentItems = [Content.text(prompt)];
    return await _model.generateContent(contentItems);
  }

  // Method to identify animals from an image
  @override
  Future<String> solveMath(dynamic imageInput) async {
    if (!_isInitialized) {
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

      // Create the image part with the bytes

      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final prompt = TextPart(
        '''What animal is this? Provide a detailed description including danger, species, 
      habitat, interesting facts and fun facts. 

      Please provide the information in a clear, concise manner and medium length.

      Tell the user if the image is not clear enough to identify the animal.
      If the image is not an animal, please let the user know and never let the user know what is in the image if it is not an animal.

      Just tell user this is not an animal if the image is not an animal.
        ''',
      );

      // Convert file to bytes first
      // final imageBytes = await imageFile!.readAsBytes(); I
      // Create a content item with the image
      final content = [
        Content.multi([prompt, imagePart]),
      ];

      // Generate content
      final response = await _model.generateContent(content);
      return response.text ?? 'Unable to identify the animal';
    } catch (e) {
      print('Error identifying animal: $e');
      return 'Error: Failed to identify the animal';
    }
  }
}
