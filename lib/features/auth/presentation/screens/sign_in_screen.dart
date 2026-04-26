import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';

import '../widgets/auth_screen_shell.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/email_field.dart';
import '../widgets/login_hero.dart';
import '../widgets/password_field.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';

/// Email + password sign-in screen.
/// Same hero + bottom-sheet layout as the welcome screen — back button
/// replaces the language toggle, Butty waves the user back.
class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _mapFailure(Failure f) => f.when(
    network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
    emailAlreadyInUse: () => AppConstants.unexpectedError,
    weakPassword: () => AppConstants.weakPasswordMessage,
    tooManyRequests: () => AppConstants.tooManyAttemptsMessage,
    invalidCredentials: () => 'Incorrect email or password.',
    userNotFound: () => AppConstants.noAccountFoundMessage,
    sessionExpired: () => AppConstants.unexpectedError,
    passwordResetEmailSent: () => AppConstants.unexpectedError,
    unknown: (String msg) => msg,
  );

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final Either<Failure, AuthUser> result = await ref
        .read(authNotifierProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    result.fold(
      (Failure f) => setState(() {
        _isLoading = false;
        _errorMessage = _mapFailure(f);
      }),
      (_) {
        // Auth state stream updates AuthNotifier; the GoRouter redirect
        // will move us to /home automatically. Pop any Navigator pages
        // pushed on top of /login so we end up on the router's redirect
        // target instead of stuck behind a stale MaterialPageRoute.
        final NavigatorState navigator = Navigator.of(context);
        while (navigator.canPop()) {
          navigator.pop();
        }
      },
    );
  }

  void _openResetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ResetPasswordScreen()),
    );
  }

  void _openSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        bubbleText: 'Great to see you again!',
        showBackButton: true,
        showLanguageToggle: false,
      ),
      sheet: AuthSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AuthDragHandle(),
            const SizedBox(height: 10),
            const AuthSheetHeadline(
              title: 'Welcome back',
              subtitle: 'Sign in to continue your Baybayin practice.',
            ),
            const SizedBox(height: 20),
            _SignInForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onSubmit: _submit,
              onForgotPassword: _openResetPassword,
            ),
            const SizedBox(height: 20),
            _SignUpPrompt(onCreateAccount: _openSignUp),
          ],
        ),
      ),
    );
  }
}

class _SignInForm extends StatelessWidget {
  const _SignInForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            EmailField(
              controller: emailController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
            ),
            _ForgotPasswordLink(onTap: onForgotPassword),
            const SizedBox(height: 4),
            if (errorMessage != null) ...<Widget>[
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
            AuthSubmitButton(
              label: 'Sign in',
              isLoading: isLoading,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        ),
        child: Text(
          'Forgot password?',
          style: TextStyle(
            fontSize: 11.5,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'New here?  ',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        GestureDetector(
          onTap: onCreateAccount,
          child: Text(
            'Create an account',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
          ),
        ),
      ],
    );
  }
}
