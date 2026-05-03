import 'package:flutter/material.dart';

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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color muted = cs.onSurface.withAlpha(153);
    final Color subtle = cs.onSurface.withAlpha(102);

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
                  Text(
                    'Remember me',
                    style: TextStyle(fontSize: 12, color: muted),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onForgotPassword,
              child: Text(
                'Forgot password?',
                style: TextStyle(
                  fontSize: 11.5,
                  color: cs.primary,
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
            style: TextStyle(fontSize: 12.5, color: muted),
            children: <InlineSpan>[
              WidgetSpan(
                child: GestureDetector(
                  onTap: widget.onCreateAccount,
                  child: Text(
                    'Create an account',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: cs.primary,
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
            children: <Widget>[
              Text(
                'Continue as guest',
                style: TextStyle(fontSize: 11.5, color: subtle),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward, size: 11, color: subtle),
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
