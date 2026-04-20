import 'package:flutter/material.dart';

import '../../../shared/presentation/widgets/placeholder_feature_content.dart';

class SettingsPlaceholderScreen extends StatelessWidget {
  const SettingsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderFeatureContent(
      icon: Icons.settings_outlined,
      title: 'Settings',
      subtitle: 'App preferences',
      body: 'Language, camera, and model settings will open here.',
    );
  }
}
