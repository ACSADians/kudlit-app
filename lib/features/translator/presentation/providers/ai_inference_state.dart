import 'package:meta/meta.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';

/// State machine for the global AI inference service.
@immutable
sealed class AiInferenceState {
  const AiInferenceState();
}

/// Initial state. Notifier hasn't yet decided what to do.
class AiInferenceIdle extends AiInferenceState {
  const AiInferenceIdle();
}

/// User selected local mode but the model file is not on disk.
/// UI should prompt them to start the download.
class AiLocalModelMissing extends AiInferenceState {
  const AiLocalModelMissing(this.model);

  final GemmaModelInfo model;
}

/// Download in flight. [progress] is 0..100.
class AiDownloading extends AiInferenceState {
  const AiDownloading({required this.model, required this.progress});

  final GemmaModelInfo model;
  final int progress;
}

/// Inference is ready. Either the local model is loaded or
/// cloud is configured.
class AiReady extends AiInferenceState {
  const AiReady({required this.mode, required this.activeModel});

  final AiPreference mode;
  final GemmaModelInfo activeModel;
}

/// Catch-all error state.
class AiInferenceError extends AiInferenceState {
  const AiInferenceError(this.message);

  final String message;
}
