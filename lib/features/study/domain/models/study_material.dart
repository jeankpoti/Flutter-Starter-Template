import 'package:cloud_firestore/cloud_firestore.dart';

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

class StudyMaterial {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final MaterialType type;
  final MaterialStatus status;
  final String? content; // For text materials
  final String? imagePath; // For image materials
  final String? firebaseStoragePath; // Firebase storage reference
  final List<String> extractedTopics;
  final String? aiAnalysis;
  final String difficultyLevel; // Elementary, High School, College
  final DateTime createdAt;
  final DateTime updatedAt;

  const StudyMaterial({
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

  // Convert to Map for Firestore
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

  // Create from Firestore Map
  factory StudyMaterial.fromMap(Map<String, dynamic> map) {
    return StudyMaterial(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      type: MaterialType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MaterialType.text,
      ),
      status: MaterialStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => MaterialStatus.processing,
      ),
      content: map['content'],
      imagePath: map['imagePath'],
      firebaseStoragePath: map['firebaseStoragePath'],
      extractedTopics: List<String>.from(map['extractedTopics'] ?? []),
      aiAnalysis: map['aiAnalysis'],
      difficultyLevel: map['difficultyLevel'] ?? 'High School',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Copy with method for updates
  StudyMaterial copyWith({
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
    return StudyMaterial(
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
  String toString() {
    return 'StudyMaterial(id: $id, title: $title, type: $type, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StudyMaterial && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}