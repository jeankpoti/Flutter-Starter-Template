import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/study_material_entity.dart';

/// Data model for study material with Firestore integration
class StudyMaterialModel extends StudyMaterialEntity {
  const StudyMaterialModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.type,
    required super.status,
    super.content,
    super.imagePath,
    super.firebaseStoragePath,
    super.extractedTopics = const [],
    super.aiAnalysis,
    required super.difficultyLevel,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from entity
  factory StudyMaterialModel.fromEntity(StudyMaterialEntity entity) {
    return StudyMaterialModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      type: entity.type,
      status: entity.status,
      content: entity.content,
      imagePath: entity.imagePath,
      firebaseStoragePath: entity.firebaseStoragePath,
      extractedTopics: entity.extractedTopics,
      aiAnalysis: entity.aiAnalysis,
      difficultyLevel: entity.difficultyLevel,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type.name,
      'status': status.name,
      'content': content,
      'imagePath': imagePath,
      'firebaseStoragePath': firebaseStoragePath,
      'extractedTopics': extractedTopics,
      'aiAnalysis': aiAnalysis,
      'difficultyLevel': difficultyLevel,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create from Firestore document
  factory StudyMaterialModel.fromMap(Map<String, dynamic> map) {
    return StudyMaterialModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      type: _parseType(map['type']),
      status: _parseStatus(map['status']),
      content: map['content'],
      imagePath: map['imagePath'],
      firebaseStoragePath: map['firebaseStoragePath'],
      extractedTopics: List<String>.from(map['extractedTopics'] ?? []),
      aiAnalysis: map['aiAnalysis'],
      difficultyLevel: map['difficultyLevel'] ?? 'Elementary',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  /// Create from Firestore DocumentSnapshot
  factory StudyMaterialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudyMaterialModel.fromMap(data);
  }

  /// Parse MaterialType from string
  static MaterialType _parseType(dynamic type) {
    if (type == null) return MaterialType.text;
    switch (type.toString().toLowerCase()) {
      case 'image':
        return MaterialType.image;
      case 'document':
        return MaterialType.document;
      case 'text':
      default:
        return MaterialType.text;
    }
  }

  /// Parse MaterialStatus from string
  static MaterialStatus _parseStatus(dynamic status) {
    if (status == null) return MaterialStatus.processing;
    switch (status.toString().toLowerCase()) {
      case 'completed':
        return MaterialStatus.completed;
      case 'failed':
        return MaterialStatus.failed;
      case 'processing':
      default:
        return MaterialStatus.processing;
    }
  }

  /// Parse DateTime from Firestore Timestamp
  static DateTime _parseDateTime(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }
    if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  /// Convert to entity
  StudyMaterialEntity toEntity() {
    return StudyMaterialEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      type: type,
      status: status,
      content: content,
      imagePath: imagePath,
      firebaseStoragePath: firebaseStoragePath,
      extractedTopics: extractedTopics,
      aiAnalysis: aiAnalysis,
      difficultyLevel: difficultyLevel,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}