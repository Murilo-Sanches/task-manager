import 'package:flutter/material.dart';

abstract class Styles {
  static InputDecoration textFormInput(String label) {
    return InputDecoration(
      fillColor: Colors.grey.shade200,
      filled: true,
      labelStyle: TextStyle(
        color: Colors.grey.shade700,
      ),
      labelText: label,
      border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide.none),
    );
  }
}
