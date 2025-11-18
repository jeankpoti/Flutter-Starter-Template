import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:math_ai/core/services/app_review_service.dart';
import 'package:math_ai/core/services/ad_service.dart';

import '../domain/models/collection.dart';
import '../domain/models/math_solution.dart';
import '../domain/respository/firebase_collection_repo.dart';
import '../domain/respository/solve_math_repo.dart';
import 'solve_math_state.dart';

class SolveMathCubit extends Cubit<SolveMathState> {
  final SolveMathRepo solveMathRepo;
  final FirebaseCollectionRepo firebaseCollectionRepo;
  final AdService adService;

  SolveMathCubit(this.solveMathRepo, this.firebaseCollectionRepo, this.adService)
    : super(const SolveMathState());

  // Show ad before solving math for free users
  Future<bool> showAdForFreeUser() async {
    // Check if ads should be shown for current user via Remote Config
    if (!adService.shouldShowAds()) {
      return true; // Grant access without showing ad
    }

    emit(state.copyWith(isShowingAd: true, errorMsg: null));
    try {
      // Check if ad is ready
      if (!adService.isRewardedAdReady()) {
        // Try to load ad first
        await adService.loadRewardedAd();
        
        // Wait a moment for ad to load
        await Future.delayed(const Duration(seconds: 2));
        
        if (!adService.isRewardedAdReady()) {
          emit(state.copyWith(isShowingAd: false, errorMsg: 'adFailedToLoad'));
          return true; // Allow user to proceed without ad if loading fails
        }
      }
      
      final adWatched = await adService.showRewardedAd();
      emit(state.copyWith(isShowingAd: false));
      return adWatched;
    } catch (e) {
      emit(state.copyWith(isShowingAd: false, errorMsg: 'adFailedToLoad'));
      // Allow user to proceed if ad fails - don't block functionality
      return true; 
    }
  }

  Future<void> solveMath(dynamic input, {bool isSubscribed = false}) async {
    // For free users, show ad first before solving
    if (!isSubscribed) {
      await showAdForFreeUser();
      // Always proceed - don't block functionality if ads fail
      // The showAdForFreeUser method already handles error messaging
    }

    emit(state.copyWith(isIdentifying: true, resultShown: false, errorMsg: null));
    try {
      MathSolution solution;

      // Check if input is text (String) and call appropriate method
      if (input is String && input.trim().isNotEmpty) {
        solution = await solveMathRepo.solveMathWithText(input.trim());
      } else {
        solution = await solveMathRepo.solveMath(input);
      }

      final collection = Collection(
        imagePath: input is File ? input.path : '',
        imageUrl: '',
        solution: solution.text,
      );

      await firebaseCollectionRepo.saveCollection(collection);

      emit(
        state.copyWith(
          result: solution.text,
          generatedImages: solution.images,
          isIdentifying: false, 
          isSuccess: true, 
          resultShown: false,
          resultTimestamp: DateTime.now(),
        ),
      );
      
      // Increment problems solved counter
      await AppReviewService.incrementProblemsSolved();
    } catch (e) {
      emit(
        state.copyWith(
          result:
              'Error solving math problem. Please check your internet connection and try again.',
          generatedImages: [],
          isIdentifying: false,
          isError: true,
        ),
      );
    }
  }

  Future<void> shareResult(File imageFile, String result) async {
    try {
      final String text = "Math Problem Solution:\n\n$result";

      final params = ShareParams(text: text, files: [XFile(imageFile.path)]);
      await SharePlus.instance.share(params);
    } catch (e) {
      emit(state.copyWith(isError: false));
    }
  }

  Future<void> emptyResult() async {
    emit(state.copyWith(
      result: '',
      generatedImages: [],
      isIdentifying: false, 
      resultShown: false,
      resultTimestamp: null,
    ));
  }
  
  void markResultAsShown() {
    emit(state.copyWith(resultShown: true));
  }

  void clearError() {
    emit(state.copyWith(errorMsg: null));
  }
}
