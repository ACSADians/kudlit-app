import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Terms of Service')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Terms of Service\n\n'
          'By using Kudlit, you agree to use the app responsibly and in '
          'compliance with applicable laws.\n\n'
          'You are responsible for keeping your account information secure.\n\n'
          'Kudlit may update features and these terms over time. Continued use '
          'means you accept those changes.\n\n'
          'If you do not agree with these terms, please stop using the app.',
        ),
      ),
    );
  }
}
