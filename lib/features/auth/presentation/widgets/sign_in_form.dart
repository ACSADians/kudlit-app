import 'package:flutter/material.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'auth_submit_button.dart';
import 'email_field.dart';
import 'forgot_password_link.dart';
import 'password_field.dart';

class SignInForm extends StatelessWidget {
  const SignInForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
    required this.errorMessage,
    required this.onSubmit,
    required this.onForgotPassword,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return AppConstants.emailRequiredMessage;
    final bool valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) return AppConstants.invalidEmailMessage;
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppConstants.passwordRequiredMessage;
    }
    return null;
  }

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
              validator: _validateEmail,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: passwordController,
              validator: _validatePassword,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => onSubmit(),
            ),
            ForgotPasswordLink(onTap: onForgotPassword),
            const SizedBox(height: 4),
            if (errorMessage != null) ...<Widget>[
              Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
            ],
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
