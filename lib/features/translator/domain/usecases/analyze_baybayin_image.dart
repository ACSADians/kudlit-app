import 'dart:typed_data';

import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';

class AnalyzeBaybayinImageParams {
  const AnalyzeBaybayinImageParams({
    required this.imageBytes,
    this.mimeType = 'image/png',
    this.prompt,
  });

  final Uint8List imageBytes;
  final String mimeType;

  /// Optional override for the analysis instruction sent to the model.
  final String? prompt;
}

/// Streaming use case that sends an image of drawn or photographed
/// Baybayin characters to the cloud AI and streams back an analysis.
class AnalyzeBaybayinImage {
  const AnalyzeBaybayinImage(this._repository);

  final AiInferenceRepository _repository;

  Stream<String> call(AnalyzeBaybayinImageParams params) {
    return _repository.analyzeImage(
      params.imageBytes,
      mimeType: params.mimeType,
      prompt: params.prompt,
    );
  }
}
