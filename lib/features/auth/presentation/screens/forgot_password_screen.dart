import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
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
          userNotFound: () => AppConstants.noAccountFoundMessage,
          tooManyRequests: () => AppConstants.tooManyRequestsMessage,
          network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
          unknown: (String msg) => msg,
          invalidCredentials: () => AppConstants.unexpectedError,
          emailAlreadyInUse: () => AppConstants.unexpectedError,
          weakPassword: () => AppConstants.unexpectedError,
          sessionExpired: () => AppConstants.unexpectedError,
          passwordResetEmailSent: () => AppConstants.unexpectedError,
        );
      }),
      (_) => setState(() {
        _isLoading = false;
        _isSuccess = true;
        _message = AppConstants.resetEmailSentSuccessMessage;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.resetPasswordTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(AppConstants.resetPasswordSubtitle),
              const SizedBox(height: 24),
              EmailField(controller: _emailController),
              const SizedBox(height: 24),
              AuthButton(
                label: AppConstants.sendResetEmailAction,
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
                  onPressed: () => context.go(AppConstants.routeLogin),
                  child: const Text(AppConstants.backToLoginAction),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
