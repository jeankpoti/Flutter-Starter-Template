import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/foundation.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import '../../../solve_math/data/repository/prompt_localizer.dart';
import '../../domain/models/study_material.dart';
import '../../domain/models/study_plan.dart';

class StudyPlanService {
  static final StudyPlanService _instance = StudyPlanService._internal();

  // Use lite model directly for study plan analysis (no image generation needed)
  GenerativeModel? _liteModel;
  final Random _random = Random();
  bool _isInitialized = false;

  factory StudyPlanService() {
    return _instance;
  }

  StudyPlanService._internal();

  Future<void> initialize() async {
    if (!_isInitialized) {
      // Study plan analysis only needs text, use cost-effective lite model
      _liteModel = FirebaseAI.googleAI().generativeModel(
        model: 'gemini-2.5-flash-lite',
      );
      _isInitialized = true;
    }
  }

  /// Analyze uploaded material and extract topics, concepts, and difficulty
  Future<StudyMaterial> analyzeMaterial({
    required String materialId,
    required MaterialType type,
    String? content,
    File? imageFile,
    Uint8List? documentBytes,
    required String title,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();
    final locale = prefs.getLocale();

    String aiAnalysis = '';
    List<String> extractedTopics = [];

    try {
      if (type == MaterialType.text && content != null) {
        aiAnalysis = await _analyzeTextContent(content, mathLevel, locale);
      } else if (type == MaterialType.image && imageFile != null) {
        aiAnalysis = await _analyzeImageContent(imageFile, mathLevel, locale);
      } else if (type == MaterialType.document && documentBytes != null) {
        aiAnalysis = await _analyzeDocumentContent(
          documentBytes,
          mathLevel,
          locale,
        );
      }

      // Extract topics from AI analysis
      extractedTopics = _extractTopicsFromAnalysis(aiAnalysis);
    } catch (e) {
      // Handle error silently

      // Check if it's a non-math content error and re-throw it
      if (e.toString().contains('does not contain mathematical material') ||
          e.toString().contains('ne contient pas de matériel mathématique') ||
          e.toString().contains('no contiene material matemático')) {
        rethrow; // Re-throw to let the calling code handle it
      }

      // For other errors, set error message but continue
      if (locale == 'fr') {
        aiAnalysis =
            'Erreur lors de l\'analyse du contenu. Veuillez réessayer.';
      } else if (locale == 'es') {
        aiAnalysis = 'Error al analizar contenido. Por favor intenta de nuevo.';
      } else {
        aiAnalysis = 'Error analyzing content. Please try again.';
      }
    }

    return StudyMaterial(
      id: materialId,
      userId: userId,
      title: title,
      type: type,
      status:
          aiAnalysis.contains('Error')
              ? MaterialStatus.failed
              : MaterialStatus.completed,
      content: content,
      imagePath: imageFile?.path,
      extractedTopics: extractedTopics,
      aiAnalysis: aiAnalysis,
      difficultyLevel: mathLevel.displayName,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Generate a comprehensive study plan from analyzed materials
  Future<StudyPlan> generateStudyPlan({
    required List<StudyMaterial> materials,
    String? customTitle,
    DateTime? targetDate,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();
    final locale = prefs.getLocale();

    // Combine all material content and analysis
    final combinedContent = _combineMateriaiContent(materials);

    // Generate study plan using AI
    final studyPlanResponse = await _generateAIStudyPlan(
      combinedContent,
      mathLevel,
      targetDate,
      locale,
    );

    // Parse AI response into structured study plan
    final topics = _parseStudyTopics(studyPlanResponse, locale);
    final totalHours = _calculateTotalHours(topics);

    final studyPlan = StudyPlan(
      id: _generateId(),
      userId: userId,
      title: customTitle ?? _generatePlanTitle(materials, locale),
      description: _getStudyPlanDescription(locale),
      materialIds: materials.map((m) => m.id).toList(),
      topics: topics,
      difficulty: _determineDifficulty(mathLevel),
      totalEstimatedHours: totalHours,
      targetCompletionDate: targetDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      aiRecommendations: _extractRecommendations(studyPlanResponse),
    );

    return studyPlan;
  }

  /// Analyze text content using AI
  Future<String> _analyzeTextContent(
    String content,
    MathLevel mathLevel,
    String locale,
  ) async {
    try {
      // Use a specific prompt for study material analysis that validates math content
      final prompt = PromptLocalizer.getStudyMaterialTextAnalysisPrompt(
        locale,
        content,
        mathLevel.displayName,
      );

      // Use lite model for text analysis (cost-effective)
      final response = await _liteModel!.generateContent([
        Content.text(prompt),
      ]);
      final analysisText = response.text ?? '';

      // AI response received

      // Check if the response indicates no math content
      if (analysisText.contains('NO_MATH_CONTENT:')) {
        // Extract the error message after NO_MATH_CONTENT:
        final errorMessage = analysisText.split('NO_MATH_CONTENT:')[1].trim();
        throw Exception(errorMessage);
      }

      return analysisText;
    } catch (e) {
      // Re-throw if it's already a no-math-content error
      if (e.toString().contains('does not contain mathematical material') ||
          e.toString().contains('ne contient pas de matériel mathématique') ||
          e.toString().contains('no contiene material matemático')) {
        rethrow;
      }

      // Other errors
      if (locale == 'fr') {
        return 'Impossible d\'analyser le contenu : $e';
      } else if (locale == 'es') {
        return 'No se puede analizar el contenido: $e';
      } else {
        return 'Unable to analyze content: $e';
      }
    }
  }

  /// Analyze image content using AI
  Future<String> _analyzeImageContent(
    File imageFile,
    MathLevel mathLevel,
    String locale,
  ) async {
    try {
      // Use a specific prompt for study material analysis that validates math content
      final prompt = PromptLocalizer.getStudyMaterialImageAnalysisPrompt(
        locale,
        mathLevel.toPromptContext(),
        mathLevel.displayName,
      );

      // Read image bytes
      final imageBytes = await imageFile.readAsBytes();

      // Use lite model for image analysis (no diagram generation needed)
      final imagePart = InlineDataPart('image/jpeg', imageBytes);
      final promptPart = TextPart(prompt);
      final response = await _liteModel!.generateContent([
        Content.multi([promptPart, imagePart]),
      ]);

      final analysisText = response.text ?? '';

      // AI response received

      // Check if the response indicates no math content
      if (analysisText.contains('NO_MATH_CONTENT:')) {
        // Extract the error message after NO_MATH_CONTENT:
        final errorMessage = analysisText.split('NO_MATH_CONTENT:')[1].trim();
        throw Exception(errorMessage);
      }

      return analysisText;
    } catch (e) {
      // Re-throw if it's already a no-math-content error
      if (e.toString().contains('does not contain mathematical material') ||
          e.toString().contains('ne contient pas de matériel mathématique') ||
          e.toString().contains('no contiene material matemático')) {
        rethrow;
      }

      // Other errors
      if (locale == 'fr') {
        return 'Impossible d\'analyser le contenu de l\'image : $e';
      } else if (locale == 'es') {
        return 'No se puede analizar el contenido de la imagen: $e';
      } else {
        return 'Unable to analyze image content: $e';
      }
    }
  }

  /// Analyze PDF document content using AI
  Future<String> _analyzeDocumentContent(
    Uint8List documentBytes,
    MathLevel mathLevel,
    String locale,
  ) async {
    try {
      // Use a specific prompt for PDF document analysis that validates math content
      final prompt = PromptLocalizer.getStudyMaterialDocumentAnalysisPrompt(
        locale,
        mathLevel.toPromptContext(),
        mathLevel.displayName,
      );

      // Starting document analysis

      // Use lite model for PDF analysis (no diagram generation needed)
      final documentPart = InlineDataPart('application/pdf', documentBytes);
      final promptPart = TextPart(prompt);
      final response = await _liteModel!.generateContent([
        Content.multi([promptPart, documentPart]),
      ]);

      final analysisText = response.text ?? '';

      // AI response received

      // Check if the response starts with NO_MATH_CONTENT (more strict check)
      if (analysisText.trim().startsWith('NO_MATH_CONTENT:')) {
        // Extract the error message after NO_MATH_CONTENT:
        final errorMessage = analysisText.split('NO_MATH_CONTENT:')[1].trim();
        throw Exception(errorMessage);
      }

      // Check if the response indicates no math content anywhere
      if (analysisText.contains('NO_MATH_CONTENT:')) {
        // Extract the error message after NO_MATH_CONTENT:
        final errorMessage = analysisText.split('NO_MATH_CONTENT:')[1].trim();
        throw Exception(errorMessage);
      }

      // Additional check: If the response mentions HTML, programming, or doesn't start with expected format
      final lowerAnalysis = analysisText.toLowerCase();

      // Check for programming/web development content
      final programmingKeywords = [
        'html',
        'css',
        'javascript',
        'programming',
        'coding',
        'web development',
        'website',
        'frontend',
        'backend',
        'python',
        'java',
        'c++',
        'react',
        'angular',
        'vue',
        'database',
        'sql',
        'api',
        'framework',
        'software development',
      ];

      // Count how many programming keywords are found
      int programmingKeywordCount = 0;
      for (final keyword in programmingKeywords) {
        if (lowerAnalysis.contains(keyword)) {
          programmingKeywordCount++;
        }
      }

      // If we find multiple programming keywords and no math keywords, it's likely not math content
      final mathKeywords = [
        'equation',
        'theorem',
        'proof',
        'derivative',
        'integral',
        'algebra',
        'geometry',
        'calculus',
        'trigonometry',
        'statistics',
        'mathematical',
        'formula',
        'function',
        'graph',
        'polynomial',
      ];

      int mathKeywordCount = 0;
      for (final keyword in mathKeywords) {
        if (lowerAnalysis.contains(keyword)) {
          mathKeywordCount++;
        }
      }

      // Keyword analysis completed

      if (programmingKeywordCount >= 3 && mathKeywordCount < 2) {
        throw Exception(
          'This document does not contain mathematical material. Please upload a PDF with math problems, equations, or mathematical concepts.',
        );
      }

      // Check if response doesn't contain expected math analysis sections
      if (!analysisText.contains('DOCUMENT OVERVIEW:') &&
          !analysisText.contains('TOPICS COVERED:') &&
          !analysisText.contains('APERÇU DU DOCUMENT:') &&
          !analysisText.contains('SUJETS COUVERTS:') &&
          !analysisText.contains('RESUMEN DEL DOCUMENTO:') &&
          !analysisText.contains('TEMAS CUBIERTOS:')) {
        throw Exception(
          'This document does not contain mathematical material. Please upload a PDF with math problems, equations, or mathematical concepts.',
        );
      }

      return analysisText;
    } catch (e) {
      // Error handling

      // Re-throw if it's already a no-math-content error
      if (e.toString().contains('does not contain mathematical material') ||
          e.toString().contains('ne contient pas de matériel mathématique') ||
          e.toString().contains('no contiene material matemático')) {
        rethrow;
      }

      // Other errors
      if (locale == 'fr') {
        return 'Impossible d\'analyser le contenu du document : $e';
      } else if (locale == 'es') {
        return 'No se puede analizar el contenido del documento: $e';
      } else {
        return 'Unable to analyze document content: $e';
      }
    }
  }

  /// Generate AI study plan from combined materials
  Future<String> _generateAIStudyPlan(
    String combinedContent,
    MathLevel mathLevel,
    DateTime? targetDate,
    String locale,
  ) async {
    final targetInfo =
        targetDate != null
            ? _getTargetDateText(targetDate, locale)
            : _getNoTargetDateText(locale);

    String prompt = '';

    if (locale == 'en') {
      prompt = '''
You are an expert math tutor creating a personalized study plan. Based on the analyzed materials below, create a comprehensive study plan.

ANALYZED MATERIALS:
$combinedContent

STUDENT LEVEL: ${mathLevel.displayName}
$targetInfo

Create a study plan in this EXACT format:

**STUDY PLAN OVERVIEW:**
[Brief description of what this plan covers]

**TOPIC 1: [Topic Name]**
- Description: [What this topic covers]
- Key Concepts: [Concept 1], [Concept 2], [Concept 3]
- Estimated Time: [X] minutes
- Prerequisites: [None or list of prerequisite topics]
- Practice Problems: [Suggest 3-5 specific types of problems]

**TOPIC 2: [Topic Name]**
- Description: [What this topic covers]
- Key Concepts: [Concept 1], [Concept 2], [Concept 3]
- Estimated Time: [X] minutes
- Prerequisites: [Topic 1 or other prerequisites]
- Practice Problems: [Suggest 3-5 specific types of problems]

[Continue for 3-8 topics total based on content complexity]

**STUDY RECOMMENDATIONS:**
- [Recommendation 1]
- [Recommendation 2]
- [Recommendation 3]

**TOTAL ESTIMATED TIME:** [X] hours

Make this appropriate for ${mathLevel.displayName} level students with clear progression from basic to advanced concepts.
''';
    } else if (locale == 'fr') {
      prompt =
          '''  Vous êtes un tuteur de mathématiques expert créant un plan d'étude personnalisé. Basé sur les matériaux analysés ci-dessous, créez un plan d'étude complet.

  MATÉRIAUX ANALYSÉS :
  $combinedContent

  NIVEAU ÉTUDIANT : ${mathLevel.displayName}
  $targetInfo

  Créez un plan d'étude dans ce format EXACT :

  **APERÇU DU PLAN D'ÉTUDE :**
  [Brève description de ce que ce plan couvre]

  **SUJET 1 : [Nom du sujet]**
  - Description : [Ce que ce sujet couvre]
  - Concepts clés : [Concept 1], [Concept 2], [Concept 3]
  - Temps estimé : [X] minutes
  - Prérequis : [Aucun ou liste des sujets prérequis]
  - Problèmes de pratique : [Suggérer 3-5 types spécifiques de problèmes]

  **SUJET 2 : [Nom du sujet]**
  - Description : [Ce que ce sujet couvre]
  - Concepts clés : [Concept 1], [Concept 2], [Concept 3]
  - Temps estimé : [X] minutes
  - Prérequis : [Sujet 1 ou autres prérequis]
  - Problèmes de pratique : [Suggérer 3-5 types spécifiques de problèmes]

  [Continuez pour 3-8 sujets au total basés sur la complexité du contenu]

  **RECOMMANDATIONS D'ÉTUDE :**
  - [Recommandation 1]
  - [Recommandation 2]
  - [Recommandation 3]

  **TEMPS TOTAL ESTIMÉ :** [X] heures

  Rendez ceci approprié pour les étudiants de niveau ${mathLevel.displayName} avec une progression claire des concepts de base aux concepts avancés.
  
  ''';
    } else if (locale == 'es') {
      prompt = '''
Eres un tutor de matemáticas experto creando un plan de estudio personalizado. Basado en los materiales analizados a continuación, crea un plan de estudio integral.

MATERIALES ANALIZADOS:
$combinedContent

NIVEL DEL ESTUDIANTE: ${mathLevel.displayName}
$targetInfo

Crea un plan de estudio en este formato EXACTO:

**RESUMEN DEL PLAN DE ESTUDIO:**
[Breve descripción de lo que cubre este plan]

**TEMA 1: [Nombre del tema]**
- Descripción: [Lo que cubre este tema]
- Conceptos clave: [Concepto 1], [Concepto 2], [Concepto 3]
- Tiempo estimado: [X] minutos
- Prerrequisitos: [Ninguno o lista de temas prerrequisito]
- Problemas de práctica: [Sugerir 3-5 tipos específicos de problemas]

**TEMA 2: [Nombre del tema]**
- Descripción: [Lo que cubre este tema]
- Conceptos clave: [Concepto 1], [Concepto 2], [Concepto 3]
- Tiempo estimado: [X] minutos
- Prerrequisitos: [Tema 1 u otros prerrequisitos]
- Problemas de práctica: [Sugerir 3-5 tipos específicos de problemas]

[Continúa para 3-8 temas totales basados en la complejidad del contenido]

**RECOMENDACIONES DE ESTUDIO:**
- [Recomendación 1]
- [Recomendación 2]
- [Recomendación 3]

**TIEMPO TOTAL ESTIMADO:** [X] horas

Haz esto apropiado para estudiantes de nivel ${mathLevel.displayName} con progresión clara de conceptos básicos a avanzados.
''';
    }

    final response = await _liteModel!.generateContent([Content.text(prompt)]);
    if (locale == 'fr') {
      return response.text ?? 'Impossible de générer le plan d\'étude';
    } else if (locale == 'es') {
      return response.text ?? 'No se puede generar el plan de estudio';
    } else {
      return response.text ?? 'Unable to generate study plan';
    }
  }

  // Helper methods for parsing and processing

  List<String> _extractTopicsFromAnalysis(String analysis) {
    final topics = <String>[];
    final lines = analysis.split('\n');

    bool inTopicsSection = false;
    for (final line in lines) {
      if (line.contains('MAIN TOPICS:') ||
          line.contains('TOPICS:') ||
          line.contains('SUJETS PRINCIPAUX:') ||
          line.contains('SUJETS:') ||
          line.contains('TEMAS PRINCIPALES:') ||
          line.contains('TEMAS:')) {
        inTopicsSection = true;
        continue;
      }

      if (inTopicsSection) {
        if (line.startsWith('**') &&
            !line.contains('TOPICS') &&
            !line.contains('SUJETS') &&
            !line.contains('TEMAS')) {
          break; // End of topics section
        }

        if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
          final topic = line.replaceAll(RegExp(r'^[-•]\s*'), '').trim();
          if (topic.isNotEmpty) {
            topics.add(topic);
          }
        }
      }
    }

    return topics;
  }

  String _combineMateriaiContent(List<StudyMaterial> materials) {
    final buffer = StringBuffer();

    for (int i = 0; i < materials.length; i++) {
      final material = materials[i];
      buffer.writeln('MATERIAL ${i + 1}: ${material.title}');
      buffer.writeln('Type: ${material.type.name}');

      if (material.content != null) {
        buffer.writeln('Content: ${material.content}');
      }

      if (material.aiAnalysis != null) {
        buffer.writeln('AI Analysis: ${material.aiAnalysis}');
      }

      buffer.writeln('Topics: ${material.extractedTopics.join(", ")}');
      buffer.writeln('---');
    }

    return buffer.toString();
  }

  List<StudyTopic> _parseStudyTopics(String studyPlanResponse, String locale) {
    final topics = <StudyTopic>[];
    final lines = studyPlanResponse.split('\n');

    String currentTopicTitle = '';
    String description = '';
    List<String> keyConcepts = [];
    int estimatedMinutes = 30;
    List<String> prerequisites = [];
    List<String> practiceProblems = [];

    for (final line in lines) {
      final trimmedLine = line.trim();

      // Check for topic header (English, French, or Spanish)
      if ((trimmedLine.startsWith('**TOPIC ') ||
              trimmedLine.startsWith('**SUJET ') ||
              trimmedLine.startsWith('**TEMA ')) &&
          trimmedLine.contains(':')) {
        // Save previous topic if exists
        if (currentTopicTitle.isNotEmpty) {
          // Generate fallback practice problems if none were parsed
          if (practiceProblems.isEmpty) {
            practiceProblems = _generateFallbackPracticeProblems(
              currentTopicTitle,
              keyConcepts,
              locale,
            );
          }

          final topic = StudyTopic(
            id: _generateId(),
            title: currentTopicTitle,
            description: description,
            keyConceptsList: keyConcepts,
            estimatedMinutes: estimatedMinutes,
            status: StudyTopicStatus.notStarted,
            prerequisites: prerequisites,
            aiExplanation: description, // Use description as AI explanation
            practiceProblems: practiceProblems,
          );
          topics.add(topic);
        }

        // Start new topic
        currentTopicTitle = trimmedLine
            .replaceAll(RegExp(r'\*\*TOPIC \d+:\s*'), '')
            .replaceAll(RegExp(r'\*\*SUJET \d+:\s*'), '')
            .replaceAll(RegExp(r'\*\*TEMA \d+:\s*'), '')
            .replaceAll(RegExp(r'\*\*TOPIC \d+ :\s*'), '')
            .replaceAll(RegExp(r'\*\*SUJET \d+ :\s*'), '')
            .replaceAll(RegExp(r'\*\*TEMA \d+ :\s*'), '')
            .replaceAll('**', '');
        description = '';
        keyConcepts = [];
        estimatedMinutes = 30;
        prerequisites = [];
        practiceProblems = [];
      } else if (trimmedLine.startsWith('- Description:') ||
          trimmedLine.startsWith('- Description :') ||
          trimmedLine.startsWith('- Descripción:') ||
          trimmedLine.startsWith('- Descripción :')) {
        description =
            trimmedLine
                .replaceAll('- Description:', '')
                .replaceAll('- Description :', '')
                .replaceAll('- Descripción:', '')
                .replaceAll('- Descripción :', '')
                .trim();
      } else if (trimmedLine.startsWith('- Key Concepts:') ||
          trimmedLine.startsWith('- Concepts clés:') ||
          trimmedLine.startsWith('- Concepts clés :') ||
          trimmedLine.startsWith('- Conceptos clave:') ||
          trimmedLine.startsWith('- Conceptos clave :')) {
        final conceptsText =
            trimmedLine
                .replaceAll('- Key Concepts:', '')
                .replaceAll('- Concepts clés:', '')
                .replaceAll('- Concepts clés :', '')
                .replaceAll('- Conceptos clave:', '')
                .replaceAll('- Conceptos clave :', '')
                .trim();
        keyConcepts =
            conceptsText
                .split(',')
                .map((c) => c.trim())
                .where((c) => c.isNotEmpty)
                .toList();
      } else if (trimmedLine.startsWith('- Estimated Time:') ||
          trimmedLine.startsWith('- Temps estimé:') ||
          trimmedLine.startsWith('- Temps estimé :') ||
          trimmedLine.startsWith('- Tiempo estimado:') ||
          trimmedLine.startsWith('- Tiempo estimado :')) {
        final timeText =
            trimmedLine
                .replaceAll('- Estimated Time:', '')
                .replaceAll('- Temps estimé:', '')
                .replaceAll('- Temps estimé :', '')
                .replaceAll('- Tiempo estimado:', '')
                .replaceAll('- Tiempo estimado :', '')
                .trim();
        final minutesMatch = RegExp(r'(\d+)').firstMatch(timeText);
        if (minutesMatch != null) {
          estimatedMinutes = int.tryParse(minutesMatch.group(1)!) ?? 30;
        }
      } else if (trimmedLine.startsWith('- Prerequisites:') ||
          trimmedLine.startsWith('- Prérequis:') ||
          trimmedLine.startsWith('- Prérequis :') ||
          trimmedLine.startsWith('- Prerrequisitos:') ||
          trimmedLine.startsWith('- Prerrequisitos :')) {
        final prereqText =
            trimmedLine
                .replaceAll('- Prerequisites:', '')
                .replaceAll('- Prérequis:', '')
                .replaceAll('- Prérequis :', '')
                .replaceAll('- Prerrequisitos:', '')
                .replaceAll('- Prerrequisitos :', '')
                .trim();
        if (prereqText.toLowerCase() != 'none' &&
            prereqText.toLowerCase() != 'aucun' &&
            prereqText.toLowerCase() != 'ninguno') {
          prerequisites =
              prereqText
                  .split(',')
                  .map((p) => p.trim())
                  .where((p) => p.isNotEmpty)
                  .toList();
        }
      } else if (trimmedLine.startsWith('- Practice Problems:') ||
          trimmedLine.startsWith('- Problèmes de pratique:') ||
          trimmedLine.startsWith('- Problèmes de pratique :') ||
          trimmedLine.startsWith('- Problemas de práctica:') ||
          trimmedLine.startsWith('- Problemas de práctica :')) {
        final problemsText =
            trimmedLine
                .replaceAll('- Practice Problems:', '')
                .replaceAll('- Problèmes de pratique:', '')
                .replaceAll('- Problèmes de pratique :', '')
                .replaceAll('- Problemas de práctica:', '')
                .replaceAll('- Problemas de práctica :', '')
                .trim();
        // Handle different formats: comma-separated, semicolon-separated, or bracket format
        if (problemsText.contains('[') && problemsText.contains(']')) {
          // Handle format like: [Problem 1], [Problem 2], [Problem 3]
          final bracketPattern = RegExp(r'\[([^\]]+)\]');
          final matches = bracketPattern.allMatches(problemsText);
          practiceProblems =
              matches
                  .map((match) => match.group(1)?.trim() ?? '')
                  .where((p) => p.isNotEmpty)
                  .toList();
        } else if (problemsText.contains(';')) {
          // Handle semicolon-separated format
          practiceProblems =
              problemsText
                  .split(';')
                  .map((p) => p.trim())
                  .where((p) => p.isNotEmpty)
                  .toList();
        } else {
          // Handle comma-separated format (original)
          practiceProblems =
              problemsText
                  .split(',')
                  .map((p) => p.trim())
                  .where((p) => p.isNotEmpty)
                  .toList();
        }
      }

      // Don't create topic here - wait until we have all the data
    }

    // Add the last topic
    if (currentTopicTitle.isNotEmpty) {
      // Generate fallback practice problems if none were parsed
      if (practiceProblems.isEmpty) {
        practiceProblems = _generateFallbackPracticeProblems(
          currentTopicTitle,
          keyConcepts,
          locale,
        );
      }

      final topic = StudyTopic(
        id: _generateId(),
        title: currentTopicTitle,
        description: description,
        keyConceptsList: keyConcepts,
        estimatedMinutes: estimatedMinutes,
        status: StudyTopicStatus.notStarted,
        prerequisites: prerequisites,
        aiExplanation: description, // Use description as AI explanation
        practiceProblems: practiceProblems,
      );
      topics.add(topic);
    }

    return topics;
  }

  List<String> _generateFallbackPracticeProblems(
    String topicTitle,
    List<String> keyConcepts,
    String locale,
  ) {
    final problems = <String>[];

    // Generate localized practice problems based on topic title and key concepts
    if (locale == 'fr') {
      problems.add(
        'Réviser et comprendre les concepts principaux de $topicTitle',
      );

      if (keyConcepts.isNotEmpty) {
        problems.add(
          'Exercices pratiques axés sur ${keyConcepts.take(2).join(' et ')}',
        );

        if (keyConcepts.length > 2) {
          problems.add(
            'Travailler sur des problèmes impliquant ${keyConcepts.skip(2).take(2).join(' et ')}',
          );
        }
      }

      problems.add(
        'Compléter les feuilles d\'exercices ou les exercices du manuel sur $topicTitle',
      );
      problems.add('Passer un quiz ou une auto-évaluation sur ce sujet');
    } else if (locale == 'es') {
      problems.add(
        'Revisar y comprender los conceptos principales de $topicTitle',
      );

      if (keyConcepts.isNotEmpty) {
        problems.add(
          'Ejercicios prácticos enfocados en ${keyConcepts.take(2).join(' y ')}',
        );

        if (keyConcepts.length > 2) {
          problems.add(
            'Trabajar en problemas que involucren ${keyConcepts.skip(2).take(2).join(' y ')}',
          );
        }
      }

      problems.add(
        'Completar hojas de trabajo o ejercicios de libro de texto sobre $topicTitle',
      );
      problems.add('Tomar un cuestionario o autoevaluación sobre este tema');
    } else {
      // Default to English
      problems.add('Review and understand the main concepts of $topicTitle');

      if (keyConcepts.isNotEmpty) {
        problems.add(
          'Practice exercises focusing on ${keyConcepts.take(2).join(' and ')}',
        );

        if (keyConcepts.length > 2) {
          problems.add(
            'Work through problems involving ${keyConcepts.skip(2).take(2).join(' and ')}',
          );
        }
      }

      problems.add(
        'Complete practice worksheets or textbook exercises on $topicTitle',
      );
      problems.add('Take a quiz or self-assessment on this topic');
    }

    return problems;
  }

  int _calculateTotalHours(List<StudyTopic> topics) {
    final totalMinutes = topics.fold<int>(
      0,
      (sum, topic) => sum + topic.estimatedMinutes,
    );
    return (totalMinutes / 60).ceil();
  }

  String _getTargetDateText(DateTime targetDate, String locale) {
    final dateStr = targetDate.toLocal().toString().split(' ')[0];
    if (locale == 'fr') {
      return 'Date de fin prévue : $dateStr';
    } else if (locale == 'es') {
      return 'Fecha objetivo de finalización: $dateStr';
    } else {
      return 'Target completion date: $dateStr';
    }
  }

  String _getNoTargetDateText(String locale) {
    if (locale == 'fr') {
      return 'Aucune date cible spécifique';
    } else if (locale == 'es') {
      return 'Sin fecha objetivo específica';
    } else {
      return 'No specific target date';
    }
  }

  String _getStudyPlanDescription(String locale) {
    if (locale == 'fr') {
      return 'Plan d\'étude généré par IA basé sur vos matériaux téléchargés';
    } else if (locale == 'es') {
      return 'Plan de estudio generado por IA basado en tus materiales subidos';
    } else {
      return 'AI-generated study plan based on your uploaded materials';
    }
  }

  String _generatePlanTitle(List<StudyMaterial> materials, String locale) {
    if (materials.length == 1) {
      if (locale == 'fr') {
        return 'Plan d\'étude : ${materials.first.title}';
      } else if (locale == 'es') {
        return 'Plan de Estudio: ${materials.first.title}';
      } else {
        return 'Study Plan: ${materials.first.title}';
      }
    }
    if (locale == 'fr') {
      return 'Plan d\'étude : ${materials.length} matériaux';
    } else if (locale == 'es') {
      return 'Plan de Estudio: ${materials.length} Materiales';
    } else {
      return 'Study Plan: ${materials.length} Materials';
    }
  }

  StudyPlanDifficulty _determineDifficulty(MathLevel mathLevel) {
    switch (mathLevel) {
      case MathLevel.elementary:
        return StudyPlanDifficulty.beginner;
      case MathLevel.middleSchool:
        return StudyPlanDifficulty.beginner;
      case MathLevel.highSchool:
        return StudyPlanDifficulty.intermediate;
      case MathLevel.college:
        return StudyPlanDifficulty.advanced;
    }
  }

  String? _extractRecommendations(String studyPlanResponse) {
    final lines = studyPlanResponse.split('\n');
    final recommendations = <String>[];

    bool inRecommendationsSection = false;
    for (final line in lines) {
      if (line.contains('STUDY RECOMMENDATIONS:') ||
          line.contains('RECOMMANDATIONS D\'ÉTUDE:') ||
          line.contains('RECOMMANDATIONS D\'ÉTUDE :') ||
          line.contains('RECOMENDACIONES DE ESTUDIO:') ||
          line.contains('RECOMENDACIONES DE ESTUDIO :')) {
        inRecommendationsSection = true;
        continue;
      }

      if (inRecommendationsSection) {
        if (line.startsWith('**') &&
            !line.contains('RECOMMENDATIONS') &&
            !line.contains('RECOMMANDATIONS') &&
            !line.contains('RECOMENDACIONES')) {
          break;
        }

        if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
          final recommendation =
              line.replaceAll(RegExp(r'^[-•]\s*'), '').trim();
          if (recommendation.isNotEmpty) {
            recommendations.add(recommendation);
          }
        }
      }
    }

    return recommendations.isEmpty ? null : recommendations.join('\n• ');
  }

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(10000).toString();
  }
}
