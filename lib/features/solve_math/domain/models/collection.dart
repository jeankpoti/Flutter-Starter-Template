import 'package:equatable/equatable.dart';

class Collection extends Equatable {
  final String? id;
  final String? imageUrl;
  final String? imagePath;
  final String? description;
  final DateTime? createdAt;

  Collection({
    this.id,
    required this.imageUrl,
    this.imagePath,
    this.description,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // For local or remote serialization
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      description: json['description'] as String?,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'] as String)
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'imageUrl': imageUrl,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Helper copyWith for immutability
  Collection copyWith({
    // String? id,
    String? imageUrl,
    String? imagePath,
    String? description,
  }) {
    return Collection(
      // id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? createdAt,
    );
  }

  @override
  String toString() => 'Collection(id: $id, imageUrl: $imageUrl)';

  @override
  List<Object?> get props => [imageUrl, imagePath, description, createdAt];
}
