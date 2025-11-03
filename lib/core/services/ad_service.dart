import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_config_service.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  // Test Ad Unit IDs
  static const String _testRewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/1712485313';

  // Production Ad Unit IDs
  static const String _prodRewardedAdUnitIdAndroid =
      'ca-app-pub-9068204541773057/5566109912';
  static const String _prodRewardedAdUnitIdIOS =
      'ca-app-pub-9068204541773057/3523897368';

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Get the appropriate rewarded ad unit ID for the platform
  String get _rewardedAdUnitId {
    final useTestAds = AdConfigService.shouldUseTestAds();
    
    if (Platform.isAndroid) {
      return useTestAds ? _testRewardedAdUnitIdAndroid : _prodRewardedAdUnitIdAndroid;
    } else {
      return useTestAds ? _testRewardedAdUnitIdIOS : _prodRewardedAdUnitIdIOS;
    }
  }

  // Load a rewarded ad
  Future<void> loadRewardedAd() async {
    if (_isRewardedAdLoading || _rewardedAd != null) {
      return;
    }

    _isRewardedAdLoading = true;

    try {
      await RewardedAd.load(
        adUnitId: _rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            _rewardedAd = ad;
            _isRewardedAdLoading = false;

            // Set the full screen content callback
            _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                ad.dispose();
                _rewardedAd = null;
                // Preload the next ad in background
                Future.delayed(const Duration(seconds: 1), () {
                  loadRewardedAd();
                });
              },
              onAdFailedToShowFullScreenContent: (
                RewardedAd ad,
                AdError error,
              ) {
                ad.dispose();
                _rewardedAd = null;
                // Preload the next ad in background
                Future.delayed(const Duration(seconds: 1), () {
                  loadRewardedAd();
                });
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            _isRewardedAdLoading = false;
            // Retry loading after delay
            Future.delayed(const Duration(seconds: 30), () {
              loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      _isRewardedAdLoading = false;
      // Retry loading after delay on network/other errors
      Future.delayed(const Duration(seconds: 30), () {
        loadRewardedAd();
      });
    }
  }

  // Check if ads should be shown for current user
  bool shouldShowAds([String? userEmail]) {
    return AdConfigService.shouldShowAds(userEmail);
  }

  // Show rewarded ad and return whether user earned reward
  Future<bool> showRewardedAd([String? userEmail]) async {
    // Check if ads should be shown for this user
    if (!shouldShowAds(userEmail)) {
      return true; // Grant reward without showing ad
    }

    if (_rewardedAd == null) {
      return false; // No ad available
    }

    final Completer<bool> completer = Completer<bool>();
    bool rewardEarned = false;

    try {
      _rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          rewardEarned = true;
        },
      );

      _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (RewardedAd ad) {
          ad.dispose();
          _rewardedAd = null;
          if (!completer.isCompleted) {
            completer.complete(rewardEarned);
          }
          // Preload the next ad in background
          Future.delayed(const Duration(seconds: 1), () {
            loadRewardedAd();
          });
        },
        onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
          ad.dispose();
          _rewardedAd = null;
          if (!completer.isCompleted) {
            completer.complete(false);
          }
          // Preload the next ad in background
          Future.delayed(const Duration(seconds: 1), () {
            loadRewardedAd();
          });
        },
      );

      // Add timeout to prevent hanging
      return completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          if (_rewardedAd != null) {
            _rewardedAd?.dispose();
            _rewardedAd = null;
          }
          return false;
        },
      );
    } catch (e) {
      if (_rewardedAd != null) {
        _rewardedAd?.dispose();
        _rewardedAd = null;
      }
      return false;
    }
  }

  // Check if rewarded ad is ready to show
  bool isRewardedAdReady() {
    return _rewardedAd != null;
  }

  // Dispose ads
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
