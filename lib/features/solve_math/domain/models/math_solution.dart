import 'package:equatable/equatable.dart';
import 'dart:typed_data';

class MathSolution extends Equatable {
  final String text;
  final List<Uint8List> images;

  const MathSolution({
    required this.text,
    this.images = const [],
  });

  @override
  List<Object?> get props => [text, images];
}