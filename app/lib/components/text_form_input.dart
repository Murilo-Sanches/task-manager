import 'package:flutter/material.dart';

import 'package:app/design/styles.dart';

class TextFormInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const TextFormInput(
      {super.key,
      required this.label,
      required this.controller,
      this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: Styles.textFormInput(label),
      controller: controller,
      validator: validator,
    );
  }
}
