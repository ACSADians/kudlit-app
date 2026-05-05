import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';

import '../widgets/login_bottom_sheet.dart';
import '../widgets/login_hero.dart';
import 'phone_sign_in_screen.dart';
import 'sign_in_screen.dart';

/// Login / welcome screen. Shows the Butty hero and auth-method options.
/// Tapping "Continue with Email" pushes [SignInScreen] via the Navigator.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;

  String _mapFailure(Failure failure) => failure.when(
    network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
    emailAlreadyInUse: () => AppConstants.unexpectedError,
    weakPassword: () => AppConstants.unexpectedError,
    tooManyRequests: () => AppConstants.tooManyAttemptsMessage,
    invalidCredentials: () => AppConstants.invalidCredentialsMessage,
    userNotFound: () => AppConstants.noAccountFoundMessage,
    sessionExpired: () => AppConstants.sessionExpiredMessage,
    passwordResetEmailSent: () => AppConstants.unexpectedError,
    unknown: (String msg) => msg,
  );

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

  Future<void> _onContinueWithGoogle(BuildContext context) async {
    if (_isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    final Either<Failure, Unit> result = await ref
        .read(authNotifierProvider.notifier)
        .signInWithGoogle();
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    result.match((Failure failure) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_mapFailure(failure))));
    }, (_) {});
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool landscape = screenSize.width > screenSize.height;
    final Widget authSheet = LoginBottomSheet(
      onContinueWithPhone: () => _onContinueWithPhone(context),
      onContinueWithEmail: () => _onContinueWithEmail(context),
      onContinueWithGoogle: () => _onContinueWithGoogle(context),
      onCreateAccount: () => _onCreateAccount(context),
      onForgotPassword: () => _onForgotPassword(context),
      onContinueAsGuest: () => _onContinueAsGuest(context),
    );

    if (landscape) {
      return Scaffold(
        body: Row(
          children: <Widget>[
            const Expanded(flex: 4, child: LoginHero()),
            Expanded(flex: 7, child: SafeArea(left: false, child: authSheet)),
          ],
        ),
      );
    }

    final double heroHeight = screenSize.height * 0.52;

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
            child: authSheet,
          ),
        ],
      ),
    );
  }
}
