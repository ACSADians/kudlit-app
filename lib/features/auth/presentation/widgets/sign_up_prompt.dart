import 'package:flutter/material.dart';

import 'auth_text_link.dart';

class SignUpPrompt extends StatelessWidget {
  const SignUpPrompt({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text(
          'New here?',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        AuthTextLink(label: 'Create an account', onTap: onCreateAccount),
      ],
    );
  }
}
