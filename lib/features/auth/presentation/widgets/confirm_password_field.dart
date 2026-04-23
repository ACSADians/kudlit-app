import 'package:flutter/material.dart';
import 'package:kudlit_ph/app/constants.dart';

class ConfirmPasswordField extends StatefulWidget {
  const ConfirmPasswordField({
    super.key,
    required this.controller,
    this.errorText,
    this.validator,
  });

  final TextEditingController controller;
  final String? errorText;
  final String? Function(String?)? validator;

  @override
  State<ConfirmPasswordField> createState() => _ConfirmPasswordFieldState();
}

class _ConfirmPasswordFieldState extends State<ConfirmPasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_visible,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: AppConstants.confirmPasswordLabel,
        errorText: widget.errorText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(_visible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => setState(() => _visible = !_visible),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
