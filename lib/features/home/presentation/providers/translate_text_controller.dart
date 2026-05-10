import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/home/domain/entities/translation_result.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translation_history_provider.dart';
import 'package:kudlit_ph/features/home/presentation/utils/safe_ai_output.dart';
import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

@immutable
class TranslateTextState {
  const TranslateTextState({
    required this.inputText,
    required this.latinToBaybayin,
    required this.baybayinText,
    required this.latinText,
    required this.feedbackMessages,
    required this.aiBusy,
    required this.aiResponse,
    this.cleanupPreview,
    this.aiSource,
  });

  const TranslateTextState.initial()
    : this(
        inputText: '',
        latinToBaybayin: true,
        baybayinText: '',
        latinText: '',
        feedbackMessages: const <String>[],
        aiBusy: false,
        aiResponse: '',
      );

  final String inputText;
  final bool latinToBaybayin;
  final String baybayinText;
  final String latinText;
  final List<String> feedbackMessages;
  final bool aiBusy;
  final String aiResponse;
  final String? cleanupPreview;
  final TranslateAiResultSource? aiSource;

  bool get hasInput => inputText.trim().isNotEmpty;

  TranslateTextState copyWith({
    String? inputText,
    bool? latinToBaybayin,
    String? baybayinText,
    String? latinText,
    List<String>? feedbackMessages,
    bool? aiBusy,
    String? aiResponse,
    String? cleanupPreview,
    bool clearCleanupPreview = false,
    TranslateAiResultSource? aiSource,
    bool clearAiSource = false,
  }) {
    return TranslateTextState(
      inputText: inputText ?? this.inputText,
      latinToBaybayin: latinToBaybayin ?? this.latinToBaybayin,
      baybayinText: baybayinText ?? this.baybayinText,
      latinText: latinText ?? this.latinText,
      feedbackMessages: feedbackMessages ?? this.feedbackMessages,
      aiBusy: aiBusy ?? this.aiBusy,
      aiResponse: aiResponse ?? this.aiResponse,
      cleanupPreview: clearCleanupPreview
          ? null
          : (cleanupPreview ?? this.cleanupPreview),
      aiSource: clearAiSource ? null : (aiSource ?? this.aiSource),
    );
  }
}

final NotifierProvider<TranslateTextController, TranslateTextState>
translateTextControllerProvider =
    NotifierProvider<TranslateTextController, TranslateTextState>(
      TranslateTextController.new,
    );

class TranslateTextController extends Notifier<TranslateTextState> {
  static final RegExp _numberPattern = RegExp(r'[0-9]');
  static final RegExp _punctuationPattern = RegExp(r'[!-/:-@[-`{-~]');
  static final RegExp _unsupportedPattern = RegExp(r'[^A-Za-z0-9\sñÑᜀ-ᜟ]');
  static final RegExp _baybayinPattern = RegExp(r'[ᜀ-ᜟ]');

  Timer? _saveDebounce;

  @override
  TranslateTextState build() {
    ref.onDispose(() => _saveDebounce?.cancel());
    return const TranslateTextState.initial();
  }

  void setInput(String value) {
    state = _deriveState(
      inputText: value,
      latinToBaybayin: state.latinToBaybayin,
    );
    _scheduleAutoSave();
  }

  void setDirection(bool latinToBaybayin) {
    state = _deriveState(
      inputText: state.inputText,
      latinToBaybayin: latinToBaybayin,
    );
    _scheduleAutoSave();
  }

  void clearInput() {
    _saveDebounce?.cancel();
    state = const TranslateTextState.initial();
  }

