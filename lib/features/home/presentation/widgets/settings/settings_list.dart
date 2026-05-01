import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/about_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/account_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/activity_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/danger_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/personalization_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/preferences_section.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/profile_hero_card.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/settings/sign_out_tile.dart';

class SettingsList extends StatelessWidget {
  const SettingsList({
    super.key,
    required this.user,
    required this.isAuthLoading,
    required this.bottomPadding,
    required this.onActionTap,
    required this.onSignOutTap,
  });

  final AuthUser? user;
  final bool isAuthLoading;
  final double bottomPadding;
  final void Function(String message) onActionTap;
  final Future<void> Function() onSignOutTap;

  @override
  Widget build(BuildContext context) {
    final AuthUser? u = user;

    return ListView(
      padding: EdgeInsets.fromLTRB(0, 8, 0, bottomPadding + 32),
      children: <Widget>[
        if (u != null)
          ProfileHeroCard(user: u)
        else
          AccountSection(user: null),
        const SizedBox(height: 28),
        if (u != null) ...<Widget>[
          ActivitySection(onActionTap: onActionTap),
          const SizedBox(height: 24),
        ],
        const PreferencesSection(),
        const SizedBox(height: 24),
        if (u != null) ...<Widget>[
          const PersonalizationSection(),
          const SizedBox(height: 24),
        ],
        const AboutSection(),
        if (u != null || isAuthLoading) ...<Widget>[
          const SizedBox(height: 24),
          SignOutTile(isLoading: isAuthLoading, onTap: onSignOutTap),
        ],
        if (u != null) ...<Widget>[
          const SizedBox(height: 16),
          DangerSection(onActionTap: onActionTap),
        ],
      ],
    );
  }
}
