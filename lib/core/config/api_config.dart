/// Centralized API and Backend Configuration
///
/// Replace placeholders with your actual Cloud Functions or API endpoints.
class ApiConfig {
  /// Base Cloud Functions URL
  /// e.g. https://us-central1-YOUR_FIREBASE_PROJECT_ID.cloudfunctions.net
  static const String cloudFunctionsBaseUrl =
      'https://us-central1-YOUR_PROJECT_ID.cloudfunctions.net';

  /// Endpoint to verify whether an Apple user already exists
  static const String checkAppleUserExistsUrl =
      '$cloudFunctionsBaseUrl/checkAppleUserExists';

  /// Endpoint to verify whether a Google user already exists
  static const String checkGoogleUserExistsUrl =
      '$cloudFunctionsBaseUrl/checkGoogleUserExists';
}
