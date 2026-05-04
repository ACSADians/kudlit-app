import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';

class TranslateGemmaStatusBanner extends StatelessWidget {
  const TranslateGemmaStatusBanner({
    super.key,
    required this.mode,
    required this.offlineStatus,
    required this.onModeChanged,
  });

  final AiPreference mode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final ValueChanged<AiPreference> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool checking = mode == AiPreference.local && offlineStatus.isLoading;
    final TranslateOfflineStatus? status = offlineStatus.value;
    final String helper = switch (mode) {
      AiPreference.cloud => 'Online Gemma is active.',
      AiPreference.local when checking => 'Preparing offline Gemma...',
      AiPreference.local when status?.usable ?? false =>
        status?.modelName == null
            ? 'Offline ready.'
            : 'Offline ready: ${status!.modelName}.',
      AiPreference.local when status?.installed ?? false =>
        'Offline model found, but local runtime is unavailable.',
      _ => status?.detail ?? 'Offline model is unavailable for this action.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _SourceSwitch(mode: mode, onModeChanged: onModeChanged),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              if (checking)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  helper,
                  style: TextStyle(
                    fontSize: 12,
                    color: cs.onSurface.withAlpha(185),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SourceSwitch extends StatelessWidget {
  const _SourceSwitch({required this.mode, required this.onModeChanged});

  final AiPreference mode;
  final ValueChanged<AiPreference> onModeChanged;

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
          _SourcePill(
            label: 'Online',
            active: mode == AiPreference.cloud,
            onTap: () => onModeChanged(AiPreference.cloud),
          ),
          _SourcePill(
            label: 'Offline',
            active: mode == AiPreference.local,
            onTap: () => onModeChanged(AiPreference.local),
          ),
        ],
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  const _SourcePill({
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
