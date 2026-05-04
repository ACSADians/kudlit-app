import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/data/datasources/local_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

enum TranslateWorkspaceMode { text, sketchpad }

enum TranslateAiResultSource { offline, online, fallback }

extension TranslateAiResultSourceLabel on TranslateAiResultSource {
  String get label => switch (this) {
    TranslateAiResultSource.offline => 'Offline Gemma',
    TranslateAiResultSource.online => 'Online Gemma',
    TranslateAiResultSource.fallback => 'Cloud fallback used',
  };
}

@immutable
class TranslatePageState {
  const TranslatePageState({required this.mode});

  const TranslatePageState.initial() : this(mode: TranslateWorkspaceMode.text);

  final TranslateWorkspaceMode mode;

  TranslatePageState copyWith({TranslateWorkspaceMode? mode}) {
    return TranslatePageState(mode: mode ?? this.mode);
  }
}

@immutable
class TranslateOfflineStatus {
  const TranslateOfflineStatus({
    required this.installed,
    required this.usable,
    required this.detail,
    this.modelName,
  });

  final bool installed;
  final bool usable;
  final String detail;
  final String? modelName;
}

final NotifierProvider<TranslatePageController, TranslatePageState>
translatePageControllerProvider =
    NotifierProvider<TranslatePageController, TranslatePageState>(
      TranslatePageController.new,
    );

class TranslatePageController extends Notifier<TranslatePageState> {
  @override
  TranslatePageState build() => const TranslatePageState.initial();

  void setMode(TranslateWorkspaceMode mode) {
    state = state.copyWith(mode: mode);
  }
}

final FutureProvider<TranslateOfflineStatus> translateOfflineStatusProvider =
    FutureProvider<TranslateOfflineStatus>((Ref ref) async {
      final AppPreferences prefs = await ref.watch(
        appPreferencesNotifierProvider.future,
      );
      final List<GemmaModelInfo> models = await ref.watch(
        availableGemmaModelsProvider.future,
      );

      if (models.isEmpty) {
        return const TranslateOfflineStatus(
          installed: false,
          usable: false,
          detail: 'Offline model is unavailable on this device.',
        );
      }

      final GemmaModelInfo active = _resolveActiveModel(
        models,
        preferredId: prefs.selectedModelId,
      );
      final LocalGemmaReadiness readiness = await ref
          .read(localGemmaDatasourceProvider)
          .probeReadiness(active);
      return TranslateOfflineStatus(
        installed: readiness.installed,
        usable: readiness.usable,
        detail: readiness.detail,
        modelName: active.name,
      );
    });

GemmaModelInfo _resolveActiveModel(
  List<GemmaModelInfo> models, {
  String? preferredId,
}) {
  if (preferredId != null) {
    for (final GemmaModelInfo model in models) {
      if (model.id == preferredId) {
        return model;
      }
    }
  }
  return models[models.length ~/ 2];
}
