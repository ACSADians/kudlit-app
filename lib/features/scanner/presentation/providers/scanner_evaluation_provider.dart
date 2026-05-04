import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/baybayin_detection.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

@immutable
class ScanEvalState {
  const ScanEvalState({
    required this.translation,
    this.followUp,
  });

  final AsyncValue<String> translation;
  final AsyncValue<String>? followUp;

  bool get canRequestFollowUp {
    if (followUp != null) return false;
    return translation.asData?.value.isNotEmpty == true;
  }

  ScanEvalState withTranslation(AsyncValue<String> t) =>
      ScanEvalState(translation: t, followUp: followUp);

  ScanEvalState withFollowUp(AsyncValue<String>? f) =>
      ScanEvalState(translation: translation, followUp: f);
}

final NotifierProvider<ScannerEvaluationNotifier, ScanEvalState>
scannerEvaluationProvider =
    NotifierProvider<ScannerEvaluationNotifier, ScanEvalState>(
      ScannerEvaluationNotifier.new,
    );

class ScannerEvaluationNotifier extends Notifier<ScanEvalState> {
  @override
  ScanEvalState build() =>
      const ScanEvalState(translation: AsyncData<String>(''));

  void evaluate(List<BaybayinDetection> detections, Uint8List? imageBytes) {
    if (detections.isEmpty) {
      state = const ScanEvalState(translation: AsyncData<String>(''));
      return;
    }

    final List<BaybayinDetection> ordered =
        List<BaybayinDetection>.of(detections)
          ..sort(
            (BaybayinDetection a, BaybayinDetection b) =>
                a.left.compareTo(b.left),
          );
    final List<String> tokens = ordered
        .map((BaybayinDetection d) => d.label.trim().toLowerCase())
        .where((String s) => s.isNotEmpty)
        .toList(growable: false);
    final List<String> perms = permuteBaybayin(tokens);

    final String candidates = perms.isEmpty
        ? tokens.join(' ')
        : perms.take(10).join(', ');

    final String systemPrompt = GemmaPrompts.scanTranslatorMode(candidates);

    state = state.withTranslation(const AsyncLoading<String>());

    final Stream<String> stream;
    if (imageBytes != null) {
      stream = ref.read(aiInferenceRepositoryProvider).analyzeImage(
        imageBytes,
        mimeType: 'image/jpeg',
        prompt: systemPrompt,
      );
    } else {
      final String query =
          'Detected glyphs (left to right): ${tokens.join(", ")}. '
          'Which word is this?';
      stream = ref
          .read(aiInferenceNotifierProvider.notifier)
          .generateResponse(
            <ChatMessage>[
              ChatMessage(
                text: query,
                isUser: true,
                timestamp: DateTime.now(),
              ),
            ],
            systemInstruction: systemPrompt,
          );
    }

    _listenToTranslation(stream);
  }

  void requestFollowUp() {
    final String? translationText = state.translation.asData?.value;
    if (translationText == null || translationText.isEmpty) return;
    if (state.followUp != null) return;

    state = state.withFollowUp(const AsyncLoading<String>());

    final List<ChatMessage> history = <ChatMessage>[
      ChatMessage(
        text: translationText,
        isUser: false,
        timestamp: DateTime.now(),
      ),
      ChatMessage(
        text: "Tell me more about this word — its meaning, how it's used, "
            'or something interesting about it.',
        isUser: true,
        timestamp: DateTime.now(),
      ),
    ];

    final Stream<String> stream = ref
        .read(aiInferenceNotifierProvider.notifier)
        .generateResponse(
          history,
          systemInstruction: GemmaPrompts.assistantMode,
        );

    _listenToFollowUp(stream);
  }

  Future<void> _listenToTranslation(Stream<String> stream) async {
    final StringBuffer buffer = StringBuffer();
    try {
      await for (final String chunk in stream) {
        buffer.write(chunk);
        state = state.withTranslation(AsyncData<String>(buffer.toString()));
      }
    } catch (e) {
      state = state.withTranslation(
        AsyncError<String>(e, StackTrace.current),
      );
    }
  }

  Future<void> _listenToFollowUp(Stream<String> stream) async {
    final StringBuffer buffer = StringBuffer();
    try {
      await for (final String chunk in stream) {
        buffer.write(chunk);
        state = state.withFollowUp(AsyncData<String>(buffer.toString()));
      }
    } catch (e) {
      state = state.withFollowUp(
        AsyncError<String>(e, StackTrace.current),
      );
    }
  }
}
