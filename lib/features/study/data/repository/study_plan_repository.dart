import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/study_plan.dart';
import 'study_material_repository.dart';

class StudyPlanRepository {
  static final StudyPlanRepository _instance = StudyPlanRepository._internal();
  late final FirebaseFirestore _firestore;
  late final String _collection;
  late final StudyMaterialRepository _materialRepository;

  factory StudyPlanRepository() {
    return _instance;
  }

  StudyPlanRepository._internal() {
    _firestore = FirebaseFirestore.instance;
    _collection = 'studyPlans';
    _materialRepository = StudyMaterialRepository();
  }

  /// Save a study plan to Firebase
  Future<void> savePlan(StudyPlan plan) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Saving study plan to Firestore: ${plan.id}');
      debugPrint(
        'Plan data: title=${plan.title}, topics=${plan.topics.length}',
      );

      final planData = plan.toMap();
      debugPrint('Plan map keys: ${planData.keys.toList()}');

      await _firestore.collection(_collection).doc(plan.id).set(planData);

      debugPrint('Study plan saved successfully to Firestore: ${plan.id}');
    } catch (e) {
      debugPrint('Error saving study plan to Firestore: $e');
      rethrow;
    }
  }

  /// Get all study plans for the current user
  Future<List<StudyPlan>> getUserPlans() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  /// Get study plans with pagination
  Future<List<StudyPlan>> getUserPlansPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      Query query = _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final querySnapshot = await query.get();

      final plans =
          querySnapshot.docs
              .map(
                (doc) => StudyPlan.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  /// Get study plans based on specific materials
  Future<List<StudyPlan>> getPlansForMaterials(List<String> materialIds) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (materialIds.isEmpty) return [];

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('materialIds', arrayContainsAny: materialIds)
              .orderBy('createdAt', descending: true)
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  /// Update an existing study plan
  Future<void> updatePlan(StudyPlan plan) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (plan.userId != userId) {
        throw Exception('Not authorized to update this plan');
      }

      final planData = plan.toMap();
      planData['updatedAt'] = Timestamp.now();

      await _firestore.collection(_collection).doc(plan.id).update(planData);
    } catch (e) {
      rethrow;
    }
  }

  /// Update study plan progress
  Future<void> updatePlanProgress(String planId, double progress) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore.collection(_collection).doc(planId).update({
        'overallProgress': progress,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Update topic status within a study plan
  Future<void> updateTopicStatus(
    String planId,
    String topicId,
    StudyTopicStatus status,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get the current plan
      final docSnapshot =
          await _firestore.collection(_collection).doc(planId).get();
      if (!docSnapshot.exists) {
        throw Exception('Study plan not found');
      }

      final plan = StudyPlan.fromMap(docSnapshot.data()!);
      if (plan.userId != userId) {
        throw Exception('Not authorized to update this plan');
      }

      // Update the specific topic
      final updatedTopics =
          plan.topics.map((topic) {
            if (topic.id == topicId) {
              return topic.copyWith(
                status: status,
                progressPercentage:
                    status == StudyTopicStatus.completed
                        ? 100.0
                        : topic.progressPercentage,
                completedAt:
                    status == StudyTopicStatus.completed
                        ? DateTime.now()
                        : topic.completedAt,
              );
            }
            return topic;
          }).toList();

      // Calculate new overall progress
      final totalProgress = updatedTopics.fold<double>(
        0.0,
        (total, topic) => total + topic.progressPercentage,
      );
      final overallProgress = totalProgress / updatedTopics.length;

      // Update the plan
      await _firestore.collection(_collection).doc(planId).update({
        'topics': updatedTopics.map((topic) => topic.toMap()).toList(),
        'overallProgress': overallProgress,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a study plan
  Future<void> deletePlan(String planId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final docSnapshot =
          await _firestore.collection(_collection).doc(planId).get();

      if (!docSnapshot.exists) {
        throw Exception('Study plan not found');
      }

      final plan = StudyPlan.fromMap(docSnapshot.data()!);
      if (plan.userId != userId) {
        throw Exception('Not authorized to delete this plan');
      }

      // Delete associated materials
      if (plan.materialIds.isNotEmpty) {
        for (final materialId in plan.materialIds) {
          try {
            await _materialRepository.deleteMaterial(materialId);
          } catch (e) {
            debugPrint('Warning: Could not delete material $materialId: $e');
            // Continue with other materials even if one fails
          }
        }
      }

      // Delete the study plan document
      await _firestore.collection(_collection).doc(planId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get study plans by difficulty
  Future<List<StudyPlan>> getPlansByDifficulty(
    StudyPlanDifficulty difficulty,
  ) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('difficulty', isEqualTo: difficulty.name)
              .orderBy('createdAt', descending: true)
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  /// Search study plans by title
  Future<List<StudyPlan>> searchPlans(String searchQuery) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation that searches by title prefix
      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('title', isGreaterThanOrEqualTo: searchQuery)
              .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
              .orderBy('title')
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }

  /// Get study plan statistics
  Future<Map<String, dynamic>> getPlanStatistics() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      final stats = {
        'totalPlans': plans.length,
        'beginnerCount':
            plans
                .where((p) => p.difficulty == StudyPlanDifficulty.beginner)
                .length,
        'intermediateCount':
            plans
                .where((p) => p.difficulty == StudyPlanDifficulty.intermediate)
                .length,
        'advancedCount':
            plans
                .where((p) => p.difficulty == StudyPlanDifficulty.advanced)
                .length,
        'averageProgress':
            plans.isNotEmpty
                ? plans.fold<double>(
                      0.0,
                      (total, plan) => total + plan.overallProgress,
                    ) /
                    plans.length
                : 0.0,
        'completedPlans': plans.where((p) => p.overallProgress >= 100.0).length,
        'totalTopics': plans.fold<int>(
          0,
          (total, plan) => total + plan.topics.length,
        ),
        'totalEstimatedHours': plans.fold<int>(
          0,
          (total, plan) => total + plan.totalEstimatedHours,
        ),
      };

      return stats;
    } catch (e) {
      return {};
    }
  }

  /// Get recently updated study plans
  Future<List<StudyPlan>> getRecentlyUpdatedPlans({int limit = 5}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('updatedAt', descending: true)
              .limit(limit)
              .get();

      final plans =
          querySnapshot.docs
              .map((doc) => StudyPlan.fromMap(doc.data()))
              .toList();

      return plans;
    } catch (e) {
      return [];
    }
  }
}
