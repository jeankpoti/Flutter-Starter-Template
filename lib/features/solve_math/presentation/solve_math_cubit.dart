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

  Future<void> solveMath(dynamic imageInput) async {
    emit(state.copyWith(isIdentifying: true));
    try {
      final result = await solveMathRepo.solveMath(imageInput);

      //  final firebaseAnimalCubit = context.read<FirebaseAnimalCubit>();
      final collection = Collection(
        imagePath: imageInput?.path ?? '',
        imageUrl: '',
        description: result,
      );
      await firebaseCollectionRepo.saveCollection(collection);

      emit(
        state.copyWith(result: result, isIdentifying: false, isSuccess: true),
      );
    } catch (e) {
      emit(
        state.copyWith(
          result: 'Error identifying animal',
          isIdentifying: false,
        ),
      );
    }
  }

  Future<void> shareResult(File imageFile, String result) async {
    try {
      final String text = "Animal Identification Result:\n\n$result";

      if (imageFile != null) {
        final params = ShareParams(text: text, files: [XFile(imageFile.path)]);
        await SharePlus.instance.share(params);
      } else {
        final params = ShareParams(text: text);
        await SharePlus.instance.share(params);
      }
    } catch (e) {
      emit(state.copyWith(isError: false));
    }
  }

  Future<void> emptyResult() async {
    emit(state.copyWith(result: '', isIdentifying: false));
  }
}
