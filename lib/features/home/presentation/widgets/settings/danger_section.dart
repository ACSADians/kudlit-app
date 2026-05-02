import 'package:flutter/material.dart';

import 'profile_nav_row.dart';
import 'settings_card.dart';
import 'settings_section_label.dart';

class DangerSection extends StatelessWidget {
  const DangerSection({super.key, required this.onActionTap});

  final void Function(String message) onActionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'Danger Zone'),
        SettingsCard(
          children: <Widget>[
            ProfileNavRow(
              icon: Icons.delete_forever_outlined,
              title: 'Delete account',
              subtitle: 'Permanently remove your data and account.',
              isDestructive: true,
              isSoon: true,
              onTap: () =>
                  onActionTap('Account deletion flow will be available soon.'),
            ),
          ],
        ),
      ],
    );
  }
}
