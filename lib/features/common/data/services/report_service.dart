import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/content_report.dart';

class ReportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _reportsCollection = 'content_reports';

  Future<void> submitReport({
    required String contentId,
    required ContentType contentType,
    required ReportType reportType,
    required String description,
    required String contentSnapshot,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User must be authenticated to submit a report');
    }

    final report = ContentReport.create(
      userId: user.uid,
      contentId: contentId,
      contentType: contentType,
      reportType: reportType,
      description: description,
      contentSnapshot: contentSnapshot,
    );

    await _firestore
        .collection(_reportsCollection)
        .doc(report.id)
        .set(report.toFirestore());
  }

  Future<List<ContentReport>> getUserReports() async {
    final user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    final querySnapshot = await _firestore
        .collection(_reportsCollection)
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => ContentReport.fromFirestore(doc))
        .toList();
  }

  Future<bool> hasUserReportedContent(String contentId) async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    final querySnapshot = await _firestore
        .collection(_reportsCollection)
        .where('userId', isEqualTo: user.uid)
        .where('contentId', isEqualTo: contentId)
        .limit(1)
        .get();

    return querySnapshot.docs.isNotEmpty;
  }
}