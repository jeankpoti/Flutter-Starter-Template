import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/models/collection.dart';
import '../domain/respository/firebase_collection_repo.dart';
import '../domain/respository/solve_math_repo.dart';
import 'solve_math_state.dart';

class SolveMathCubit extends Cubit<SolveMathState> {
  final SolveMathRepo solveMathRepo;
  final FirebaseCollectionRepo firebaseCollectionRepo;

  SolveMathCubit(this.solveMathRepo, this.firebaseCollectionRepo)
    : super(const SolveMathState());

  Future<void> solveMath(dynamic input) async {
    emit(state.copyWith(isIdentifying: true, resultShown: false));
    try {
      String result;

      // Check if input is text (String) and call appropriate method
      if (input is String && input.trim().isNotEmpty) {
        result = await solveMathRepo.solveMathWithText(input.trim());
      } else {
        result = await solveMathRepo.solveMath(input);
      }

      print('SolveMathCubit: Got result, saving collection...');

      final collection = Collection(
        imagePath: input is File ? input.path : '',
        imageUrl: '',
        solution: result,
      );

      await firebaseCollectionRepo.saveCollection(collection);
      print('SolveMathCubit: Collection saved successfully');

      emit(
        state.copyWith(
          result: result, 
          isIdentifying: false, 
          isSuccess: true, 
          resultShown: false,
          resultTimestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          result:
              'Error solving math problem. Please check your internet connection and try again.',
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
      isIdentifying: false, 
      resultShown: false,
      resultTimestamp: null,
    ));
  }
  
  void markResultAsShown() {
    emit(state.copyWith(resultShown: true));
  }
}
