import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

import '../widgets/login_bottom_sheet.dart';
import '../widgets/login_hero.dart';
import 'phone_sign_in_screen.dart';
import 'sign_in_screen.dart';

/// Login / welcome screen. Shows the Butty hero and auth-method options.
/// Tapping "Continue with Email" pushes [SignInScreen] via the Navigator.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _onContinueWithEmail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const SignInScreen(),
      ),
    );
  }

  void _onContinueWithPhone(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => const PhoneSignInScreen(),
      ),
    );
  }

  void _onContinueWithGoogle(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google sign-in — coming soon!')),
    );
  }

  void _onCreateAccount(BuildContext context) {
    context.go(AppConstants.routeSignUp);
  }

  void _onForgotPassword(BuildContext context) {
    context.push(AppConstants.routeForgotPassword);
  }

  void _onContinueAsGuest(BuildContext context) {
    context.go(AppConstants.routeHome);
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double heroHeight = screenHeight * 0.52;

    return Scaffold(
      body: Stack(
        // StackFit.expand ensures the stack fills the full screen so that
        // Positioned(bottom: 0) means the bottom of the screen, not the hero.
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: heroHeight,
            child: const LoginHero(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: heroHeight - 22,
            bottom: 0,
            child: LoginBottomSheet(
              onContinueWithPhone: () => _onContinueWithPhone(context),
              onContinueWithEmail: () => _onContinueWithEmail(context),
              onContinueWithGoogle: () => _onContinueWithGoogle(context),
              onCreateAccount: () => _onCreateAccount(context),
              onForgotPassword: () => _onForgotPassword(context),
              onContinueAsGuest: () => _onContinueAsGuest(context),
            ),
          ),
        ],
      ),
    );
  }
}
