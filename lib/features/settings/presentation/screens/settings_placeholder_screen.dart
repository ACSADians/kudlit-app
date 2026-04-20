import 'package:flutter/material.dart';

import '../../../../core/config/app_environment.dart';
import '../../../shared/presentation/widgets/placeholder_feature_content.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlaceholderFeatureContent(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'App preferences',
      body: AppEnvironment.hasSupabaseConfig
          ? 'Supabase is configured for this build.'
          : 'Supabase is not configured for this build.',
    );
  }
}
