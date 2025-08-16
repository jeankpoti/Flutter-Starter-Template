import 'package:equatable/equatable.dart';

class SolveMathState extends Equatable {
  final String result;
  final bool isLoading;
  final bool isIdentifying;
  final bool isSuccess;
  final bool isError;
  final bool resultShown;
  final DateTime? resultTimestamp;

  const SolveMathState({
    this.result = '',
    this.isLoading = false,
    this.isIdentifying = false,
    this.isSuccess = false,
    this.isError = false,
    this.resultShown = false,
    this.resultTimestamp,
  });

  SolveMathState copyWith({
    String? result,
    bool? isLoading,
    bool? isIdentifying,
    bool? isSuccess,
    bool? isError,
    bool? resultShown,
    DateTime? resultTimestamp,
  }) {
    return SolveMathState(
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      isIdentifying: isIdentifying ?? this.isIdentifying,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      resultShown: resultShown ?? this.resultShown,
      resultTimestamp: resultTimestamp ?? this.resultTimestamp,
    );
  }

  @override
  List<Object?> get props => [
    result,
    isLoading,
    isIdentifying,
    isSuccess,
    isError,
    resultShown,
    resultTimestamp,
  ];
}
