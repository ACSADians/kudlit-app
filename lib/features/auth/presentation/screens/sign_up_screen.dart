import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/sign_up_status.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_drag_handle.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet_headline.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirmation_sent_view.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/sign_in_prompt.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/sign_up_form.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _isLoading = false;
  bool _confirmationSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppConstants.emailRequiredMessage;
    }
    final bool valid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value.trim());
    if (!valid) return AppConstants.invalidEmailMessage;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequiredMessage;
    }
    if (value.length < 6) return AppConstants.passwordTooShortMessage;
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) {
      return AppConstants.passwordsDoNotMatchMessage;
    }
    return null;
  }

  String _mapFailure(Failure f) => f.when(
    network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
    emailAlreadyInUse: () => AppConstants.emailAlreadyInUseMessage,
    weakPassword: () => AppConstants.weakPasswordMessage,
    tooManyRequests: () => AppConstants.tooManyAttemptsMessage,
    invalidCredentials: () => AppConstants.unexpectedError,
    userNotFound: () => AppConstants.unexpectedError,
    sessionExpired: () => AppConstants.unexpectedError,
    passwordResetEmailSent: () => AppConstants.unexpectedError,
    unknown: (String msg) => msg,
  );

  Future<void> _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final Either<Failure, SignUpStatus> result = await ref
        .read(authNotifierProvider.notifier)
        .signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;
    result.fold(
      (Failure f) => setState(() {
        _isLoading = false;
        _errorMessage = _mapFailure(f);
      }),
      (SignUpStatus signUpStatus) {
        if (signUpStatus == SignUpStatus.confirmationPending) {
          setState(() => _confirmationSent = true);
        }
        // Auto-confirmed: auth stream emits and router redirects to /home.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmationSent) return const ConfirmationSentView();

    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyPaint.webp',
        bubbleText: 'Let\'s get you set up!',
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
              title: 'Create account',
              subtitle: 'Start your Baybayin journey.',
            ),
            const SizedBox(height: 20),
            SignUpForm(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmController: _confirmController,
              validateEmail: _validateEmail,
              validatePassword: _validatePassword,
              validateConfirm: _validateConfirm,
              errorMessage: _errorMessage,
              isLoading: _isLoading,
              onSubmit: _onSignUp,
            ),
            const SizedBox(height: 20),
            SignInPrompt(onSignIn: () => Navigator.of(context).pop()),
          ],
        ),
      ),
    );
  }
}
