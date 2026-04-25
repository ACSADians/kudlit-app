import 'package:flutter/material.dart';

import '../widgets/auth_form_scaffold.dart';
import '../widgets/email_field.dart';

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

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: 'Reset password',
      subtitle: 'Enter your email and we will prepare a reset flow.',
      formKey: _formKey,
      primaryActionLabel: _hasSent ? 'Send again' : 'Send reset link',
      onPrimaryAction: _submit,
      statusMessage: _hasSent
          ? 'Reset flow preview sent. Backend email delivery is not connected yet.'
          : null,
      children: <Widget>[
        EmailField(
          controller: _emailController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
      ],
    );
  }
}
