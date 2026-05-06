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
    required this.onContinueWithPhone,
    super.key,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final VoidCallback onContinueWithPhone;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _RememberMeToggle(),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(child: ForgotPasswordLink(onTap: onForgotPassword)),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: _AuxiliaryAuthLink(
                      label: 'Continue with Phone Number',
                      onTap: onContinueWithPhone,
                      maxLines: 2,
                    ),
                  ),
                ),
              ],
            ),
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

class _RememberMeToggle extends StatefulWidget {
  const _RememberMeToggle();

  @override
  State<_RememberMeToggle> createState() => _RememberMeToggleState();
}

class _RememberMeToggleState extends State<_RememberMeToggle> {
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color muted = cs.onSurface.withAlpha(153);

    return Semantics(
      button: true,
      checked: _rememberMe,
      label: 'Remember me',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => setState(() => _rememberMe = !_rememberMe),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _CheckBox(checked: _rememberMe),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Remember me',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: checked ? cs.primary : cs.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? cs.primary : cs.outlineVariant,
          width: 1.25,
        ),
      ),
      child: checked ? Icon(Icons.check, size: 10, color: cs.onPrimary) : null,
    );
  }
}

class _AuxiliaryAuthLink extends StatelessWidget {
  const _AuxiliaryAuthLink({
    required this.label,
    required this.onTap,
    this.maxLines = 1,
  });

  final String label;
  final VoidCallback onTap;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        label,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11.5,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
