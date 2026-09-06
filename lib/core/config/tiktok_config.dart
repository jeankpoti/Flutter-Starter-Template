/// TikTok Events SDK configuration
///
/// Replace the placeholder values with your actual TikTok App credentials.
/// You can find these in TikTok Events Manager > Your App
class TikTokConfig {
  /// Your TikTok App ID (used for both platforms)
  /// Get this from: TikTok Events Manager > Your App > Settings
  static const String appId = 'YOUR_TIKTOK_APP_ID';

  /// Android App ID - same as appId unless you have separate IDs
  static const String androidAppId = appId;

  /// TikTok Android ID - same as appId unless you have separate IDs
  static const String tikTokAndroidId = appId;

  /// iOS App ID - same as appId unless you have separate IDs
  static const String iosAppId = appId;

  /// TikTok iOS ID - same as appId unless you have separate IDs
  static const String tikTokIosId = appId;

  /// Enable debug mode for testing events
  /// Set to true during development, false for production
  static const bool debugMode = false;
}
