import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/data/datasources/local_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

@immutable
class ButtyOfflineStatus {
  const ButtyOfflineStatus({
    required this.installed,
    this.modelName,
    this.detail,
  });

  final bool installed;
  final String? modelName;
  final String? detail;
}

final FutureProvider<ButtyOfflineStatus> buttyOfflineStatusProvider =
    FutureProvider<ButtyOfflineStatus>((Ref ref) async {
      final AppPreferences prefs = await ref.watch(
        appPreferencesNotifierProvider.future,
      );
      final List<GemmaModelInfo> models = await ref.watch(
        availableGemmaModelsProvider.future,
      );

      if (models.isEmpty) {
        return const ButtyOfflineStatus(
          installed: false,
          detail: 'No Gemma model is configured for offline chat.',
        );
      }

      GemmaModelInfo active = models[models.length ~/ 2];
      if (prefs.selectedModelId != null) {
        for (final GemmaModelInfo model in models) {
          if (model.id == prefs.selectedModelId) {
            active = model;
            break;
          }
        }
      }

      final LocalGemmaDatasource localDatasource = ref.read(
        localGemmaDatasourceProvider,
      );
      final LocalGemmaReadiness readiness = await localDatasource
          .probeReadiness(active);

      return ButtyOfflineStatus(
        installed: readiness.usable,
        modelName: active.name,
        detail: readiness.detail,
      );
    });

class ButtyModelModeSelector extends ConsumerWidget {
  const ButtyModelModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<AppPreferences> prefsAsync = ref.watch(
      appPreferencesNotifierProvider,
    );
    final AsyncValue<AiInferenceState> inferenceAsync = ref.watch(
      aiInferenceNotifierProvider,
    );
    final AsyncValue<ButtyOfflineStatus> offlineStatusAsync = ref.watch(
      buttyOfflineStatusProvider,
    );

    final AiPreference currentMode =
        prefsAsync.value?.aiPreference ?? AiPreference.cloud;
    final ButtyOfflineStatus? offlineStatus = offlineStatusAsync.value;
    final bool offlineReady = offlineStatus?.installed ?? false;
    final bool offlineChecking =
        offlineStatusAsync.isLoading || inferenceAsync.isLoading;
    final String helperText = switch (offlineStatusAsync) {
      AsyncData(:final ButtyOfflineStatus value) =>
        value.detail ?? 'Offline status unknown.',
      AsyncError() => 'Offline check failed. Use cloud or retry later.',
      _ => 'Checking whether the offline Gemma model is installed…',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ModePill(
                label: 'Online',
                active: currentMode == AiPreference.cloud,
                onTap: () => _setMode(ref, AiPreference.cloud),
              ),
              _ModePill(
                label: 'Offline',
                active: currentMode == AiPreference.local,
                enabled: offlineReady && !offlineChecking,
                onTap: () => _setMode(ref, AiPreference.local),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          helperText,
          style: TextStyle(fontSize: 10.5, color: Colors.white.withAlpha(170)),
        ),
      ],
    );
  }

  Future<void> _setMode(WidgetRef ref, AiPreference mode) async {
    debugPrint('[Butty] model mode selected -> ${mode.name}');
    final AppPreferencesNotifier notifier = ref.read(
      appPreferencesNotifierProvider.notifier,
    );
    await notifier.setAiPreference(mode);
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.active,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = active ? cs.primary : Colors.transparent;
    final Color fg = active
        ? cs.onPrimary
        : enabled
        ? cs.primary
        : cs.onSurface.withAlpha(110);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: fg,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
