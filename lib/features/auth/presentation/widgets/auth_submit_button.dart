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
    final bool enabled = !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: isLoading ? cs.primary.withAlpha(153) : cs.primary,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              boxShadow: <BoxShadow>[
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
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
