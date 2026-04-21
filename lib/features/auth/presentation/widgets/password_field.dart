import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  });

  final TextEditingController controller;
  final String? errorText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isVisible = ref.watch(passwordVisibleProvider);
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: errorText,
        prefixIcon: const Icon(Icons.lock_outlined),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () =>
              ref.read(passwordVisibleProvider.notifier).toggle(),
        ),
        border: const OutlineInputBorder(),
      ),
    );
  }
}
