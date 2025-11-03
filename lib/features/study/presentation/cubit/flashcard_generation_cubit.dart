import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/repository/flashcard_generation_repository.dart';
import '../../data/services/flashcard_generation_service.dart';
import '../../../subscription/presentation/subscription_cubit.dart';
import '../../../../core/services/ad_service.dart';

/// State for flashcard generation
class FlashcardGenerationState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMsg;
  final List<FlashcardContent> generatedCards;
  final bool isShowingAd;

  const FlashcardGenerationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMsg,
    this.generatedCards = const [],
    this.isShowingAd = false,
  });

  FlashcardGenerationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMsg,
    List<FlashcardContent>? generatedCards,
    bool? isShowingAd,
  }) {
    return FlashcardGenerationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMsg: errorMsg,
      generatedCards: generatedCards ?? this.generatedCards,
      isShowingAd: isShowingAd ?? this.isShowingAd,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMsg, generatedCards, isShowingAd];
}

/// Cubit for managing flashcard generation from various sources
class FlashcardGenerationCubit extends Cubit<FlashcardGenerationState> {
  final FlashcardGenerationRepository _repository;
  final SubscriptionCubit _subscriptionCubit;
  final AdService _adService;

  FlashcardGenerationCubit(this._repository, this._subscriptionCubit, this._adService) : super(const FlashcardGenerationState());

  /// Generate flashcards from camera
  Future<void> generateFromCamera() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;
      if (!isSubscribed) {
        await showAdForFreeUser();
        
        // Check if ad failed or user didn't watch
        if (state.errorMsg != null) {
          return;
        }
      }

      emit(state.copyWith(isLoading: true, errorMsg: null));
      
      final flashcardContents = await _repository.generateFromCamera();
      
      if (flashcardContents == null || flashcardContents.isEmpty) {
        // User cancelled camera capture or no content generated
        emit(state.copyWith(isLoading: false));
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        generatedCards: flashcardContents,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMsg: 'Failed to generate flashcards: ${e.toString()}',
      ));
    }
  }

  /// Generate flashcards from gallery
  Future<void> generateFromGallery() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;
      if (!isSubscribed) {
        await showAdForFreeUser();
        
        // Check if ad failed or user didn't watch
        if (state.errorMsg != null) {
          return;
        }
      }

      emit(state.copyWith(isLoading: true, errorMsg: null));
      
      final flashcardContents = await _repository.generateFromGallery();
      
      if (flashcardContents == null || flashcardContents.isEmpty) {
        // User cancelled gallery selection or no content generated
        emit(state.copyWith(isLoading: false));
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        generatedCards: flashcardContents,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMsg: 'Failed to generate flashcards: ${e.toString()}',
      ));
    }
  }

  /// Generate flashcards from file
  Future<void> generateFromFile() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;
      if (!isSubscribed) {
        await showAdForFreeUser();
        
        // Check if ad failed or user didn't watch
        if (state.errorMsg != null) {
          return;
        }
      }

      emit(state.copyWith(isLoading: true, errorMsg: null));
      
      final flashcardContents = await _repository.generateFromFile();
      
      if (flashcardContents == null || flashcardContents.isEmpty) {
        // User cancelled file selection or no content generated
        emit(state.copyWith(isLoading: false));
        return;
      }

      emit(state.copyWith(
        isLoading: false,
        isSuccess: true,
        generatedCards: flashcardContents,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMsg: 'Failed to generate flashcards: ${e.toString()}',
      ));
    }
  }

  /// Clear messages and reset state
  void clearMessages() {
    emit(state.copyWith(errorMsg: null, isSuccess: false));
  }

  /// Clear generated cards
  void clearGeneratedCards() {
    emit(state.copyWith(generatedCards: []));
  }

  /// Show ad for free users before flashcard generation
  Future<void> showAdForFreeUser() async {
    try {
      // Check if ads should be shown for current user via Remote Config
      if (!_adService.shouldShowAds()) {
        return; // Skip ad, allow proceeding
      }

      emit(state.copyWith(isShowingAd: true));
      
      final adResult = await _adService.showRewardedAd();
      
      if (!isClosed) {
        emit(state.copyWith(isShowingAd: false));
        
        if (!adResult) {
          emit(state.copyWith(
            errorMsg: 'watchAdFirst',
          ));
          return;
        }
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isShowingAd: false,
          errorMsg: 'adFailedToLoad',
        ));
      }
    }
  }
}