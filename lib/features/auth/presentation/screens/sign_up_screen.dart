import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirmation_sent_view.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/sign_up_form_body.dart';

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
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final bool valid =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
    if (!valid) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required.';
    if (value.length < 6) return 'Password must be at least 6 characters.';
    return null;
  }

  String? _validateConfirm(String? value) {
    if (value != _passwordController.text) return 'Passwords do not match.';
    return null;
  }

  String _mapFailure(Failure f) => f.when(
    network: (String msg) => 'Network error: $msg',
    emailAlreadyInUse: () => 'An account with this email already exists.',
    weakPassword: () => 'Password is too weak. Use at least 6 characters.',
    tooManyRequests: () => 'Too many attempts. Please wait.',
    invalidCredentials: () => 'Unexpected error. Please try again.',
    userNotFound: () => 'Unexpected error. Please try again.',
    sessionExpired: () => 'Unexpected error. Please try again.',
    passwordResetEmailSent: () => 'Unexpected error. Please try again.',
    unknown: (String msg) => msg,
  );

  Future<void> _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final Either<Failure, bool> result = await ref
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
      (bool needsConfirmation) {
        if (needsConfirmation) setState(() => _confirmationSent = true);
        // Auto-confirmed: auth stream emits and router redirects to /home.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmationSent) return const ConfirmationSentView();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SignUpFormBody(
              emailController: _emailController,
              passwordController: _passwordController,
              confirmController: _confirmController,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onSignUp: _onSignUp,
              validateEmail: _validateEmail,
              validatePassword: _validatePassword,
              validateConfirm: _validateConfirm,
            ),
          ),
        ),
      ),
    );
  }
}
