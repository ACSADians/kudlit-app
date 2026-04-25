import 'package:flutter/material.dart';

import 'sign_in_screen.dart';
import 'sign_up_screen.dart';
import '../widgets/auth_header.dart';

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  void _openSignIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignInScreen(),
      ),
    );
  }

  void _openSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Expanded(
                child: AuthHeader(
                  title: 'Kudlit',
                  subtitle:
                      'Read Baybayin, practice kudlit marks, and keep your '
                      'learning progress ready for every session.',
                ),
              ),
              FilledButton(
                onPressed: () => _openSignUp(context),
                child: const Text('Create account'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => _openSignIn(context),
                child: const Text('Sign in'),
              ),
              const SizedBox(height: 16),
              Text(
                'Authentication is UI-only for now.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
