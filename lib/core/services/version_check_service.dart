import 'package:package_info_plus/package_info_plus.dart';
import 'ad_config_service.dart';

/// Service for checking if the app requires a mandatory update.
/// Compares the current app version with the minimum required version from Remote Config.
class VersionCheckService {
  static final VersionCheckService _instance = VersionCheckService._internal();

  factory VersionCheckService() {
    return _instance;
  }

  VersionCheckService._internal();

  /// Returns true if an update is required (either soft or hard).
  Future<bool> isUpdateAvailable() async {
    try {
      final minVersion = AdConfigService.getMinRequiredVersion();
      if (minVersion.isEmpty) return false;

      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion =
          '${packageInfo.version}+${packageInfo.buildNumber}';

      return _isVersionBelow(currentVersion, minVersion);
    } catch (e) {
      return false;
    }
  }

  /// Returns true if a HARD update is mandatory.
  Future<bool> isForceUpdateRequired() async {
    if (!AdConfigService.isForceUpdateEnabled()) return false;
    return await isUpdateAvailable();
  }

  /// Compares two version strings in the format "major.minor.patch+build".
  /// Returns true if current is strictly below minimum.
  bool _isVersionBelow(String current, String minimum) {
    try {
      final currentParts = current.split('+');
      final minParts = minimum.split('+');

      final currentVer = currentParts[0];
      final minVer = minParts[0];

      final currentBuild =
          currentParts.length > 1 ? int.tryParse(currentParts[1]) ?? 0 : 0;
      final minBuild = minParts.length > 1 ? int.tryParse(minParts[1]) ?? 0 : 0;

      final v1 =
          currentVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final v2 = minVer.split('.').map((e) => int.tryParse(e) ?? 0).toList();

      for (var i = 0; i < 3; i++) {
        final part1 = i < v1.length ? v1[i] : 0;
        final part2 = i < v2.length ? v2[i] : 0;

        if (part1 < part2) return true;
        if (part1 > part2) return false;
      }

      return currentBuild < minBuild;
    } catch (e) {
      return false;
    }
  }
}
