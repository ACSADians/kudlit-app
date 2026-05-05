import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.aiMode,
    required this.workspaceMode,
    required this.offlineStatus,
    required this.onAiModeChanged,
    required this.onWorkspaceModeChanged,
  });

  final AiPreference aiMode;
  final TranslateWorkspaceMode workspaceMode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final ValueChanged<AiPreference> onAiModeChanged;
  final ValueChanged<TranslateWorkspaceMode> onWorkspaceModeChanged;

  String? _statusHint() {
    if (aiMode == AiPreference.cloud) return null;
    if (offlineStatus.isLoading) return 'Preparing offline model…';
    final TranslateOfflineStatus? s = offlineStatus.value;
    if (s?.usable ?? false) return null;
    return s?.detail ?? 'Offline model unavailable.';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? hint = _statusHint();
    final bool checking =
        aiMode == AiPreference.local && offlineStatus.isLoading;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'Translate',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(),
              _AiModeToggle(mode: aiMode, onChanged: onAiModeChanged),
              const SizedBox(width: 8),
              TranslateModeSwitch(
                mode: workspaceMode,
                onChanged: onWorkspaceModeChanged,
              ),
            ],
          ),
          if (hint != null) ...<Widget>[
            const SizedBox(height: 4),
            _StatusHint(text: hint, isLoading: checking),
          ],
        ],
      ),
    );
  }
}

// ─── AI mode toggle (Online / Offline) ────────────────────────────────────────

class _AiModeToggle extends StatelessWidget {
  const _AiModeToggle({required this.mode, required this.onChanged});

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
  const _AiPill({required this.label, required this.active, required this.onTap});

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
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
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

// ─── Status hint (loading / error) ────────────────────────────────────────────

class _StatusHint extends StatelessWidget {
  const _StatusHint({required this.text, required this.isLoading});

  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        if (isLoading) ...<Widget>[
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 6),
        ],
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurface.withAlpha(160),
          ),
        ),
      ],
    );
  }
}
