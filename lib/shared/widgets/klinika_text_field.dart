import 'package:flutter/material.dart';

class KlinikaTextField extends StatelessWidget {
  const KlinikaTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.minLines = 1,
    this.maxLines = 1,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final int maxLines;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: hintText),
      onSubmitted: onSubmitted,
    );
  }
}
