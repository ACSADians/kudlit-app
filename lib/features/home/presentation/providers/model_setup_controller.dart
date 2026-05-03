import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

@immutable
class ModelSetupState {
  const ModelSetupState({
    required this.busy,
    this.errorMessage,
  });

  const ModelSetupState.initial() : this(busy: false);

  final bool busy;
  final String? errorMessage;

  ModelSetupState copyWith({
    bool? busy,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ModelSetupState(
      busy: busy ?? this.busy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final NotifierProvider<ModelSetupController, ModelSetupState>
modelSetupControllerProvider =
    NotifierProvider<ModelSetupController, ModelSetupState>(
      ModelSetupController.new,
    );

class ModelSetupController extends Notifier<ModelSetupState> {
  @override
  ModelSetupState build() => const ModelSetupState.initial();

  Future<void> download(GemmaModelInfo llmModel) async {
    if (state.busy) {
      return;
    }

    state = state.copyWith(busy: true, clearError: true);

    await ref
        .read(aiInferenceNotifierProvider.notifier)
        .triggerLocalDownload(llmModel);

    final AiInferenceState? inferenceState = ref
        .read(aiInferenceNotifierProvider)
        .value;
    if (inferenceState is AiInferenceError) {
      state = state.copyWith(
        busy: false,
        errorMessage: inferenceState.message,
      );
      return;
    }

    if (!kIsWeb) {
      try {
        final List<AiModelInfo> visionModels = await ref.read(
          availableYoloModelsProvider.future,
        );
        final AiModelInfo? visionModel = visionModels.isEmpty
            ? null
            : visionModels.first;
        if (visionModel != null) {
          final String yoloUrl = Platform.isIOS
              ? (visionModel.iosModelLink ?? visionModel.modelLink)
              : (visionModel.androidModelLink ?? visionModel.modelLink);
          if (yoloUrl.isNotEmpty) {
            await YoloModelCache.instance.download(
              visionModel.id,
              yoloUrl,
              version: visionModel.version,
            );
            ref.invalidate(yoloModelPathProvider);
          }
        }
      } catch (e) {
        debugPrint('[ModelSetup] YOLO download failed: $e');
      }
    }

    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .setAiPreference(AiPreference.local);
    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .markModelsDownloaded();
    state = state.copyWith(busy: false, clearError: true);
  }

  void skip() {
    if (state.busy) {
      return;
    }
    ref.read(modelSetupSkippedProvider.notifier).setSkipped();
  }
}
