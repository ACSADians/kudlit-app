import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirm_password_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
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
    if (value == null || value.trim().isEmpty) return 'Email is required.';
    final bool valid = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(value.trim());
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

  String _mapFailure(Failure f) {
    return f.when(
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
  }

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
        if (needsConfirmation) {
          setState(() {
            _isLoading = false;
            _confirmationSent = true;
          });
        }
        // If auto-confirmed, the auth stream emits and the router redirects.
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmationSent) {
      return const _ConfirmationSentView();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'Join Kudlit',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create an account to start translating Baybayin.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 32),
                EmailField(
                  controller: _emailController,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _passwordController,
                  errorText: null,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 16),
                ConfirmPasswordField(
                  controller: _confirmController,
                  validator: _validateConfirm,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                AuthButton(
                  label: 'Create Account',
                  isLoading: _isLoading,
                  onPressed: _onSignUp,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmationSentView extends StatelessWidget {
  const _ConfirmationSentView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_read_outlined,
                size: 72,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Check your inbox',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'We sent a confirmation link to your email. '
                'Click it to activate your account.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to Sign In'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
