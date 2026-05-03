import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';

import 'row_icon.dart';
import 'segmented_picker.dart';

class AiRow extends ConsumerWidget {
  const AiRow({super.key, required this.current});

  final AiPreference current;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          const RowIcon(icon: Icons.auto_awesome_rounded),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'AI processing',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Local runs on-device; Cloud uses Gemma API',
                  style: TextStyle(
                    fontSize: 11,
                    color: cs.onSurface.withAlpha(128),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SegmentedPicker<AiPreference>(
            options: const <(AiPreference, String)>[
              (AiPreference.local, 'Local'),
              (AiPreference.cloud, 'Cloud'),
            ],
            selected: current,
            onSelect: (AiPreference v) => ref
                .read(appPreferencesNotifierProvider.notifier)
                .setAiPreference(v),
          ),
        ],
      ),
    );
  }
}
