import 'package:flutter/material.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'auth_submit_button.dart';
import 'confirm_password_field.dart';
import 'email_field.dart';
import 'password_field.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.confirmController,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateConfirm,
    required this.errorMessage,
    required this.isLoading,
    required this.onSubmit,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirm;
  final String? errorMessage;
  final bool isLoading;
  final VoidCallback onSubmit;

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
              validator: validateEmail,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            PasswordField(
              controller: passwordController,
              validator: validatePassword,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            ConfirmPasswordField(
              controller: confirmController,
              validator: validateConfirm,
            ),
            if (errorMessage != null) ...<Widget>[
              const SizedBox(height: 12),
              Text(
                errorMessage!,
                style: const TextStyle(
                  color: KudlitColors.danger400,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: AppConstants.signUpAction,
              isLoading: isLoading,
              onTap: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
