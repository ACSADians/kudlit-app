import 'package:flutter/material.dart';
import 'package:kudlit_ph/core/design_system/widgets/kudlit_loading_indicator.dart';

/// Primary action button for all auth forms. Matches the visual weight of
/// the welcome screen's [PrimaryAuthOptionButton].
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isLoading ? cs.primary.withAlpha(153) : cs.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x400E1425),
              blurRadius: 10,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        alignment: Alignment.center,
        child: isLoading
            ? KudlitLoadingIndicator(
                size: 20,
                strokeWidth: 2,
                color: cs.onPrimary,
              )
            : Text(
                label,
                style: TextStyle(
                  color: cs.onPrimary,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
      ),
    );
  }
}
