import 'package:flutter/material.dart';

/// Headline and subhead shown at the top of the login bottom sheet.
class LoginBottomSheetHeadline extends StatelessWidget {
  const LoginBottomSheetHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Text(
          'Welcome, ka-Baybayin!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Sign in to save your progress and earn badges.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface.withAlpha(153),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
