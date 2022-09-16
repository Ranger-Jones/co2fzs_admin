import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final bool expands;
  final int maxLines;
  final int minLines;
  const TextFieldInput({
    Key? key,
    required this.hintText,
    this.isPass = false,
    required this.textEditingController,
    required this.textInputType,
    this.expands = false,
    this.maxLines = 1,
    this.minLines = 1,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(
      borderSide: Divider.createBorderSide(context),
    );

    return TextField(
      controller: textEditingController,
      expands: expands,
      maxLines: maxLines,
      minLines: minLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: inputBorder,
        focusedBorder: inputBorder,
        enabledBorder: inputBorder,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      style: Theme.of(context).textTheme.bodyText2,
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
