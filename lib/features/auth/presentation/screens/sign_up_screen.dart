import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/sign_up_status.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirm_password_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirmation_sent_view.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/password_field.dart';

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
            _SignUpForm(
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
            _SignInPrompt(),
          ],
        ),
      ),
    );
  }
}

class _SignUpForm extends StatelessWidget {
  const _SignUpForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirm,
    required this.errorMessage,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirm;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSubmit;

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
              validator: validateEmail,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: passwordController,
              validator: validatePassword,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            ConfirmPasswordField(
              controller: confirmController,
              validator: validateConfirm,
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: KudlitColors.danger400,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: AppConstants.signUpAction,
              isLoading: isLoading,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Already have an account?  ',
          style: TextStyle(fontSize: 12.5, color: cs.onSurface.withAlpha(153)),
        ),
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Text(
            'Sign in',
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
