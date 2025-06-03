/*
 TO DO CUBIT - Simple sate management

 Each cubit is a list of todos
*/

import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/repository/account_repo.dart';
import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  // Reference  todo repo
  final AccountRepo accountRepo;
  // final HybridTodoRepo hybridTodoRepo; // <--- We have access to set isSignedIn

  AccountCubit(
    this.accountRepo,
    // this.hybridTodoRepo,
  ) : super(const AccountState());

  // signInWithApple
  Future<void> signInWithApple(context) async {
    //Show loading
    emit(state.copyWith(isLoading: true));

    try {
      final bool signInSuccess = await accountRepo.signInWithApple(context);

      if (signInSuccess) {
        //  On success -> isLoading: false, no error message
        emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
      } else {
        // On failure (as indicated by repo) -> isLoading: false, isSuccess: false.
        // Error message should have been shown by the repository method.
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMsg: 'Something went wrong',
          ),
        );
      }
    } catch (e) {
      // On unexpected error in cubit -> isLoading: false, error message, isSuccess: false
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  // signInWithGooogle
  Future<void> signInWithGooogle(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      final bool signInSuccess = await accountRepo.signInWithGooogle(context);

      if (signInSuccess) {
        //  On success -> isLoading: false, no error message
        emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
      } else {
        // On failure (as indicated by repo) -> isLoading: false, isSuccess: false. Error message might have been shown by repo.
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMsg: 'Something went wrong',
          ),
        );
      }
    } catch (e) {
      // On error -> isLoading: false, error message, isSuccess: false
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: false,
          errorMsg: 'Something went wrong',
        ),
      );
    }
  }

  // signUpWithEmailAndPassword
  Future<void> signUpWithEmailAndPassword(
    String fullName,
    String email,
    String password,
    context,
  ) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithEmailAndPassword(
        fullName,
        email,
        password,
        context,
      );

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // signInWithEmailAndPassword
  Future<void> signInWithEmailAndPassword(
    String email,
    String password,
    context,
  ) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      final bool signInSuccess = await accountRepo.signInWithEmailAndPassword(
        email,
        password,
        context,
      );

      if (signInSuccess) {
        emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            isSuccess: false,
            errorMsg: "Something went wrong.",
          ),
        );
      }
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: 'Something went wrong.'));
    }
  }

  // signOut
  Future<void> signOut() async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signOut();

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(isLoading: false, isSignOut: true, errorMsg: null));

      // resetSignOut();
      // hybridTodoRepo.isSignedIn = false;
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(
        state.copyWith(
          isLoading: false,
          isSignIn: false,
          errorMsg: e.toString(),
        ),
      );
    }
  }

  void resetSignOut() {
    emit(state.copyWith(isSignOut: false));
  }

  // signUpWithGoogle
  Future<void> signUpWithGoogle(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithGoogle(context);

      //  On success -> isLoading: false, no error message
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          // isSignIn: true,
          errorMsg: null,
        ),
      );
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // signUpWithApple
  Future<void> signUpWithApple(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.signUpWithApple(context);

      //  On success -> isLoading: false, no error message
      emit(
        state.copyWith(
          isLoading: false,
          isSuccess: true,
          // isSignIn: true,
          errorMsg: null,
        ),
      );
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  // resetPassword
  Future<void> resetPassword(context, email) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.resetPassword(context, email);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  Future<void> deleteUserWithHisData(context) async {
    try {
      //Show loading
      emit(state.copyWith(isLoading: true));

      await accountRepo.deleteUserWithHisData(context);

      //  On success -> isLoading: false, no error message
      emit(state.copyWith(isLoading: false, isSuccess: true, errorMsg: null));
    } catch (e) {
      // On error -> isLoading: false, error message
      emit(state.copyWith(isLoading: false, errorMsg: e.toString()));
    }
  }

  bool checkSignInStatus() {
    return state.isSignIn;
  }
}
