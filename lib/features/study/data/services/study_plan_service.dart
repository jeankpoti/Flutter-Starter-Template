import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../solve_math/data/repository/gemini_solve_math_repo.dart';
import '../../../settings/data/preferences_service.dart';
import '../../../settings/domain/models/math_level.dart';
import '../../domain/models/study_material.dart';
import '../../domain/models/study_plan.dart';

class StudyPlanService {
  static final StudyPlanService _instance = StudyPlanService._internal();
  late final GeminiSolveMathRepo _geminiService;
  final Random _random = Random();

  factory StudyPlanService() {
    return _instance;
  }

  StudyPlanService._internal();

  Future<void> initialize() async {
    _geminiService = GeminiSolveMathRepo();
    await _geminiService.initialize();
  }

  /// Analyze uploaded material and extract topics, concepts, and difficulty
  Future<StudyMaterial> analyzeMaterial({
    required String materialId,
    required MaterialType type,
    String? content,
    File? imageFile,
    required String title,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await PreferencesService.getInstance();
    final mathLevel = prefs.getMathLevel();

    String aiAnalysis = '';
    List<String> extractedTopics = [];

    try {
      if (type == MaterialType.text && content != null) {
        aiAnalysis = await _analyzeTextContent(content, mathLevel);
      } else if (type == MaterialType.image && imageFile != null) {
        aiAnalysis = await _analyzeImageContent(imageFile, mathLevel);
      }

      // Extract topics from AI analysis
      extractedTopics = _extractTopicsFromAnalysis(aiAnalysis);

    } catch (e) {
      // Log error (in production, use proper logging framework)
      debugPrint('Error analyzing material: $e');
      aiAnalysis = 'Error analyzing content. Please try again.';
    }

    return StudyMaterial(
      id: materialId,
      userId: userId,
      title: title,
      type: type,
      status: aiAnalysis.contains('Error') ? MaterialStatus.failed : MaterialStatus.completed,
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

    // Combine all material content and analysis
    final combinedContent = _combineMateriaiContent(materials);
    
    // Generate study plan using AI
    final studyPlanResponse = await _generateAIStudyPlan(combinedContent, mathLevel, targetDate);
    
    // Parse AI response into structured study plan
    final topics = _parseStudyTopics(studyPlanResponse);
    final totalHours = _calculateTotalHours(topics);
    
    final studyPlan = StudyPlan(
      id: _generateId(),
      userId: userId,
      title: customTitle ?? _generatePlanTitle(materials),
      description: 'AI-generated study plan based on your uploaded materials',
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

  /// Analyze text content using Gemini AI
  Future<String> _analyzeTextContent(String content, MathLevel mathLevel) async {
    final prompt = '''
You are an expert math tutor analyzing study material. Analyze this content and provide a comprehensive breakdown:

CONTENT TO ANALYZE:
$content

Please provide analysis in this format:

**MAIN TOPICS:**
- List the key mathematical topics covered
- Include subtopics and specific concepts

**DIFFICULTY LEVEL:**
- Assess if this is appropriate for ${mathLevel.displayName} level
- Note any prerequisites needed

**KEY CONCEPTS:**
- Essential concepts students must understand
- Important formulas or theorems mentioned

**LEARNING OBJECTIVES:**
- What students should be able to do after studying this
- Specific skills they'll develop

**STUDY RECOMMENDATIONS:**
- How to approach learning this material
- Suggested practice strategies
- Estimated study time needed

Make recommendations appropriate for ${mathLevel.displayName} level students.
''';

    final response = await _geminiService.generateTextContent(prompt);
    return response.text ?? 'Unable to analyze content';
  }

  /// Analyze image content using Gemini AI
  Future<String> _analyzeImageContent(File imageFile, MathLevel mathLevel) async {
    try {
      // Use the existing solveMath method which handles image analysis
      // The prompts are already configured in GeminiSolveMathRepo for image analysis
      final response = await _geminiService.solveMath(imageFile);
      return response;
    } catch (e) {
      return 'Unable to analyze image content: $e';
    }
  }

  /// Generate AI study plan from combined materials
  Future<String> _generateAIStudyPlan(String combinedContent, MathLevel mathLevel, DateTime? targetDate) async {
    final targetInfo = targetDate != null 
        ? 'Target completion date: ${targetDate.toLocal().toString().split(' ')[0]}'
        : 'No specific target date';

    final prompt = '''
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

    final response = await _geminiService.generateTextContent(prompt);
    return response.text ?? 'Unable to generate study plan';
  }

  // Helper methods for parsing and processing

  List<String> _extractTopicsFromAnalysis(String analysis) {
    final topics = <String>[];
    final lines = analysis.split('\n');
    
    bool inTopicsSection = false;
    for (final line in lines) {
      if (line.contains('MAIN TOPICS:') || line.contains('TOPICS:')) {
        inTopicsSection = true;
        continue;
      }
      
      if (inTopicsSection) {
        if (line.startsWith('**') && !line.contains('TOPICS')) {
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

  List<StudyTopic> _parseStudyTopics(String studyPlanResponse) {
    final topics = <StudyTopic>[];
    final lines = studyPlanResponse.split('\n');
    
    StudyTopic? currentTopic;
    String currentTopicTitle = '';
    String description = '';
    List<String> keyConcepts = [];
    int estimatedMinutes = 30;
    List<String> prerequisites = [];
    List<String> practiceProblems = [];
    
    for (final line in lines) {
      final trimmedLine = line.trim();
      
      // Check for topic header
      if (trimmedLine.startsWith('**TOPIC ') && trimmedLine.contains(':')) {
        // Save previous topic if exists
        if (currentTopic != null && currentTopicTitle.isNotEmpty) {
          topics.add(currentTopic);
        }
        
        // Start new topic
        currentTopicTitle = trimmedLine.replaceAll(RegExp(r'\*\*TOPIC \d+:\s*'), '').replaceAll('**', '');
        description = '';
        keyConcepts = [];
        estimatedMinutes = 30;
        prerequisites = [];
        practiceProblems = [];
      } else if (trimmedLine.startsWith('- Description:')) {
        description = trimmedLine.replaceAll('- Description:', '').trim();
      } else if (trimmedLine.startsWith('- Key Concepts:')) {
        final conceptsText = trimmedLine.replaceAll('- Key Concepts:', '').trim();
        keyConcepts = conceptsText.split(',').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
      } else if (trimmedLine.startsWith('- Estimated Time:')) {
        final timeText = trimmedLine.replaceAll('- Estimated Time:', '').trim();
        final minutesMatch = RegExp(r'(\d+)').firstMatch(timeText);
        if (minutesMatch != null) {
          estimatedMinutes = int.tryParse(minutesMatch.group(1)!) ?? 30;
        }
      } else if (trimmedLine.startsWith('- Prerequisites:')) {
        final prereqText = trimmedLine.replaceAll('- Prerequisites:', '').trim();
        if (prereqText.toLowerCase() != 'none') {
          prerequisites = prereqText.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
        }
      } else if (trimmedLine.startsWith('- Practice Problems:')) {
        final problemsText = trimmedLine.replaceAll('- Practice Problems:', '').trim();
        practiceProblems = problemsText.split(',').map((p) => p.trim()).where((p) => p.isNotEmpty).toList();
      }
      
      // If we have a complete topic, create it
      if (currentTopicTitle.isNotEmpty && description.isNotEmpty) {
        currentTopic = StudyTopic(
          id: _generateId(),
          title: currentTopicTitle,
          description: description,
          keyConceptsList: keyConcepts,
          estimatedMinutes: estimatedMinutes,
          status: StudyTopicStatus.notStarted,
          prerequisites: prerequisites,
          practiceProblems: practiceProblems,
        );
      }
    }
    
    // Add the last topic
    if (currentTopic != null && currentTopicTitle.isNotEmpty) {
      topics.add(currentTopic);
    }
    
    return topics;
  }

  int _calculateTotalHours(List<StudyTopic> topics) {
    final totalMinutes = topics.fold<int>(0, (sum, topic) => sum + topic.estimatedMinutes);
    return (totalMinutes / 60).ceil();
  }

  String _generatePlanTitle(List<StudyMaterial> materials) {
    if (materials.length == 1) {
      return 'Study Plan: ${materials.first.title}';
    }
    return 'Study Plan: ${materials.length} Materials';
  }

  StudyPlanDifficulty _determineDifficulty(MathLevel mathLevel) {
    switch (mathLevel) {
      case MathLevel.elementary:
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
      if (line.contains('STUDY RECOMMENDATIONS:')) {
        inRecommendationsSection = true;
        continue;
      }
      
      if (inRecommendationsSection) {
        if (line.startsWith('**') && !line.contains('RECOMMENDATIONS')) {
          break;
        }
        
        if (line.trim().startsWith('-') || line.trim().startsWith('•')) {
          final recommendation = line.replaceAll(RegExp(r'^[-•]\s*'), '').trim();
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