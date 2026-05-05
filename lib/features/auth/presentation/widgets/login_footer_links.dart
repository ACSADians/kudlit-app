import 'package:flutter/material.dart';

import 'auth_text_link.dart';

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
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 2,
          children: <Widget>[
            Semantics(
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
                          Text(
                            'Remember me',
                            style: TextStyle(fontSize: 12.5, color: muted),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            AuthTextLink(
              label: 'Forgot password?',
              semanticLabel: 'Reset forgotten password',
              onTap: widget.onForgotPassword,
            ),
          ],
        ),
        const SizedBox(height: 1),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: <Widget>[
            Text('New here?', style: TextStyle(fontSize: 12.5, color: muted)),
            AuthTextLink(
              label: 'Create an account',
              onTap: widget.onCreateAccount,
            ),
          ],
        ),
        const SizedBox(height: 0),
        Center(
          child: Semantics(
            button: true,
            label: 'Continue as guest',
            child: TextButton.icon(
              onPressed: widget.onContinueAsGuest,
              style: TextButton.styleFrom(
                foregroundColor: subtle,
                minimumSize: const Size(44, 44),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                tapTargetSize: MaterialTapTargetSize.padded,
                textStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              icon: Icon(Icons.arrow_forward, size: 14, color: subtle),
              label: const Text('Continue as guest'),
            ),
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
