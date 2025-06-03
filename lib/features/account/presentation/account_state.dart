import 'package:equatable/equatable.dart';

class AccountState extends Equatable {
  final bool isLoading;
  final bool isSuccess;
  final bool isSignIn;
  final bool isSignInSuccess;
  final bool isSignOut;
  final bool isSignUpSuccess;
  final String? errorMsg;

  const AccountState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isSignIn = false,
    this.isSignInSuccess = false,
    this.isSignOut = false,
    this.isSignUpSuccess = false,
    this.errorMsg,
  });

  // Copy with helper for immutability
  AccountState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isSignIn,
    bool? isSignInSuccess,
    bool? isSignOut,
    bool? isSignUpSuccess,
    String? errorMsg,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isSignIn: isSignIn ?? this.isSignIn,
      isSignInSuccess: isSignInSuccess ?? this.isSignInSuccess,
      isSignOut: isSignOut ?? this.isSignOut,
      isSignUpSuccess: isSignUpSuccess ?? this.isSignUpSuccess,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMsg,
    isSuccess,
    isSignIn,
    isSignInSuccess,
    isSignOut,
    isSignUpSuccess,
  ];
}
