import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum StudyTopicStatus { notStarted, inProgress, completed, needsReview }

enum StudyPlanDifficulty { beginner, intermediate, advanced }

class StudyTopic extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> keyConceptsList;
  final int estimatedMinutes;
  final StudyTopicStatus status;
  final List<String> prerequisites; // Topic IDs that should be completed first
  final String? aiExplanation;
  final List<String> practiceProblems;
  final DateTime? completedAt;
  final double progressPercentage;

  const StudyTopic({
    required this.id,
    required this.title,
    required this.description,
    this.keyConceptsList = const [],
    required this.estimatedMinutes,
    required this.status,
    this.prerequisites = const [],
    this.aiExplanation,
    this.practiceProblems = const [],
    this.completedAt,
    this.progressPercentage = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'keyConceptsList': keyConceptsList,
      'estimatedMinutes': estimatedMinutes,
      'status': status.name,
      'prerequisites': prerequisites,
      'aiExplanation': aiExplanation,
      'practiceProblems': practiceProblems,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'progressPercentage': progressPercentage,
    };
  }

  factory StudyTopic.fromMap(Map<String, dynamic> map) {
    return StudyTopic(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      keyConceptsList: List<String>.from(map['keyConceptsList'] ?? []),
      estimatedMinutes: map['estimatedMinutes'] ?? 30,
      status: StudyTopicStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => StudyTopicStatus.notStarted,
      ),
      prerequisites: List<String>.from(map['prerequisites'] ?? []),
      aiExplanation: map['aiExplanation'],
      practiceProblems: List<String>.from(map['practiceProblems'] ?? []),
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      progressPercentage: (map['progressPercentage'] ?? 0.0).toDouble(),
    );
  }

  StudyTopic copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? keyConceptsList,
    int? estimatedMinutes,
    StudyTopicStatus? status,
    List<String>? prerequisites,
    String? aiExplanation,
    List<String>? practiceProblems,
    DateTime? completedAt,
    double? progressPercentage,
  }) {
    return StudyTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      keyConceptsList: keyConceptsList ?? this.keyConceptsList,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      status: status ?? this.status,
      prerequisites: prerequisites ?? this.prerequisites,
      aiExplanation: aiExplanation ?? this.aiExplanation,
      practiceProblems: practiceProblems ?? this.practiceProblems,
      completedAt: completedAt ?? this.completedAt,
      progressPercentage: progressPercentage ?? this.progressPercentage,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        keyConceptsList,
        estimatedMinutes,
        status,
        prerequisites,
        aiExplanation,
        practiceProblems,
        completedAt,
        progressPercentage,
      ];
}

