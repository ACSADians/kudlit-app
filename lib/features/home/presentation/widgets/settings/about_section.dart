import 'package:flutter/material.dart';

import 'kudlit_about_dialog.dart';
import 'row_icon.dart';
import 'settings_card.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'About'),
        SettingsCard(
          children: <Widget>[
            const _AboutAppTile(),
            const SettingsDivider(),
            const _VersionTile(version: KudlitAboutDialog.version),
          ],
        ),
      ],
    );
  }
}

class _VersionTile extends StatelessWidget {
  const _VersionTile({required this.version});

  final String version;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return _AboutTile(
      icon: Icons.numbers_rounded,
      title: 'Version',
      trailing: Text(
        version,
        style: TextStyle(fontSize: 12, color: cs.onSurface.withAlpha(128)),
      ),
    );
  }
}

class _AboutAppTile extends StatelessWidget {
  const _AboutAppTile();

  @override
  Widget build(BuildContext context) {
    return _AboutTile(
      icon: Icons.info_outline_rounded,
      title: 'About Kudlit',
      onTap: () => showKudlitAboutDialog(context),
    );
  }
}

class _AboutTile extends StatelessWidget {
  const _AboutTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: <Widget>[
            RowIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            if (trailing case final Widget trailingWidget) trailingWidget,
            if (onTap != null && trailing == null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: cs.onSurface.withAlpha(64),
              ),
          ],
        ),
      ),
    );
  }
}
