import 'package:flutter/material.dart';

class TitleSmallTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  const TitleSmallTextWidget({super.key, required this.text, this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall!.copyWith(color: color),
    );
  }
}
