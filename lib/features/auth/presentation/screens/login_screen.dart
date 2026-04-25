import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/widgets/kudlit_auth_shell.dart';
import 'package:kudlit_ph/core/error/failures.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_form_body.dart';

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
    await ref
        .read(authNotifierProvider.notifier)
        .signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  String _mapFailureToMessage(Object? error) {
    if (error is! Failure) return AppConstants.unexpectedErrorOccurred;
    return error.when(
      network: (String msg) => '${AppConstants.networkErrorPrefix}$msg',
      invalidCredentials: () => AppConstants.invalidCredentialsMessage,
      userNotFound: () => AppConstants.noAccountFoundMessage,
      emailAlreadyInUse: () => AppConstants.emailAlreadyInUseMessage,
      weakPassword: () => AppConstants.weakPasswordShortMessage,
      tooManyRequests: () => AppConstants.tooManyAttemptsMessage,
      sessionExpired: () => AppConstants.sessionExpiredMessage,
      passwordResetEmailSent: () => AppConstants.passwordResetEmailSentMessage,
      unknown: (String msg) => msg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<AuthUser?> authState = ref.watch(authNotifierProvider);
    final String? errorMessage = authState.hasError
        ? _mapFailureToMessage(authState.error)
        : null;

    return KudlitAuthShell(
      title: AppConstants.loginTitle,
      subtitle: AppConstants.loginSubtitle,
      heroAsset: 'assets/brand/ButtyWave.webp',
      child: LoginFormBody(
        emailController: _emailController,
        passwordController: _passwordController,
        isLoading: authState.isLoading,
        errorMessage: errorMessage,
        onSignIn: _onSignIn,
      ),
    );
  }
}
