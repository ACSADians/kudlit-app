import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/account_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/preferences_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/settings_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/sign_out_tile.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AuthUser?> authState = ref.watch(authNotifierProvider);
    final AuthUser? user = authState.valueOrNull;
    final double bottom = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            const SettingsHeader(),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(0, 8, 0, bottom + 24),
                children: <Widget>[
                  AccountSection(user: user),
                  const SizedBox(height: 24),
                  const PreferencesSection(),
                  if (user != null || authState.isLoading) ...<Widget>[
                    const SizedBox(height: 24),
                    SignOutTile(
                      isLoading: authState.isLoading,
                      onTap: () async {
                        await ref.read(authNotifierProvider.notifier).signOut();
                        if (context.mounted) {
                          context.go(AppConstants.routeLogin);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
