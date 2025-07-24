import 'package:equatable/equatable.dart';

/// Enums for study material
enum MaterialType {
  image,
  text,
  document,
}

enum MaterialStatus {
  processing,
  completed,
  failed,
}

/// Pure business object for study material
class StudyMaterialEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final MaterialType type;
  final MaterialStatus status;
  final String? content;
  final String? imagePath;
  final String? firebaseStoragePath;
  final List<String> extractedTopics;
  final String? aiAnalysis;
  final String difficultyLevel;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyMaterialEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    required this.status,
    this.content,
    this.imagePath,
    this.firebaseStoragePath,
    this.extractedTopics = const [],
    this.aiAnalysis,
    required this.difficultyLevel,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with modified fields
  StudyMaterialEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    MaterialType? type,
    MaterialStatus? status,
    String? content,
    String? imagePath,
    String? firebaseStoragePath,
    List<String>? extractedTopics,
    String? aiAnalysis,
    String? difficultyLevel,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StudyMaterialEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      firebaseStoragePath: firebaseStoragePath ?? this.firebaseStoragePath,
      extractedTopics: extractedTopics ?? this.extractedTopics,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    type,
    status,
    content,
    imagePath,
    firebaseStoragePath,
    extractedTopics,
    aiAnalysis,
    difficultyLevel,
    createdAt,
    updatedAt,
  ];
}