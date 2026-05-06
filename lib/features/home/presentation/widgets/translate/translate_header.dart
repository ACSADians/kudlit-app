import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.aiMode,
    required this.workspaceMode,
    required this.onAiModeChanged,
    required this.onWorkspaceModeChanged,
  });

  final AiPreference aiMode;
  final TranslateWorkspaceMode workspaceMode;
  final ValueChanged<AiPreference> onAiModeChanged;
  final ValueChanged<TranslateWorkspaceMode> onWorkspaceModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Translate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              _CompactAiToggle(
                mode: aiMode,
                onChanged: onAiModeChanged,
              ),
              const SizedBox(width: 8),
              TranslateModeSwitch(
                mode: workspaceMode,
                onChanged: onWorkspaceModeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompactAiToggle extends StatelessWidget {
  const _CompactAiToggle({required this.mode, required this.onChanged});

  final AiPreference mode;
  final ValueChanged<AiPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AiPill(
            label: 'Online',
            active: mode == AiPreference.cloud,
            onTap: () => onChanged(AiPreference.cloud),
          ),
          _AiPill(
            label: 'Offline',
            active: mode == AiPreference.local,
            onTap: () => onChanged(AiPreference.local),
          ),
        ],
      ),
    );
  }
}

class _AiPill extends StatelessWidget {
  const _AiPill({
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: active ? cs.onPrimary : cs.onSurface.withAlpha(170),
          ),
        ),
      ),
    );
  }
}