  void _scheduleAutoSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 1500), _doAutoSave);
  }

  void _doAutoSave() {
    final TranslateTextState s = state;
    if (s.baybayinText.isEmpty && s.latinText.isEmpty) return;
    unawaited(
      ref
          .read(translationHistoryNotifierProvider.notifier)
          .addResult(
            TranslationResult(
              inputText: s.inputText.trim(),
              baybayinText: s.baybayinText,
              latinText: s.latinText,
              direction: s.latinToBaybayin
                  ? 'latin_to_baybayin'
                  : 'baybayin_to_latin',
              aiResponse: '',
              isBookmarked: false,
              timestamp: DateTime.now(),
            ),
          ),
    );
  }

  Future<void> explain() async {
    await _runAiAction(
      userPrompt:
          'Input: "${state.inputText.trim()}"\n'
          'Baybayin: "${state.baybayinText}"\n'
          'Filipino: "${state.latinText}"\n'
          'Give a short explanation of this transliteration.',
    );
  }

  Future<void> checkInput() async {
    await _runAiAction(
      userPrompt:
          'Input: "${state.inputText.trim()}".\n'
          'Direction: ${state.latinToBaybayin ? 'Filipino to Baybayin' : 'Baybayin to Filipino'}.\n'
          'Give one short warning and one short improvement tip.',
    );
  }

  TranslateTextState _deriveState({
    required String inputText,
    required bool latinToBaybayin,
  }) {
    final String trimmed = inputText.trim();
    if (trimmed.isEmpty) {
      return state.copyWith(
        inputText: inputText,
        latinToBaybayin: latinToBaybayin,
        baybayinText: '',
        latinText: '',
        feedbackMessages: const <String>[],
        clearCleanupPreview: true,
        aiResponse: '',
        clearAiSource: true,
      );
    }

    final String baybayinText = latinToBaybayin
        ? baybayifyWord(trimmed)
        : trimmed;
    final String latinText = latinToBaybayin
        ? trimmed
        : baybayinToLatin(trimmed);
    return state.copyWith(
      inputText: inputText,
      latinToBaybayin: latinToBaybayin,
      baybayinText: baybayinText,
      latinText: latinText,
      feedbackMessages: _feedbackFor(trimmed, latinToBaybayin),
      cleanupPreview: _cleanupPreviewFor(trimmed, latinToBaybayin),
    );
  }

  String? _cleanupPreviewFor(String input, bool latinToBaybayin) {
    final bool hasRemovedCharacters = latinToBaybayin
        ? _punctuationPattern.hasMatch(input) ||
              _numberPattern.hasMatch(input) ||
              _unsupportedPattern.hasMatch(input)
        : _punctuationPattern.hasMatch(input) ||
              _numberPattern.hasMatch(input) ||
              _unsupportedPattern.hasMatch(input) ||
              _baybayinPattern.hasMatch(input);
    if (!hasRemovedCharacters) return null;

    final String normalized = latinToBaybayin
        ? input.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '')
        : input.toLowerCase().replaceAll(RegExp(r'[^a-z+\s]'), '');
    final String compact = normalized.trim().replaceAll(RegExp(r'\s+'), ' ');
    return compact.isEmpty ? null : compact;
  }

  List<String> _feedbackFor(String input, bool latinToBaybayin) {
    final List<String> messages = <String>[];
    if (_punctuationPattern.hasMatch(input)) {
      messages.add('Removed punctuation from input.');
    }
    if (_numberPattern.hasMatch(input)) {
      messages.add('Numbers were ignored.');
    }
    if (_unsupportedPattern.hasMatch(input)) {
      messages.add('Some unsupported characters were ignored.');
    }
    if (!latinToBaybayin) {
      if (_baybayinPattern.hasMatch(input)) {
        messages.add(
          'Pasted Baybayin glyphs are not parsed yet. Use encoded text like ka, ki, or k+.',
        );
      } else {
        messages.add('Reverse mode reads encoded Baybayin like ka, ki, or k+.');
      }
    }
    if (latinToBaybayin) {
      messages.add('Transliteration may be approximate for modern spelling.');
    }
    return messages;
  }

  Future<void> _runAiAction({required String userPrompt}) async {
    if (!state.hasInput || state.aiBusy) {
      return;
    }
    state = state.copyWith(aiBusy: true, aiResponse: '', clearAiSource: true);

    final List<ChatMessage> history = <ChatMessage>[
      ChatMessage(text: userPrompt, isUser: true, timestamp: DateTime.now()),
    ];
    final AiPreference mode =
        ref.read(appPreferencesNotifierProvider).value?.aiPreference ??
        AiPreference.cloud;

    if (kIsWeb || mode == AiPreference.cloud) {
      await _streamResponse(
        stream: ref
            .read(cloudGemmaDatasourceProvider)
            .generate(history, systemInstruction: GemmaPrompts.translatorMode),
        source: TranslateAiResultSource.online,
        rethrowOnError: false,
      );
      return;
    }

    final TranslateOfflineStatus offline = await ref.read(
      translateOfflineStatusProvider.future,
    );
    if (!offline.usable) {
      state = state.copyWith(
        aiBusy: false,
        aiResponse: 'Offline model is unavailable for this action.',
        clearAiSource: true,
      );
      return;
    }

    try {
      await _streamResponse(
        stream: ref
            .read(localGemmaDatasourceProvider)
            .generate(history, systemInstruction: GemmaPrompts.translatorMode),
        source: TranslateAiResultSource.offline,
        rethrowOnError: true,
      );
    } catch (error) {
      await _streamResponse(
        stream: ref
            .read(cloudGemmaDatasourceProvider)
            .generate(history, systemInstruction: GemmaPrompts.translatorMode),
        source: TranslateAiResultSource.fallback,
        prefix: 'Offline inference failed, so cloud fallback was used.\n\n',
        rethrowOnError: false,
      );
    }
  }

  Future<void> _streamResponse({
    required Stream<String> stream,
    required TranslateAiResultSource source,
    String prefix = '',
    required bool rethrowOnError,
  }) async {
    final StringBuffer buffer = StringBuffer(prefix);
    try {
      await for (final String chunk in stream) {
        buffer.write(chunk);
        final String displayResponse = cleanAssistantOutput(buffer.toString());
        state = state.copyWith(
          aiBusy: true,
          aiResponse: displayResponse,
          aiSource: source,
        );
      }
      final String displayResponse = cleanAssistantOutput(buffer.toString());
      state = state.copyWith(
        aiBusy: false,
        aiResponse: displayResponse,
        aiSource: source,
      );
      if (buffer.isNotEmpty) {
        unawaited(
          ref
              .read(translationHistoryNotifierProvider.notifier)
              .updateLastAiResponse(buffer.toString()),
        );
      }
    } catch (error) {
      state = state.copyWith(
        aiBusy: false,
        aiResponse: 'Could not complete AI request: $error',
        clearAiSource: true,
      );
      if (rethrowOnError) {
        rethrow;
      }
    }
  }
}
