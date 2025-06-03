import 'package:flutter/material.dart';

class BodySmallTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  final int? maxLine;
  final TextAlign? textAlign;
  const BodySmallTextWidget({
    super.key,
    required this.text,
    this.color,
    this.maxLine,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: color),
      maxLines: maxLine,
      textAlign: textAlign,
    );
  }
}
