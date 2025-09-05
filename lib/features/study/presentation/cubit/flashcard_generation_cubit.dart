import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import '../../domain/repository/flashcard_generation_repository.dart';
import '../../data/services/flashcard_generation_service.dart';
import '../../../subscription/presentation/subscription_cubit.dart';

/// State for flashcard generation
class FlashcardGenerationState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final String? errorMsg;
  final List<FlashcardContent> generatedCards;

  const FlashcardGenerationState({
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMsg,
    this.generatedCards = const [],
  });

  FlashcardGenerationState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? errorMsg,
    List<FlashcardContent>? generatedCards,
  }) {
    return FlashcardGenerationState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMsg: errorMsg,
      generatedCards: generatedCards ?? this.generatedCards,
    );
  }

  @override
  List<Object?> get props => [isLoading, isSuccess, errorMsg, generatedCards];
}

/// Cubit for managing flashcard generation from various sources
class FlashcardGenerationCubit extends Cubit<FlashcardGenerationState> {
  final FlashcardGenerationRepository _repository;
  final SubscriptionCubit _subscriptionCubit;

  FlashcardGenerationCubit(this._repository, this._subscriptionCubit) : super(const FlashcardGenerationState());

  /// Generate flashcards from camera
  Future<void> generateFromCamera() async {
    try {
      // Check subscription first
      await _subscriptionCubit.loadSubscriptionStatus();
      final isSubscribed = _subscriptionCubit.state.isSubscribed;
      if (!isSubscribed) {
        try {
          final result = await RevenueCatUI.presentPaywallIfNeeded('premium_flashcard_generation');
          if (result == PaywallResult.notPresented || result == PaywallResult.cancelled) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;
          if (!newStatus) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
        } catch (e) {
          emit(state.copyWith(
            errorMsg: 'Unable to verify subscription status.',
          ));
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
        try {
          final result = await RevenueCatUI.presentPaywallIfNeeded('premium_flashcard_generation');
          if (result == PaywallResult.notPresented || result == PaywallResult.cancelled) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;
          if (!newStatus) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
        } catch (e) {
          emit(state.copyWith(
            errorMsg: 'Unable to verify subscription status.',
          ));
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
        try {
          final result = await RevenueCatUI.presentPaywallIfNeeded('premium_flashcard_generation');
          if (result == PaywallResult.notPresented || result == PaywallResult.cancelled) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
          // Reload subscription status to check if user subscribed
          await _subscriptionCubit.loadSubscriptionStatus();
          final newStatus = _subscriptionCubit.state.isSubscribed;
          if (!newStatus) {
            emit(state.copyWith(
              errorMsg: 'AI flashcard generation requires a premium subscription.',
            ));
            return;
          }
        } catch (e) {
          emit(state.copyWith(
            errorMsg: 'Unable to verify subscription status.',
          ));
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
}