class StudyPlan extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> materialIds; // Study materials this plan is based on
  final List<StudyTopic> topics;
  final StudyPlanDifficulty difficulty;
  final int totalEstimatedHours;
  final DateTime? targetCompletionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double overallProgress;
  final String? aiRecommendations;

  const StudyPlan({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    this.materialIds = const [],
    this.topics = const [],
    required this.difficulty,
    required this.totalEstimatedHours,
    this.targetCompletionDate,
    required this.createdAt,
    required this.updatedAt,
    this.overallProgress = 0.0,
    this.aiRecommendations,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'materialIds': materialIds,
      'topics': topics.map((topic) => topic.toMap()).toList(),
      'difficulty': difficulty.name,
      'totalEstimatedHours': totalEstimatedHours,
      'targetCompletionDate':
          targetCompletionDate != null
              ? Timestamp.fromDate(targetCompletionDate!)
              : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'overallProgress': overallProgress,
      'aiRecommendations': aiRecommendations,
    };
  }

  factory StudyPlan.fromMap(Map<String, dynamic> map) {
    return StudyPlan(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      materialIds: List<String>.from(map['materialIds'] ?? []),
      topics:
          (map['topics'] as List<dynamic>?)
              ?.map((topicMap) => StudyTopic.fromMap(topicMap))
              .toList() ??
          [],
      difficulty: StudyPlanDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => StudyPlanDifficulty.intermediate,
      ),
      totalEstimatedHours: map['totalEstimatedHours'] ?? 1,
      targetCompletionDate:
          (map['targetCompletionDate'] as Timestamp?)?.toDate(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      overallProgress: (map['overallProgress'] ?? 0.0).toDouble(),
      aiRecommendations: map['aiRecommendations'],
    );
  }

  StudyPlan copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? materialIds,
    List<StudyTopic>? topics,
    StudyPlanDifficulty? difficulty,
    int? totalEstimatedHours,
    DateTime? targetCompletionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? overallProgress,
    String? aiRecommendations,
  }) {
    return StudyPlan(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      materialIds: materialIds ?? this.materialIds,
      topics: topics ?? this.topics,
      difficulty: difficulty ?? this.difficulty,
      totalEstimatedHours: totalEstimatedHours ?? this.totalEstimatedHours,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      overallProgress: overallProgress ?? this.overallProgress,
      aiRecommendations: aiRecommendations ?? this.aiRecommendations,
    );
  }

  // Calculate overall progress from topics
  double calculateProgress() {
    if (topics.isEmpty) return 0.0;

    final totalProgress = topics.fold<double>(
      0.0,
      (total, topic) => total + topic.progressPercentage,
    );

    return totalProgress / topics.length;
  }

  // Get next topic to study
  StudyTopic? getNextTopic() {
    // Find topics that are not completed and have all prerequisites completed
    for (final topic in topics) {
      if (topic.status == StudyTopicStatus.completed) continue;

      // Check if all prerequisites are completed
      final allPrerequisitesMet = topic.prerequisites.every((prereqId) {
        final prereqTopic = topics.firstWhere(
          (t) => t.id == prereqId,
          orElse: () => topic, // If prerequisite not found, assume it's met
        );
        return prereqTopic.status == StudyTopicStatus.completed;
      });

      if (allPrerequisitesMet) {
        return topic;
      }
    }

    return null;
  }

  // Update topic progress and return updated study plan
  StudyPlan updateTopicProgress(
    String topicId,
    double progressPercentage, {
    StudyTopicStatus? status,
  }) {
    final updatedTopics =
        topics.map((topic) {
          if (topic.id == topicId) {
            StudyTopicStatus newStatus = status ?? topic.status;
            DateTime? newCompletedAt = topic.completedAt;

            // Auto-update status based on progress
            if (progressPercentage >= 100.0) {
              newStatus = StudyTopicStatus.completed;
              newCompletedAt = DateTime.now();
            } else if (progressPercentage > 0.0 &&
                topic.status == StudyTopicStatus.notStarted) {
              newStatus = StudyTopicStatus.inProgress;
            } else if (progressPercentage == 0.0) {
              newStatus = StudyTopicStatus.notStarted;
              newCompletedAt = null;
            }

            return topic.copyWith(
              progressPercentage: progressPercentage,
              status: newStatus,
              completedAt: newCompletedAt,
            );
          }
          return topic;
        }).toList();

    return copyWith(
      topics: updatedTopics,
      overallProgress: _calculateOverallProgress(updatedTopics),
    );
  }

  // Mark topic as complete
  StudyPlan markTopicComplete(String topicId) {
    return updateTopicProgress(
      topicId,
      100.0,
      status: StudyTopicStatus.completed,
    );
  }

  // Mark topic as incomplete
  StudyPlan markTopicIncomplete(String topicId) {
    return updateTopicProgress(
      topicId,
      0.0,
      status: StudyTopicStatus.notStarted,
    );
  }

  // Start topic (mark as in progress)
  StudyPlan startTopic(String topicId) {
    final updatedTopics =
        topics.map((topic) {
          if (topic.id == topicId &&
              topic.status == StudyTopicStatus.notStarted) {
            return topic.copyWith(
              status: StudyTopicStatus.inProgress,
              progressPercentage:
                  topic.progressPercentage > 0
                      ? topic.progressPercentage
                      : 10.0,
            );
          }
          return topic;
        }).toList();

    return copyWith(
      topics: updatedTopics,
      overallProgress: _calculateOverallProgress(updatedTopics),
    );
  }

  // Helper method to calculate overall progress from topics
  double _calculateOverallProgress(List<StudyTopic> topicsList) {
    if (topicsList.isEmpty) return 0.0;

    final totalProgress = topicsList.fold<double>(
      0.0,
      (total, topic) => total + topic.progressPercentage,
    );

    return totalProgress / topicsList.length;
  }

  // Get completion statistics
  Map<String, int> getCompletionStats() {
    return {
      'total': topics.length,
      'completed':
          topics.where((t) => t.status == StudyTopicStatus.completed).length,
      'inProgress':
          topics.where((t) => t.status == StudyTopicStatus.inProgress).length,
      'notStarted':
          topics.where((t) => t.status == StudyTopicStatus.notStarted).length,
      'needsReview':
          topics.where((t) => t.status == StudyTopicStatus.needsReview).length,
    };
  }

  // Get available topics (prerequisites met)
  List<StudyTopic> getAvailableTopics() {
    return topics.where((topic) {
      if (topic.status == StudyTopicStatus.completed) return false;

      // Check if all prerequisites are completed
      return topic.prerequisites.every((prereqId) {
        final prereqTopic = topics.firstWhere(
          (t) => t.id == prereqId,
          orElse: () => topic,
        );
        return prereqTopic.status == StudyTopicStatus.completed;
      });
    }).toList();
  }

  // Check if plan is completed
  bool get isCompleted {
    return topics.isNotEmpty &&
        topics.every((topic) => topic.status == StudyTopicStatus.completed);
  }

  @override
  String toString() {
    return 'StudyPlan(id: $id, title: $title, progress: ${overallProgress.toStringAsFixed(1)}%)';
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        materialIds,
        topics,
        difficulty,
        totalEstimatedHours,
        targetCompletionDate,
        createdAt,
        updatedAt,
        overallProgress,
        aiRecommendations,
      ];
}
