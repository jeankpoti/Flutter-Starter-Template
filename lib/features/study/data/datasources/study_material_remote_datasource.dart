import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'dart:io';
import '../../../../core/error/exceptions.dart';
import '../models/study_material_model.dart';

/// Abstract class for remote data source
abstract class StudyMaterialRemoteDataSource {
  Future<List<StudyMaterialModel>> getUserMaterials();
  Future<StudyMaterialModel> getMaterialById(String id);
  Future<void> saveMaterial(StudyMaterialModel material);
  Future<void> updateMaterial(StudyMaterialModel material);
  Future<void> deleteMaterial(String id);
  Future<String> uploadImage(String imagePath, String materialId);
}

/// Implementation of remote data source using Firebase
class StudyMaterialRemoteDataSourceImpl implements StudyMaterialRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final FirebaseAuth auth;
  final String _collection = 'studyMaterials';
  final String _storagePath = 'study_materials';

  StudyMaterialRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    required this.auth,
  });

  String get _currentUserId {
    final userId = auth.currentUser?.uid;
    if (userId == null) {
      throw const AuthException('User not authenticated');
    }
    return userId;
  }

  @override
  Future<List<StudyMaterialModel>> getUserMaterials() async {
    try {
      final querySnapshot = await firestore
          .collection(_collection)
          .where('userId', isEqualTo: _currentUserId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => StudyMaterialModel.fromFirestore(doc))
          .toList();
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to get user materials: ${e.message}', e.code);
    } catch (e) {
      throw ServerException('Unexpected error getting user materials: $e');
    }
  }

  @override
  Future<StudyMaterialModel> getMaterialById(String id) async {
    try {
      final doc = await firestore.collection(_collection).doc(id).get();
      
      if (!doc.exists) {
        throw const ServerException('Study material not found');
      }

      final material = StudyMaterialModel.fromFirestore(doc);
      
      // Verify user owns this material
      if (material.userId != _currentUserId) {
        throw const PermissionException('Access denied to this material');
      }

      return material;
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to get material: ${e.message}', e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error getting material: $e');
    }
  }

  @override
  Future<void> saveMaterial(StudyMaterialModel material) async {
    try {
      // Ensure the material belongs to current user
      if (material.userId != _currentUserId) {
        throw const PermissionException('Cannot save material for another user');
      }

      await firestore
          .collection(_collection)
          .doc(material.id)
          .set(material.toMap());
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to save material: ${e.message}', e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error saving material: $e');
    }
  }

  @override
  Future<void> updateMaterial(StudyMaterialModel material) async {
    try {
      // Verify material exists and user owns it
      await getMaterialById(material.id);

      await firestore
          .collection(_collection)
          .doc(material.id)
          .update(material.toMap());
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to update material: ${e.message}', e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error updating material: $e');
    }
  }

  @override
  Future<void> deleteMaterial(String id) async {
    try {
      // Verify material exists and user owns it
      final material = await getMaterialById(id);

      // Delete from Firestore
      await firestore.collection(_collection).doc(id).delete();

      // Delete from Storage if it has a file
      if (material.firebaseStoragePath != null) {
        try {
          await storage.ref(material.firebaseStoragePath).delete();
        } catch (e) {
          // Log but don't fail if storage deletion fails
          print('Warning: Failed to delete file from storage: $e');
        }
      }
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to delete material: ${e.message}', e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error deleting material: $e');
    }
  }

  @override
  Future<String> uploadImage(String imagePath, String materialId) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) {
        throw const ServerException('Image file not found');
      }

      final ref = storage.ref().child('$_storagePath/$_currentUserId/$materialId.jpg');
      
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } on firebase_core.FirebaseException catch (e) {
      throw ServerException('Failed to upload image: ${e.message}', e.code);
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException('Unexpected error uploading image: $e');
    }
  }
}