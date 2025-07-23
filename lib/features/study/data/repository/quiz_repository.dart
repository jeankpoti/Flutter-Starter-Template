import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/models/quiz.dart';

class QuizRepository {
  static final QuizRepository _instance = QuizRepository._internal();
  late final FirebaseFirestore _firestore;
  late final String _collection;

  factory QuizRepository() {
    return _instance;
  }

  QuizRepository._internal() {
    _firestore = FirebaseFirestore.instance;
    _collection = 'quizzes';
  }

  /// Save a completed quiz to Firebase
  Future<void> saveQuiz(Quiz quiz) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Saving quiz to Firestore: ${quiz.id}');
      debugPrint('Quiz data: title=${quiz.title}, score=${quiz.lastScore}, status=${quiz.status}');
      
      final quizData = quiz.toMap();
      debugPrint('Quiz map keys: ${quizData.keys.toList()}');
      
      await _firestore
          .collection(_collection)
          .doc(quiz.id)
          .set(quizData);
      
      debugPrint('Quiz saved successfully to Firestore: ${quiz.id}');
    } catch (e) {
      debugPrint('Error saving quiz to Firestore: $e');
      rethrow;
    }
  }

  /// Get all quizzes for the current user
  Future<List<Quiz>> getUserQuizzes() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Fetching quizzes for user: $userId');
      
      // Try with ordering first, fall back to simple query if index doesn't exist
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (indexError) {
        debugPrint('Index not available, falling back to simple query: $indexError');
        // Fallback to simple query without ordering
        querySnapshot = await _firestore
            .collection(_collection)
            .where('userId', isEqualTo: userId)
            .get();
      }

      debugPrint('Found ${querySnapshot.docs.length} quiz documents');
      
      final quizzes = querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              debugPrint('Quiz doc: ${doc.id}, data keys: ${data.keys.toList()}');
              return Quiz.fromMap(data);
            } else {
              debugPrint('Invalid document data format for doc: ${doc.id}');
              return null;
            }
          })
          .whereType<Quiz>()
          .toList();
      
      // Sort by creation date (newest first) in case Firestore ordering failed
      quizzes.sort((a, b) {
        final aDate = a.lastAttemptAt ?? a.createdAt;
        final bDate = b.lastAttemptAt ?? b.createdAt;
        return bDate.compareTo(aDate); // Descending order (newest first)
      });
          
      debugPrint('Parsed and sorted ${quizzes.length} quizzes successfully');
      return quizzes;
    } catch (e) {
      debugPrint('Error fetching user quizzes: $e');
      return [];
    }
  }

  /// Get quizzes for specific study materials
  Future<List<Quiz>> getQuizzesForMaterials(List<String> materialIds) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('studyMaterialIds', arrayContainsAny: materialIds)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Quiz.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error fetching quizzes for materials: $e');
      return [];
    }
  }

  /// Get quizzes for a specific study plan
  Future<List<Quiz>> getQuizzesForStudyPlan(String studyPlanId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('studyTopicIds', isNotEqualTo: [])
          .orderBy('createdAt', descending: true)
          .get();

      // Filter by study plan topics (since we can't query nested arrays directly)
      return querySnapshot.docs
          .map((doc) => Quiz.fromMap(doc.data()))
          .where((quiz) => quiz.studyTopicIds.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('Error fetching quizzes for study plan: $e');
      return [];
    }
  }

  /// Update an existing quiz (for retakes)
  Future<void> updateQuiz(Quiz quiz) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(quiz.id)
          .update(quiz.toMap());
      
      debugPrint('Quiz updated successfully: ${quiz.id}');
    } catch (e) {
      debugPrint('Error updating quiz: $e');
      rethrow;
    }
  }

  /// Delete a quiz
  Future<void> deleteQuiz(String quizId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(quizId)
          .delete();
      
      debugPrint('Quiz deleted successfully: $quizId');
    } catch (e) {
      debugPrint('Error deleting quiz: $e');
      rethrow;
    }
  }

  /// Get quiz statistics for the user
  Future<Map<String, dynamic>> getQuizStatistics() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .get();

      final quizzes = querySnapshot.docs
          .map((doc) => Quiz.fromMap(doc.data()))
          .toList();

      if (quizzes.isEmpty) {
        return {
          'totalQuizzes': 0,
          'averageScore': 0.0,
          'bestScore': 0.0,
          'totalQuestionsAnswered': 0,
          'totalCorrectAnswers': 0,
          'streakCount': 0,
          'recentActivity': <Map<String, dynamic>>[],
        };
      }

      // Calculate statistics
      final totalQuizzes = quizzes.length;
      final scores = quizzes.where((q) => q.lastScore != null).map((q) => q.lastScore!).toList();
      final averageScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a + b) / scores.length;
      final bestScore = scores.isEmpty ? 0.0 : scores.reduce((a, b) => a > b ? a : b);
      
      final totalQuestionsAnswered = quizzes.fold<int>(0, (total, quiz) => total + quiz.userAnswers.length);
      final totalCorrectAnswers = quizzes.fold<int>(0, (total, quiz) => 
          total + quiz.userAnswers.where((answer) => answer.isCorrect).length);

      // Calculate streak (consecutive days with completed quizzes)
      final streakCount = _calculateStreak(quizzes);

      // Recent activity (last 10 quizzes)
      final recentActivity = quizzes
          .take(10)
          .map((quiz) => {
            'id': quiz.id,
            'title': quiz.title,
            'score': quiz.lastScore,
            'completedAt': quiz.lastAttemptAt?.toIso8601String(),
            'questionCount': quiz.questions.length,
          })
          .toList();

      return {
        'totalQuizzes': totalQuizzes,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'totalQuestionsAnswered': totalQuestionsAnswered,
        'totalCorrectAnswers': totalCorrectAnswers,
        'streakCount': streakCount,
        'recentActivity': recentActivity,
      };
    } catch (e) {
      debugPrint('Error fetching quiz statistics: $e');
      return {
        'totalQuizzes': 0,
        'averageScore': 0.0,
        'bestScore': 0.0,
        'totalQuestionsAnswered': 0,
        'totalCorrectAnswers': 0,
        'streakCount': 0,
        'recentActivity': <Map<String, dynamic>>[],
      };
    }
  }

  /// Calculate the current streak of days with completed quizzes
  int _calculateStreak(List<Quiz> quizzes) {
    if (quizzes.isEmpty) return 0;

    // Sort quizzes by completion date
    final completedQuizzes = quizzes
        .where((quiz) => quiz.lastAttemptAt != null)
        .toList()
      ..sort((a, b) => b.lastAttemptAt!.compareTo(a.lastAttemptAt!));

    if (completedQuizzes.isEmpty) return 0;

    int streak = 0;
    DateTime? lastDate;

    for (final quiz in completedQuizzes) {
      final quizDate = DateTime(
        quiz.lastAttemptAt!.year,
        quiz.lastAttemptAt!.month,
        quiz.lastAttemptAt!.day,
      );

      if (lastDate == null) {
        // First quiz
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        
        if (quizDate.isAtSameMomentAs(todayDate) || 
            quizDate.isAtSameMomentAs(todayDate.subtract(const Duration(days: 1)))) {
          streak = 1;
          lastDate = quizDate;
        } else {
          break;
        }
      } else {
        // Check if this quiz is from the previous day
        final expectedPreviousDay = lastDate.subtract(const Duration(days: 1));
        
        if (quizDate.isAtSameMomentAs(expectedPreviousDay)) {
          streak++;
          lastDate = quizDate;
        } else if (quizDate.isAtSameMomentAs(lastDate)) {
          // Same day, don't increment streak but continue
          continue;
        } else {
          // Gap in streak
          break;
        }
      }
    }

    return streak;
  }

  /// Get performance trends over time
  Future<List<Map<String, dynamic>>> getPerformanceTrends({int days = 30}) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final startDate = DateTime.now().subtract(Duration(days: days));
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'completed')
          .where('lastAttemptAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .orderBy('lastAttemptAt', descending: false)
          .get();

      final quizzes = querySnapshot.docs
          .map((doc) => Quiz.fromMap(doc.data()))
          .toList();

      // Group by day and calculate daily averages
      final dailyPerformance = <String, List<double>>{};
      
      for (final quiz in quizzes) {
        if (quiz.lastAttemptAt != null && quiz.lastScore != null) {
          final dayKey = '${quiz.lastAttemptAt!.year}-${quiz.lastAttemptAt!.month.toString().padLeft(2, '0')}-${quiz.lastAttemptAt!.day.toString().padLeft(2, '0')}';
          
          if (!dailyPerformance.containsKey(dayKey)) {
            dailyPerformance[dayKey] = [];
          }
          dailyPerformance[dayKey]!.add(quiz.lastScore!);
        }
      }

      // Calculate daily averages
      final trends = dailyPerformance.entries.map((entry) {
        final scores = entry.value;
        final averageScore = scores.reduce((a, b) => a + b) / scores.length;
        
        return {
          'date': entry.key,
          'averageScore': averageScore,
          'quizCount': scores.length,
        };
      }).toList();

      return trends;
    } catch (e) {
      debugPrint('Error fetching performance trends: $e');
      return [];
    }
  }
}