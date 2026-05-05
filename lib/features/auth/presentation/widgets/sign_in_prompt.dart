import 'package:flutter/material.dart';

import 'auth_text_link.dart';

class SignInPrompt extends StatelessWidget {
  const SignInPrompt({required this.onSignIn, super.key});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'Already have an account?',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        AuthTextLink(label: 'Sign in', onTap: onSignIn),
      ],
    );
  }
}
