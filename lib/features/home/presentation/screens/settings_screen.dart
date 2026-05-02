import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/settings_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/settings_list.dart';

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
              child: SettingsList(
                user: user,
                isAuthLoading: authState.isLoading,
                bottomPadding: bottom,
                onActionTap: (String message) =>
                    _showActionSnackBar(context, message),
                onSignOutTap: () async {
                  await ref.read(authNotifierProvider.notifier).signOut();
                  if (context.mounted) {
                    context.go(AppConstants.routeLogin);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showActionSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
