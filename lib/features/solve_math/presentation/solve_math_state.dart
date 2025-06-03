import 'package:equatable/equatable.dart';

class SolveMathState extends Equatable {
  final String result;
  final bool isLoading;
  final bool isIdentifying;
  final bool isSuccess;
  final bool isError;

  const SolveMathState({
    this.result = '',
    this.isLoading = false,
    this.isIdentifying = false,
    this.isSuccess = false,
    this.isError = false,
  });

  SolveMathState copyWith({
    String? result,
    bool? isLoading,
    bool? isIdentifying,
    bool? isSuccess,
    bool? isError,
  }) {
    return SolveMathState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      isIdentifying: isIdentifying ?? this.isIdentifying,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
    );
  }

  @override
  List<Object?> get props => [
    result,
    isLoading,
    isIdentifying,
    isSuccess,
    isError,
  ];
}
