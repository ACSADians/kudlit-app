import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';

import 'guest_tile.dart';
import 'settings_card.dart';
import 'settings_section_label.dart';
import 'user_tile.dart';

class AccountSection extends StatelessWidget {
  const AccountSection({super.key, required this.user});

  final AuthUser? user;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'Account'),
        SettingsCard(
          children: <Widget>[
            if (user != null) UserTile(user: user!) else const GuestTile(),
          ],
        ),
      ],
    );
  }
}
