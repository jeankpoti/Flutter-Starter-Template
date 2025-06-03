import 'package:flutter/material.dart';

class TextFormFieldWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String labelText;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final int maxLine;

  final TextInputType? keyboardType;
  const TextFormFieldWidget({
    super.key,
    this.labelText = '',
    this.hintText = '',
    this.controller,
    this.obscureText = false,
    this.validator,
    this.suffixIcon,
    this.keyboardType,
    this.maxLine = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      autocorrect: true,
      controller: controller,
      keyboardType: keyboardType,
      minLines: 1,
      maxLines: maxLine,
      obscureText: obscureText,
      style: TextStyle(color: Theme.of(context).colorScheme.primary),
      cursorColor: Theme.of(context).colorScheme.primary,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        fillColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        suffixIcon: suffixIcon,
      ),
      validator: (value) => value!.isEmpty ? validator!(value) : null,
    );
  }
}
