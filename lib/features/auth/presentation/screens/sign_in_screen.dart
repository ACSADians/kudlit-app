import 'package:flutter/material.dart';

import 'reset_password_screen.dart';
import 'sign_up_screen.dart';
import 'home_screen.dart';
import '../widgets/auth_form_scaffold.dart';
import '../widgets/email_field.dart';
import '../widgets/password_field.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const HomeScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  void _openResetPassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const ResetPasswordScreen(),
      ),
    );
  }

  void _openSignUp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthFormScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to continue your Baybayin practice.',
      formKey: _formKey,
      primaryActionLabel: 'Sign in',
      onPrimaryAction: _submit,
      footer: AuthFooterAction(
        prompt: 'No account yet?',
        actionLabel: 'Create account',
        onPressed: _openSignUp,
      ),
      children: <Widget>[
        EmailField(controller: _emailController),
        PasswordField(
          controller: _passwordController,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _openResetPassword,
            child: const Text('Forgot password?'),
          ),
        ),
      ],
    );
  }
}
