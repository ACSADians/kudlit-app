import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';

import 'login_button.dart';
import 'profile_button.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);
    final AuthUser? user = ref.watch(authNotifierProvider).valueOrNull;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? cs.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/brand/BaybayInscribe-AppIcon.webp',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 9),
              const Text(
                'Kudlit',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.4,
                ),
              ),
              const Spacer(),
              if (user == null)
                LoginButton(onTap: () => context.go(AppConstants.routeLogin))
              else
                const ProfileButton(),
            ],
          ),
        ),
      ),
    );
  }
}
