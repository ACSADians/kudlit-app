import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_screen_shell.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/auth_submit_button.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/login_hero.dart';

class ConfirmationSentView extends StatelessWidget {
  const ConfirmationSentView({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      heroFraction: 0.42,
      hero: const LoginHero(
        buttyAsset: 'assets/brand/ButtyPhone.webp',
        bubbleText: 'Check your inbox!',
        showBackButton: false,
        showLanguageToggle: false,
      ),
      sheet: AuthSheet(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const AuthDragHandle(),
            const SizedBox(height: 10),
            const AuthSheetHeadline(
              title: 'Check your inbox',
              subtitle: AppConstants.confirmationMessage,
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.mark_email_read_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            AuthSubmitButton(
              label: AppConstants.backToSignInAction,
              isLoading: false,
              onTap: () => context.go(AppConstants.routeLogin),
            ),
          ],
        ),
      ),
    );
  }
}
