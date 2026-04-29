import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(
          'Privacy Policy\n\n'
          'Kudlit collects account data needed for authentication and app '
          'functionality.\n\n'
          'We use this information to provide sign-in, personalization, and '
          'core app features.\n\n'
          'We do not sell your personal data. Data may be processed by trusted '
          'service providers required to run the app.\n\n'
          'By continuing to use Kudlit, you acknowledge this policy.',
        ),
      ),
    );
  }
}
