import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';

import 'settings_card.dart';
import 'settings_section_label.dart';
import 'theme_row.dart';
import 'ai_preference_row.dart';
import 'local_model_status_row.dart';

class PreferencesSection extends ConsumerWidget {
  const PreferencesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppPreferences? prefs = ref
        .watch(appPreferencesNotifierProvider)
        .valueOrNull;

    if (prefs == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'Preferences'),
        SettingsCard(
          children: <Widget>[
            ThemeRow(current: prefs.themeMode),
            const SettingsDivider(),
            AiPreferenceRow(current: prefs.aiPreference),
            const SettingsDivider(),
            const LocalModelStatusRow(),
          ],
        ),
      ],
    );
  }
}
