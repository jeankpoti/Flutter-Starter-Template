import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Collection extends Equatable {
  final String? id;
  final String? imageUrl;
  final String? imagePath;
  final String? solution;
  final DateTime? createdAt;

  Collection({
    this.id,
    required this.imageUrl,
    this.imagePath,
    this.solution,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // For local or remote serialization
  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      id: json['id'] as String?,
      imageUrl: json['imageUrl'] as String? ?? '',
      solution: json['solution'] as String?,
      createdAt:
          json['createdAt'] != null
              ? (json['createdAt'] is Timestamp 
                  ? (json['createdAt'] as Timestamp).toDate()
                  : json['createdAt'] is String 
                      ? DateTime.parse(json['createdAt'] as String)
                      : (json['createdAt'] as DateTime))
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'imageUrl': imageUrl,
      'solution': solution,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  // Helper copyWith for immutability
  Collection copyWith({
    // String? id,
    String? imageUrl,
    String? imagePath,
    String? solution,
  }) {
    return Collection(
      // id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      solution: solution ?? this.solution,
      createdAt: createdAt ?? createdAt,
    );
  }

  @override
  String toString() => 'Collection(id: $id, imageUrl: $imageUrl)';

  @override
  List<Object?> get props => [imageUrl, imagePath, solution, createdAt];
}
