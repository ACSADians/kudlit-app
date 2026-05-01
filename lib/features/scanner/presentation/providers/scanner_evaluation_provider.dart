import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';

final AutoDisposeNotifierProvider<ScannerEvaluationNotifier, AsyncValue<String>> scannerEvaluationProvider =
    AutoDisposeNotifierProvider<ScannerEvaluationNotifier, AsyncValue<String>>(
  ScannerEvaluationNotifier.new,
);

class ScannerEvaluationNotifier extends AutoDisposeNotifier<AsyncValue<String>> {
  @override
  AsyncValue<String> build() => const AsyncData<String>('');

  void evaluate(List<BaybayinDetection> detections, Uint8List? imageBytes) {
    if (detections.isEmpty) {
      state = const AsyncData<String>('No characters detected.');
      return;
    }

    final String detectedLabels = detections.map((BaybayinDetection d) => d.label).join(' ');
    final String prompt = imageBytes != null
        ? GemmaPrompts.teacherMode
        : GemmaPrompts.translatorMode;

    final String query = 'Detected: $detectedLabels. Please analyze.';

    final ChatMessage message = ChatMessage(
      text: query,
      isUser: true,
      timestamp: DateTime.now(),
      imageBytes: imageBytes,
    );

    final Stream<String> responseStream = ref
        .read(aiInferenceNotifierProvider.notifier)
        .generateResponse(
          <ChatMessage>[message],
          systemInstruction: prompt,
        );

    state = const AsyncLoading<String>();
    _listenToStream(responseStream);
  }

  Future<void> _listenToStream(Stream<String> stream) async {
    final StringBuffer buffer = StringBuffer();
    try {
      await for (final String chunk in stream) {
        buffer.write(chunk);
        state = AsyncData<String>(buffer.toString());
      }
    } catch (e) {
      state = AsyncError<String>(e, StackTrace.current);
    }
  }
}
