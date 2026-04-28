import 'package:flutter/material.dart';

import 'login_auth_or_divider.dart';
import 'login_bottom_sheet_headline.dart';
import 'login_footer_links.dart';
import 'login_secondary_auth_row.dart';
import 'primary_auth_option_button.dart';

/// Floating card that overlaps the login hero, containing all auth options
/// and footer links.
class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    required this.onContinueWithPhone,
    required this.onContinueWithEmail,
    required this.onContinueWithGoogle,
    required this.onCreateAccount,
    required this.onForgotPassword,
    required this.onContinueAsGuest,
    super.key,
  });

  final VoidCallback onContinueWithPhone;
  final VoidCallback onContinueWithEmail;
  final VoidCallback onContinueWithGoogle;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;
  final VoidCallback onContinueAsGuest;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x260E1425),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.sizeOf(context).height * 0.48 -
                  MediaQuery.paddingOf(context).bottom -
                  24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const LoginBottomSheetHeadline(),
                const SizedBox(height: 12),
                PrimaryAuthOptionButton(
                  icon: Icons.smartphone_outlined,
                  label: 'Continue with Phone Number',
                  onTap: onContinueWithPhone,
                ),
                const LoginAuthOrDivider(),
                LoginSecondaryAuthRow(
                  onContinueWithEmail: onContinueWithEmail,
                  onContinueWithGoogle: onContinueWithGoogle,
                ),
                const SizedBox(height: 10),
                LoginFooterLinks(
                  onCreateAccount: onCreateAccount,
                  onForgotPassword: onForgotPassword,
                  onContinueAsGuest: onContinueAsGuest,
                ),
                const SizedBox(height: 24),
                const _TermsText(),
                const SizedBox(height: 2),
                const _VersionLabel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TermsText extends StatelessWidget {
  const _TermsText();

  @override
  Widget build(BuildContext context) {
    return Text(
      'By continuing you agree to our Terms and Privacy Policy.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
        height: 1.45,
      ),
    );
  }
}

class _VersionLabel extends StatelessWidget {
  const _VersionLabel();

  @override
  Widget build(BuildContext context) {
    return Text(
      'v1.0.0 · build 1',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 9.5,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
        height: 1.3,
      ),
    );
  }
}
