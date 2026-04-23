import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/confirm_password_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/password_field.dart';

class SignUpFormBody extends StatelessWidget {
  const SignUpFormBody({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.isLoading,
    required this.onSignUp,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirm,
    this.errorMessage,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final bool isLoading;
  final VoidCallback onSignUp;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirm;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        Text(
          AppConstants.signUpHeading,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          AppConstants.signUpSubtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 32),
        EmailField(controller: emailController, validator: validateEmail),
        const SizedBox(height: 16),
        PasswordField(
          controller: passwordController,
          validator: validatePassword,
        ),
        const SizedBox(height: 16),
        ConfirmPasswordField(
          controller: confirmController,
          validator: validateConfirm,
        ),
        const SizedBox(height: 24),
        if (errorMessage != null) ...[
          Text(
            errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 16),
        ],
        AuthButton(
          label: AppConstants.signUpAction,
          isLoading: isLoading,
          onPressed: onSignUp,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            const Text(
              AppConstants.existingAccountPrompt,
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () => context.go(AppConstants.routeLogin),
              child: const Text(AppConstants.loginAction),
            ),
          ],
        ),
      ],
    );
  }
}
