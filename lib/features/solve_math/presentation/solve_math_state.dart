import 'package:equatable/equatable.dart';
import 'dart:typed_data';

class SolveMathState extends Equatable {
  final String result;
  final List<Uint8List> generatedImages;
  final bool isLoading;
  final bool isIdentifying;
  final bool isSuccess;
  final bool isError;
  final bool resultShown;
  final DateTime? resultTimestamp;
  final bool isShowingAd;
  final String? errorMsg;

  const SolveMathState({
    this.result = '',
    this.generatedImages = const [],
    this.isLoading = false,
    this.isIdentifying = false,
    this.isSuccess = false,
    this.isError = false,
    this.resultShown = false,
    this.resultTimestamp,
    this.isShowingAd = false,
    this.errorMsg,
  });

  SolveMathState copyWith({
    String? result,
    List<Uint8List>? generatedImages,
    bool? isLoading,
    bool? isIdentifying,
    bool? isSuccess,
    bool? isError,
    bool? resultShown,
    DateTime? resultTimestamp,
    bool? isShowingAd,
    String? errorMsg,
  }) {
    return SolveMathState(
      result: result ?? this.result,
      generatedImages: generatedImages ?? this.generatedImages,
      isLoading: isLoading ?? this.isLoading,
      isIdentifying: isIdentifying ?? this.isIdentifying,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      resultShown: resultShown ?? this.resultShown,
      resultTimestamp: resultTimestamp ?? this.resultTimestamp,
      isShowingAd: isShowingAd ?? this.isShowingAd,
      errorMsg: errorMsg,
    );
  }

  @override
  List<Object?> get props => [
    result,
    generatedImages,
    isLoading,
    isIdentifying,
    isSuccess,
    isError,
    resultShown,
    resultTimestamp,
    isShowingAd,
    errorMsg,
  ];
}
