import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

import 'auth_text_link.dart';
import 'login_auth_or_divider.dart';
import 'login_bottom_sheet_headline.dart';
import 'login_footer_links.dart';
import 'login_secondary_auth_row.dart';
import 'primary_auth_option_button.dart';

/// Floating card that overlaps the login hero, containing all auth options
/// and footer links.
class LoginBottomSheet extends StatelessWidget {
  const LoginBottomSheet({
    required this.onContinueWithEmail,
    required this.onContinueWithGoogle,
    required this.onCreateAccount,
    required this.onContinueAsGuest,
    this.isGoogleLoading = false,
    super.key,
  });

  final VoidCallback onContinueWithEmail;
  final VoidCallback onContinueWithGoogle;
  final VoidCallback onCreateAccount;
  final VoidCallback onContinueAsGuest;
  final bool isGoogleLoading;

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
              minHeight:
                  MediaQuery.sizeOf(context).height * 0.48 -
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
                  icon: Icons.arrow_forward,
                  label: 'Continue as guest',
                  onTap: onContinueAsGuest,
                ),
                const LoginAuthOrDivider(),
                LoginSecondaryAuthRow(
                  onContinueWithEmail: onContinueWithEmail,
                  onContinueWithGoogle: onContinueWithGoogle,
                  isGoogleLoading: isGoogleLoading,
                ),
                const SizedBox(height: 6),
                const _TermsText(),
                const SizedBox(height: 4),
                LoginFooterLinks(onCreateAccount: onCreateAccount),
                const SizedBox(height: 1),
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
    final Color baseColor = Theme.of(
      context,
    ).colorScheme.onSurface.withAlpha(102);
    const TextStyle baseStyle = TextStyle(fontSize: 11, height: 1.35);

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 2,
        children: <Widget>[
          Text(
            'By continuing you agree to our',
            textAlign: TextAlign.center,
            style: baseStyle.copyWith(color: baseColor),
          ),
          AuthTextLink(
            label: 'Terms',
            semanticLabel: 'Open terms of service',
            onTap: () => context.go(AppConstants.routeTerms),
          ),
          Text('and', style: baseStyle.copyWith(color: baseColor)),
          AuthTextLink(
            label: 'Privacy Policy',
            semanticLabel: 'Open privacy policy',
            onTap: () => context.go(AppConstants.routePrivacyPolicy),
          ),
        ],
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
