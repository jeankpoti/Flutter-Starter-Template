import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/models/study_material.dart';
import '../../../../common/utils/file_size_validator.dart';

class StudyMaterialRepository {
  static final StudyMaterialRepository _instance =
      StudyMaterialRepository._internal();
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final String _collection;
  late final String _storagePath;

  factory StudyMaterialRepository() {
    return _instance;
  }

  StudyMaterialRepository._internal() {
    _firestore = FirebaseFirestore.instance;
    _storage = FirebaseStorage.instance;
    _collection = 'studyMaterials';
    _storagePath = 'study_materials';
  }

  /// Save a study material to Firebase
  Future<void> saveMaterial(StudyMaterial material) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final materialData = material.toMap();

      await _firestore
          .collection(_collection)
          .doc(material.id)
          .set(materialData);
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image to Firebase Storage and return the download URL
  Future<String> uploadImage(File imageFile, String materialId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Validate file size before upload (50MB max for study materials)
      if (!FileSizeValidator.isValidStudyMaterial(imageFile)) {
        throw Exception(
          FileSizeValidator.getFileSizeErrorMessage(
            imageFile,
            FileSizeValidator.studyMaterialMaxSizeMB,
          ),
        );
      }

      final fileName =
          '${materialId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('$_storagePath/$userId/$fileName');

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  /// Get all study materials for the current user
  Future<List<StudyMaterial>> getUserMaterials() async {
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

      final materials =
          querySnapshot.docs
              .map((doc) => StudyMaterial.fromMap(doc.data()))
              .toList();

      return materials;
    } catch (e) {
      return [];
    }
  }

  /// Get study materials with pagination
  Future<List<StudyMaterial>> getUserMaterialsPaginated({
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

      final materials =
          querySnapshot.docs
              .map(
                (doc) =>
                    StudyMaterial.fromMap(doc.data() as Map<String, dynamic>),
              )
              .toList();

      return materials;
    } catch (e) {
      return [];
    }
  }

  /// Update an existing study material
  Future<void> updateMaterial(StudyMaterial material) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      if (material.userId != userId) {
        throw Exception('Not authorized to update this material');
      }

      final materialData = material.toMap();
      materialData['updatedAt'] = Timestamp.now();

      await _firestore
          .collection(_collection)
          .doc(material.id)
          .update(materialData);
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a study material
  Future<void> deleteMaterial(String materialId) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get the material to check ownership and get image URL
      final docSnapshot =
          await _firestore.collection(_collection).doc(materialId).get();

      if (!docSnapshot.exists) {
        throw Exception('Study material not found');
      }

      final material = StudyMaterial.fromMap(docSnapshot.data()!);
      if (material.userId != userId) {
        throw Exception('Not authorized to delete this material');
      }

      // Delete the image from storage if it exists
      if (material.firebaseStoragePath != null) {
        try {
          await _storage.refFromURL(material.firebaseStoragePath!).delete();
        } catch (e) {
          debugPrint('Warning: Could not delete image from storage: $e');
          // Continue with document deletion even if image deletion fails
        }
      }

      // Delete the document
      await _firestore.collection(_collection).doc(materialId).delete();
    } catch (e) {
      rethrow;
    }
  }

  /// Get materials by type
  Future<List<StudyMaterial>> getMaterialsByType(MaterialType type) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final querySnapshot =
          await _firestore
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .where('type', isEqualTo: type.name)
              .orderBy('createdAt', descending: true)
              .get();

      final materials =
          querySnapshot.docs
              .map((doc) => StudyMaterial.fromMap(doc.data()))
              .toList();

      return materials;
    } catch (e) {
      return [];
    }
  }

  /// Search study materials by title or content
  Future<List<StudyMaterial>> searchMaterials(String searchQuery) async {
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

      final materials =
          querySnapshot.docs
              .map((doc) => StudyMaterial.fromMap(doc.data()))
              .toList();

      return materials;
    } catch (e) {
      return [];
    }
  }

  /// Get study material statistics
  Future<Map<String, dynamic>> getMaterialStatistics() async {
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

      final materials =
          querySnapshot.docs
              .map((doc) => StudyMaterial.fromMap(doc.data()))
              .toList();

      final stats = {
        'totalMaterials': materials.length,
        'imageCount':
            materials.where((m) => m.type == MaterialType.image).length,
        'textCount': materials.where((m) => m.type == MaterialType.text).length,
        'documentCount':
            materials.where((m) => m.type == MaterialType.document).length,
        'completedCount':
            materials.where((m) => m.status == MaterialStatus.completed).length,
        'processingCount':
            materials
                .where((m) => m.status == MaterialStatus.processing)
                .length,
        'failedCount':
            materials.where((m) => m.status == MaterialStatus.failed).length,
      };

      return stats;
    } catch (e) {
      return {};
    }
  }
}
