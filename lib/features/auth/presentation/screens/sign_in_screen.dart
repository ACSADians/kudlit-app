import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

import '../widgets/auth_screen_shell.dart';
import '../widgets/auth_submit_button.dart';
import '../widgets/email_field.dart';
import '../widgets/login_hero.dart';
import '../widgets/password_field.dart';
import 'home_screen.dart';
import 'reset_password_screen.dart';
import 'sign_up_screen.dart';

/// Email + password sign-in screen.
/// Same hero + bottom-sheet layout as the welcome screen — back button
/// replaces the language toggle, Butty waves the user back.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    // TODO: wire to auth notifier
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (_) => false,
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
    required this.onSubmit,
    required this.onForgotPassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onForgotPassword,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                ),
                child: const Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: KudlitColors.blue400,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
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

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt({required this.onCreateAccount});

  final VoidCallback onCreateAccount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text(
          'New here?  ',
          style: TextStyle(fontSize: 12.5, color: KudlitColors.grey200),
        ),
        GestureDetector(
          onTap: onCreateAccount,
          child: const Text(
            'Create an account',
            style: TextStyle(
              fontSize: 12.5,
              color: KudlitColors.blue300,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
              decorationColor: KudlitColors.blue300,
            ),
          ),
        ),
      ],
    );
  }
}
