import 'package:flutter/material.dart';

class TitleLargeTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleLargeTextWidget({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge!.copyWith(color: color),
    );
  }
}
