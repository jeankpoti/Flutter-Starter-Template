import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Tracks Firebase initialization status for graceful degradation
/// when Firebase is not configured.
class FirebaseConfig {
  static bool _isInitialized = false;

  /// Whether Firebase was successfully initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize Firebase and track status
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      _isInitialized = true;
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      _isInitialized = false;
      debugPrint('Firebase not configured: $e');
      debugPrint('Run "flutterfire configure" to set up Firebase');
    }
  }
}
