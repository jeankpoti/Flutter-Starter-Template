import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/services/ad_service.dart';

class AdCubit extends Cubit<AdState> {
  final AdService _adService;

  AdCubit(this._adService) : super(const AdState());

  // Initialize ads and preload them
  Future<void> initializeAds() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      await AdService.initialize();
      await _adService.loadRewardedAd();
      emit(state.copyWith(
        isLoading: false,
        isInitialized: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMsg: 'Failed to initialize ads: $e',
      ));
    }
  }

  // Show rewarded ad for math solution
  Future<bool> showRewardedAdForSolution() async {
    emit(state.copyWith(isShowingAd: true, errorMsg: null));
    
    try {
      final rewardEarned = await _adService.showRewardedAd();
      
      emit(state.copyWith(
        isShowingAd: false,
        lastAdResult: rewardEarned ? AdResult.rewarded : AdResult.dismissed,
      ));
      
      return rewardEarned;
    } catch (e) {
      emit(state.copyWith(
        isShowingAd: false,
        errorMsg: 'Failed to show ad: $e',
        lastAdResult: AdResult.failed,
      ));
      return false;
    }
  }

  // Check if rewarded ad is ready
  bool isRewardedAdReady() {
    return _adService.isRewardedAdReady();
  }

  // Preload rewarded ad
  Future<void> preloadRewardedAd() async {
    try {
      await _adService.loadRewardedAd();
    } catch (e) {
      emit(state.copyWith(errorMsg: 'Failed to preload ad: $e'));
    }
  }

  // Clear error message
  void clearError() {
    emit(state.copyWith(errorMsg: null));
  }

  // Clear last ad result
  void clearLastResult() {
    emit(state.copyWith(lastAdResult: null));
  }

  @override
  Future<void> close() {
    _adService.dispose();
    return super.close();
  }
}

class AdState extends Equatable {
  final bool isLoading;
  final bool isInitialized;
  final bool isShowingAd;
  final String? errorMsg;
  final AdResult? lastAdResult;

  const AdState({
    this.isLoading = false,
    this.isInitialized = false,
    this.isShowingAd = false,
    this.errorMsg,
    this.lastAdResult,
  });

  AdState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? isShowingAd,
    String? errorMsg,
    AdResult? lastAdResult,
  }) {
    return AdState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isShowingAd: isShowingAd ?? this.isShowingAd,
      errorMsg: errorMsg,
      lastAdResult: lastAdResult,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isInitialized,
    isShowingAd,
    errorMsg,
    lastAdResult,
  ];
}

enum AdResult {
  rewarded,
  dismissed,
  failed,
}