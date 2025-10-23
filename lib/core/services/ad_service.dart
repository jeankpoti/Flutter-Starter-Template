import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static AdService? _instance;
  static AdService get instance => _instance ??= AdService._();

  AdService._();

  // Test Ad Unit IDs (replace with actual IDs for production)
  static const String _rewardedAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  // static const String _rewardedAdUnitIdIOS =
  //     'ca-app-pub-9068204541773057~7141744607';
  // static const String _rewardedAdUnitIdAndroid =
  //     'ca-app-pub-3940256099942544/5224354917';
  static const String _rewardedAdUnitIdIOS =
      'ca-app-pub-3940256099942544/1712485313';

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  // Initialize the Mobile Ads SDK
  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  // Get the appropriate rewarded ad unit ID for the platform
  String get _rewardedAdUnitId {
    return Platform.isAndroid ? _rewardedAdUnitIdAndroid : _rewardedAdUnitIdIOS;
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

  // Show rewarded ad and return whether user earned reward
  Future<bool> showRewardedAd() async {
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
