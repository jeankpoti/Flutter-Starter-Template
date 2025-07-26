import 'package:flutter/material.dart';

import 'text_widgets.dart';

class ElevatedButtonWidget extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final double? width;
  final double? height;

  const ElevatedButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 300,
      height: height ?? 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: LabelLargeText(
          text,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }
}
