import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.workspaceMode,
    required this.aiMode,
    required this.offlineStatus,
    required this.onWorkspaceModeChanged,
    required this.onAiModeChanged,
  });

  final TranslateWorkspaceMode workspaceMode;
  final AiPreference aiMode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final ValueChanged<TranslateWorkspaceMode> onWorkspaceModeChanged;
  final ValueChanged<AiPreference> onAiModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Translate',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Baybayin translator and stroke practice.',
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withAlpha(150),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              TranslateModeSwitch(
                mode: workspaceMode,
                onChanged: onWorkspaceModeChanged,
              ),
              _AiModeSwitch(
                mode: aiMode,
                onChanged: onAiModeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiModeSwitch extends StatelessWidget {
  const _AiModeSwitch({required this.mode, required this.onChanged});

  final AiPreference mode;
  final ValueChanged<AiPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AiModePill(
            label: 'Online',
            active: mode == AiPreference.cloud,
            onTap: () => onChanged(AiPreference.cloud),
          ),
          _AiModePill(
            label: 'Offline',
            active: mode == AiPreference.local,
            onTap: () => onChanged(AiPreference.local),
          ),
        ],
      ),
    );
  }
}

class _AiModePill extends StatelessWidget {
  const _AiModePill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: active ? cs.onPrimary : cs.onSurface.withAlpha(170),
          ),
        ),
      ),
    );
  }
}
