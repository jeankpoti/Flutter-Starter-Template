import 'package:posthog_flutter/posthog_flutter.dart';

/// PostHog analytics service
///
/// Mirrors the same pattern as AnalyticsService for consistency.
/// All methods silently fail if PostHog is not initialized to avoid
/// interrupting app flow.
class PostHogService {
  static Posthog? _posthog;
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  /// Initialize PostHog analytics
  static Future<void> initialize({
    required String apiKey,
    required String host,
  }) async {
    if (_isInitialized) return;

    // Skip initialization if API key is not set
    if (apiKey.isEmpty || apiKey == 'YOUR_POSTHOG_API_KEY') {
      return;
    }

    try {
      final config = PostHogConfig(apiKey);
      config.host = host;
      config.captureApplicationLifecycleEvents = true;
      config.debug = false;

      // Enable Session Replay
      config.sessionReplay = true;
      config.sessionReplayConfig.maskAllTexts = false;
      config.sessionReplayConfig.maskAllImages = false;
      config.sessionReplayConfig.throttleDelay =
          const Duration(milliseconds: 1000);

      await Posthog().setup(config);
      _posthog = Posthog();
      _isInitialized = true;
    } catch (e) {
      // Log error but don't crash - analytics should be non-blocking
      _isInitialized = false;
    }
  }

  /// Capture an event with optional properties
  static Future<void> capture({
    required String name,
    Map<String, Object?>? properties,
  }) async {
    if (!_isInitialized || _posthog == null) return;

    try {
      // Filter out null values
      final Map<String, Object>? filteredProperties = properties != null
          ? Map.fromEntries(
              properties.entries
                  .where((entry) => entry.value != null)
                  .map((entry) => MapEntry(entry.key, entry.value!)),
            )
          : null;

      await _posthog!.capture(
        eventName: name,
        properties: filteredProperties,
      );
    } catch (e) {
      // Silently fail - don't interrupt app flow for analytics
    }
  }

  /// Log screen view
  static Future<void> screen({
    required String screenName,
    Map<String, Object>? properties,
  }) async {
    if (!_isInitialized || _posthog == null) return;

    try {
      await _posthog!.screen(
        screenName: screenName,
        properties: properties,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Identify user (set user ID)
  static Future<void> identify(String userId) async {
    if (!_isInitialized || _posthog == null) return;

    try {
      await _posthog!.identify(userId: userId);
    } catch (e) {
      // Silently fail
    }
  }

  /// Set user properties
  static Future<void> setUserProperties(Map<String, Object> properties) async {
    if (!_isInitialized || _posthog == null) return;

    try {
      await _posthog!.identify(
        userId: '', // Will use existing identity
        userProperties: properties,
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Reset identity (for logout)
  static Future<void> reset() async {
    if (!_isInitialized || _posthog == null) return;

    try {
      await _posthog!.reset();
    } catch (e) {
      // Silently fail
    }
  }

  /// Flush events to PostHog (useful before app close)
  static Future<void> flush() async {
    if (!_isInitialized || _posthog == null) return;

    try {
      await _posthog!.flush();
    } catch (e) {
      // Silently fail
    }
  }
}
