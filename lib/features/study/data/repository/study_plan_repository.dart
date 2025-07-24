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
      debugPrint('Plan data: title=${plan.title}, topics=${plan.topics.length}');
      
      final planData = plan.toMap();
      debugPrint('Plan map keys: ${planData.keys.toList()}');
      
      await _firestore
          .collection(_collection)
          .doc(plan.id)
          .set(planData);
      
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

      debugPrint('Fetching study plans for user: $userId');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      debugPrint('Fetched ${plans.length} study plans from Firestore');
      return plans;
    } catch (e) {
      debugPrint('Error fetching study plans: $e');
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
      
      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      debugPrint('Fetched ${plans.length} study plans (paginated) from Firestore');
      return plans;
    } catch (e) {
      debugPrint('Error fetching paginated study plans: $e');
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

      debugPrint('Fetching study plans for materials: $materialIds');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('materialIds', arrayContainsAny: materialIds)
          .orderBy('createdAt', descending: true)
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      debugPrint('Fetched ${plans.length} study plans for materials from Firestore');
      return plans;
    } catch (e) {
      debugPrint('Error fetching study plans for materials: $e');
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

      debugPrint('Updating study plan: ${plan.id}');
      
      final planData = plan.toMap();
      planData['updatedAt'] = Timestamp.now();
      
      await _firestore
          .collection(_collection)
          .doc(plan.id)
          .update(planData);
      
      debugPrint('Study plan updated successfully: ${plan.id}');
    } catch (e) {
      debugPrint('Error updating study plan: $e');
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

      debugPrint('Updating study plan progress: $planId -> $progress%');
      
      await _firestore
          .collection(_collection)
          .doc(planId)
          .update({
            'overallProgress': progress,
            'updatedAt': Timestamp.now(),
          });
      
      debugPrint('Study plan progress updated successfully: $planId');
    } catch (e) {
      debugPrint('Error updating study plan progress: $e');
      rethrow;
    }
  }

  /// Update topic status within a study plan
  Future<void> updateTopicStatus(String planId, String topicId, StudyTopicStatus status) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Updating topic status: $planId -> $topicId -> ${status.name}');
      
      // Get the current plan
      final docSnapshot = await _firestore.collection(_collection).doc(planId).get();
      if (!docSnapshot.exists) {
        throw Exception('Study plan not found');
      }

      final plan = StudyPlan.fromMap(docSnapshot.data()!);
      if (plan.userId != userId) {
        throw Exception('Not authorized to update this plan');
      }

      // Update the specific topic
      final updatedTopics = plan.topics.map((topic) {
        if (topic.id == topicId) {
          return topic.copyWith(
            status: status,
            progressPercentage: status == StudyTopicStatus.completed ? 100.0 : topic.progressPercentage,
            completedAt: status == StudyTopicStatus.completed ? DateTime.now() : topic.completedAt,
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
      
      debugPrint('Topic status updated successfully: $planId -> $topicId');
    } catch (e) {
      debugPrint('Error updating topic status: $e');
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

      debugPrint('Deleting study plan: $planId');
      
      // Get the plan to check ownership
      final docSnapshot = await _firestore
          .collection(_collection)
          .doc(planId)
          .get();

      if (!docSnapshot.exists) {
        throw Exception('Study plan not found');
      }

      final plan = StudyPlan.fromMap(docSnapshot.data()!);
      if (plan.userId != userId) {
        throw Exception('Not authorized to delete this plan');
      }

      // Delete associated materials
      if (plan.materialIds.isNotEmpty) {
        debugPrint('Deleting ${plan.materialIds.length} associated materials');
        
        for (final materialId in plan.materialIds) {
          try {
            await _materialRepository.deleteMaterial(materialId);
            debugPrint('Deleted material: $materialId');
          } catch (e) {
            debugPrint('Warning: Could not delete material $materialId: $e');
            // Continue with other materials even if one fails
          }
        }
      }

      // Delete the study plan document
      await _firestore.collection(_collection).doc(planId).delete();
      
      debugPrint('Study plan and associated materials deleted successfully: $planId');
    } catch (e) {
      debugPrint('Error deleting study plan: $e');
      rethrow;
    }
  }

  /// Get study plans by difficulty
  Future<List<StudyPlan>> getPlansByDifficulty(StudyPlanDifficulty difficulty) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('difficulty', isEqualTo: difficulty.name)
          .orderBy('createdAt', descending: true)
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      debugPrint('Fetched ${plans.length} ${difficulty.name} study plans from Firestore');
      return plans;
    } catch (e) {
      debugPrint('Error fetching plans by difficulty: $e');
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
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('title', isGreaterThanOrEqualTo: searchQuery)
          .where('title', isLessThanOrEqualTo: '$searchQuery\uf8ff')
          .orderBy('title')
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      debugPrint('Found ${plans.length} study plans matching "$searchQuery"');
      return plans;
    } catch (e) {
      debugPrint('Error searching study plans: $e');
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

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      final stats = {
        'totalPlans': plans.length,
        'beginnerCount': plans.where((p) => p.difficulty == StudyPlanDifficulty.beginner).length,
        'intermediateCount': plans.where((p) => p.difficulty == StudyPlanDifficulty.intermediate).length,
        'advancedCount': plans.where((p) => p.difficulty == StudyPlanDifficulty.advanced).length,
        'averageProgress': plans.isNotEmpty 
            ? plans.fold<double>(0.0, (total, plan) => total + plan.overallProgress) / plans.length 
            : 0.0,
        'completedPlans': plans.where((p) => p.overallProgress >= 100.0).length,
        'totalTopics': plans.fold<int>(0, (total, plan) => total + plan.topics.length),
        'totalEstimatedHours': plans.fold<int>(0, (total, plan) => total + plan.totalEstimatedHours),
      };

      debugPrint('Study plan statistics: $stats');
      return stats;
    } catch (e) {
      debugPrint('Error getting study plan statistics: $e');
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

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      final plans = querySnapshot.docs
          .map((doc) => StudyPlan.fromMap(doc.data()))
          .toList();

      debugPrint('Fetched ${plans.length} recently updated study plans');
      return plans;
    } catch (e) {
      debugPrint('Error fetching recently updated plans: $e');
      return [];
    }
  }
}