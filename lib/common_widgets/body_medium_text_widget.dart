import 'package:flutter/material.dart';

class BodyMediumTextWidget extends StatelessWidget {
  final String text;
  final Color? color;
  final int? maxLine;
  final TextAlign? textAlign;
  const BodyMediumTextWidget({
    super.key,
    required this.text,
    this.maxLine,
    this.color,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
        color: color ?? Theme.of(context).colorScheme.tertiary,
      ),
      textAlign: textAlign ?? TextAlign.start,
      // softWrap: true,
      // overflow: TextOverflow.ellipsis,
      maxLines: maxLine,
    );
  }
}
