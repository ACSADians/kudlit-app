import 'package:flutter/material.dart';

import 'auth_text_link.dart';

/// Footer section of the login bottom sheet with the create account prompt.
class LoginFooterLinks extends StatelessWidget {
  const LoginFooterLinks({required this.onCreateAccount, super.key});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color muted = cs.onSurface.withAlpha(153);

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        Text('New here?', style: TextStyle(fontSize: 12.5, color: muted)),
        AuthTextLink(label: 'Create an account', onTap: onCreateAccount),
      ],
    );
  }
}
