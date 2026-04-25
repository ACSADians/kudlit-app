import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Footer section of the login bottom sheet: remember-me toggle,
/// forgot password, create account prompt, and guest access link.
class LoginFooterLinks extends StatefulWidget {
  const LoginFooterLinks({
    required this.onCreateAccount,
    required this.onForgotPassword,
    required this.onContinueAsGuest,
    super.key,
  });

  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;
  final VoidCallback onContinueAsGuest;

  @override
  State<LoginFooterLinks> createState() => _LoginFooterLinksState();
}

class _LoginFooterLinksState extends State<LoginFooterLinks> {
  bool _rememberMe = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () => setState(() => _rememberMe = !_rememberMe),
              child: Row(
                children: <Widget>[
                  _CheckBox(checked: _rememberMe),
                  const SizedBox(width: 7),
                  const Text(
                    'Remember me',
                    style: TextStyle(fontSize: 12, color: KudlitColors.grey200),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onForgotPassword,
              child: const Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 11.5,
                  color: KudlitColors.blue400,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(
            text: 'New here?  ',
            style: const TextStyle(fontSize: 12.5, color: KudlitColors.grey200),
            children: <InlineSpan>[
              WidgetSpan(
                child: GestureDetector(
                  onTap: widget.onCreateAccount,
                  child: const Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: KudlitColors.blue300,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: KudlitColors.blue300,
                    ),
                  ),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onContinueAsGuest,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              Text(
                'Continue as guest',
                style: TextStyle(fontSize: 11.5, color: KudlitColors.grey300),
              ),
              SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 11, color: KudlitColors.grey300),
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        color: checked ? KudlitColors.blue300 : Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked ? KudlitColors.blue300 : KudlitColors.grey400,
          width: 1.25,
        ),
      ),
      child: checked
          ? const Icon(Icons.check, size: 10, color: KudlitColors.blue900)
          : null,
    );
  }
}
