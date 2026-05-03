import 'package:flutter/material.dart';

import 'secondary_auth_option_button.dart';

/// Two-column row of secondary auth options: Email and Google.
class LoginSecondaryAuthRow extends StatelessWidget {
  const LoginSecondaryAuthRow({
    required this.onContinueWithEmail,
    required this.onContinueWithGoogle,
    super.key,
  });

  final VoidCallback onContinueWithEmail;
  final VoidCallback onContinueWithGoogle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: SecondaryAuthOptionButton(
            icon: Icons.mail_outline,
            label: 'Email',
            onTap: onContinueWithEmail,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SecondaryAuthOptionButton(
            imagePath: 'assets/brand/google.icon.webp',
            label: 'Google',
            onTap: onContinueWithGoogle,
          ),
        ),
      ],
    );
  }
}
