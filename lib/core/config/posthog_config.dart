/// PostHog configuration
///
/// Replace YOUR_POSTHOG_API_KEY with your actual PostHog project API key.
/// You can find this in PostHog Settings > Project > Project API Key
class PostHogConfig {
  /// Your PostHog project API key
  /// Get this from: PostHog Dashboard > Settings > Project > Project API Key
  static const String apiKey =
      'YOUR_POSTHOG_API_KEY';

  /// PostHog host URL
  /// - US Cloud: https://us.i.posthog.com
  /// - EU Cloud: https://eu.i.posthog.com
  /// - Self-hosted: Your custom URL
  static const String host = 'https://us.i.posthog.com';
}
