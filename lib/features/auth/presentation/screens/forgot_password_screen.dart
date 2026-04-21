import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _onReset() async {
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final Either<Failure, Unit> result = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(email: _emailController.text.trim());

    result.fold(
      (Failure f) => setState(() {
        _isLoading = false;
        _isSuccess = false;
        _message = f.when(
          userNotFound: () => 'No account found with this email.',
          tooManyRequests: () => 'Too many requests. Please wait.',
          network: (String msg) => 'Network error: $msg',
          unknown: (String msg) => msg,
          invalidCredentials: () => 'Unexpected error.',
          emailAlreadyInUse: () => 'Unexpected error.',
          weakPassword: () => 'Unexpected error.',
          sessionExpired: () => 'Unexpected error.',
          passwordResetEmailSent: () => 'Unexpected error.',
        );
      }),
      (_) => setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = 'Check your email for a reset link.';
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter your email to receive a reset link.'),
              const SizedBox(height: 24),
              EmailField(controller: _emailController),
              const SizedBox(height: 24),
              AuthButton(
                label: 'Send Reset Email',
                isLoading: _isLoading,
                onPressed: _onReset,
              ),
              if (_message != null) ...[
                const SizedBox(height: 16),
                Text(
                  _message!,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ],
              if (_isSuccess) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Back to login'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
