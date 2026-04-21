import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/password_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  String _mapFailureToMessage(Object? error) {
    if (error is! Failure) return 'An unexpected error occurred.';
    return error.when(
      network: (String msg) => 'Network error: $msg',
      invalidCredentials: () => 'Invalid email or password.',
      userNotFound: () => 'No account found with this email.',
      emailAlreadyInUse: () => 'Email already in use.',
      weakPassword: () => 'Password is too weak.',
      tooManyRequests: () => 'Too many attempts. Please wait.',
      sessionExpired: () => 'Session expired. Please sign in again.',
      passwordResetEmailSent: () => 'Password reset email sent.',
      unknown: (String msg) => msg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthUser?> authState = ref.watch(authNotifierProvider);
    final String? errorMessage =
        authState.hasError ? _mapFailureToMessage(authState.error) : null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Kudlit',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              EmailField(controller: _emailController),
              const SizedBox(height: 16),
              PasswordField(controller: _passwordController),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push('/forgot-password'),
                  child: const Text('Forgot password?'),
                ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 16),
              AuthButton(
                label: 'Sign In',
                isLoading: authState.isLoading,
                onPressed: _onSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
