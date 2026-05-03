import 'package:flutter/material.dart';
import 'package:kudlit_ph/core/design_system/widgets/kudlit_loading_indicator.dart';

class AuthButton extends StatelessWidget {
  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const KudlitLoadingIndicator(
                size: 20,
                strokeWidth: 2,
                color: Colors.white,
              )
            : Text(label),
      ),
    );
  }
}
