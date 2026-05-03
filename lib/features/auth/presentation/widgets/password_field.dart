import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:kudlit_ph/app/constants.dart';

part 'password_field.g.dart';

@riverpod
class PasswordVisible extends _$PasswordVisible {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class PasswordField extends ConsumerWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.errorText,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String? errorText;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isVisible = ref.watch(passwordVisibleProvider);
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      textInputAction: textInputAction,
      onFieldSubmitted: onSubmitted,
      validator: validator,
      decoration: InputDecoration(
        labelText: AppConstants.passwordLabel,
        errorText: errorText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          onPressed: () => ref.read(passwordVisibleProvider.notifier).toggle(),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
