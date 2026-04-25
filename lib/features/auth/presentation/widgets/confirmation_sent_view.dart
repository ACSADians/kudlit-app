import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/core/design_system/widgets/kudlit_auth_shell.dart';

class ConfirmationSentView extends StatelessWidget {
  const ConfirmationSentView({super.key});

  @override
  Widget build(BuildContext context) {
    return KudlitAuthShell(
      title: AppConstants.confirmationTitle,
      subtitle: AppConstants.confirmationMessage,
      heroAsset: 'assets/brand/ButtyPhone.webp',
      child: Column(
        children: <Widget>[
          Icon(
            Icons.mark_email_read_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go(AppConstants.routeLogin),
              child: const Text(AppConstants.backToSignInAction),
            ),
          ),
        ],
      ),
    );
  }
}
