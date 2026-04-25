import 'package:flutter/material.dart';

class NameField extends StatelessWidget {
  const NameField({required this.controller, super.key});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofillHints: const <String>[AutofillHints.name],
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'Juan dela Cruz',
        border: OutlineInputBorder(),
      ),
      validator: _validateName,
    );
  }

  String? _validateName(String? value) {
    if ((value?.trim() ?? '').isEmpty) {
      return 'Enter your name.';
    }

    return null;
  }
}
