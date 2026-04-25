import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_theme.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/password_field.dart';

class LoginFormBody extends StatelessWidget {
  const LoginFormBody({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.onSignIn,
    this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final VoidCallback onSignIn;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'ᜃᜓᜇ᜔ᜎᜒᜆ᜔',
          textAlign: TextAlign.center,
          style: KudlitTheme.baybayinDisplay(context),
        ),
        const SizedBox(height: 32),
        Text(
          AppConstants.loginTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.loginHelper,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        EmailField(controller: emailController),
        const SizedBox(height: 16),
        PasswordField(controller: passwordController),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => context.push(AppConstants.routeForgotPassword),
            child: const Text(AppConstants.forgotPasswordAction),
          ),
        ),
        if (errorMessage != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        const SizedBox(height: 16),
        AuthButton(
          label: AppConstants.loginAction,
          isLoading: isLoading,
          onPressed: onSignIn,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: <Widget>[
            const Text(
              AppConstants.noAccountPrompt,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => context.push(AppConstants.routeSignUp),
              child: const Text(AppConstants.createOneAction),
            ),
          ],
        ),
      ],
    );
  }
}
