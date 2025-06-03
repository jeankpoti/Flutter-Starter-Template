import 'package:flutter/material.dart';

class TitleMediumTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleMediumTextWidget({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium!.copyWith(color: color),
    );
  }
}
