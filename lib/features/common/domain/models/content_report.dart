import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  inappropriate,
  incorrect,
  harmful,
  spam,
  other,
}

enum ContentType {
  mathSolution,
  quizQuestion,
  quizAnswer,
  studyMaterial,
}

class ContentReport extends Equatable {
  final String id;
  final String userId;
  final String contentId;
  final ContentType contentType;
  final ReportType reportType;
  final String description;
  final String contentSnapshot; // Store the actual content being reported
  final DateTime createdAt;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime? reviewedAt;

  const ContentReport({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.contentType,
    required this.reportType,
    required this.description,
    required this.contentSnapshot,
    required this.createdAt,
    this.status = ReportStatus.pending,
    this.adminNotes,
    this.reviewedAt,
  });

  factory ContentReport.create({
    required String userId,
    required String contentId,
    required ContentType contentType,
    required ReportType reportType,
    required String description,
    required String contentSnapshot,
  }) {
    return ContentReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      contentId: contentId,
      contentType: contentType,
      reportType: reportType,
      description: description,
      contentSnapshot: contentSnapshot,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'contentId': contentId,
      'contentType': contentType.name,
      'reportType': reportType.name,
      'description': description,
      'contentSnapshot': contentSnapshot,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      'adminNotes': adminNotes,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
    };
  }

  factory ContentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContentReport(
      id: doc.id,
      userId: data['userId'] as String,
      contentId: data['contentId'] as String,
      contentType: ContentType.values.firstWhere(
        (e) => e.name == data['contentType'],
      ),
      reportType: ReportType.values.firstWhere(
        (e) => e.name == data['reportType'],
      ),
      description: data['description'] as String,
      contentSnapshot: data['contentSnapshot'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'pending'),
        orElse: () => ReportStatus.pending,
      ),
      adminNotes: data['adminNotes'] as String?,
      reviewedAt: data['reviewedAt'] != null
          ? (data['reviewedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        contentId,
        contentType,
        reportType,
        description,
        contentSnapshot,
        createdAt,
        status,
        adminNotes,
        reviewedAt,
      ];
}

enum ReportStatus {
  pending,
  reviewing,
  resolved,
  dismissed,
}