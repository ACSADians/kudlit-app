import 'package:flutter/material.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_drag_handle.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_sheet_headline.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/email_field.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  bool _hasSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _hasSent = true;
    });
  }

  String? _validateEmail(String? value) {
    final String email = value?.trim() ?? '';
    if (email.isEmpty) return AppConstants.emailRequiredMessage;
    final bool valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (!valid) return AppConstants.invalidEmailMessage;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      heroFraction: 0.38,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyPhone.webp',
        bubbleText: 'Almost there — enter your email.',
        showBackButton: true,
        showLanguageToggle: false,
      ),
      sheet: AuthSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AuthDragHandle(),
            const SizedBox(height: 10),
            const AuthSheetHeadline(
              title: 'Reset password',
              subtitle: 'Enter your email and we will prepare a reset link.',
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: EmailField(
                controller: _emailController,
                validator: _validateEmail,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),
            ),
            const SizedBox(height: 16),
            AuthSubmitButton(
              label: _hasSent ? 'Send again' : 'Send reset link',
              isLoading: false,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
