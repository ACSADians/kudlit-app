import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key, required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: 'Log in',
      child: Tooltip(
        message: 'Log in',
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: compact ? 30 : null,
            height: compact ? 30 : null,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 0 : 14,
              vertical: compact ? 0 : 7,
            ),
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: compact
                ? Icon(
                    Icons.login_rounded,
                    size: 16,
                    color: cs.onPrimary,
                    semanticLabel: 'Log in',
                  )
                : Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.onPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
