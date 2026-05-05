import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/utils/safe_ai_output.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_msg.dart';
import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';

@immutable
class ButtyChatState {
  const ButtyChatState({required this.messages, required this.responding});

  factory ButtyChatState.initial() {
    return const ButtyChatState(
      messages: <ChatMsg>[
        (
          isButty: true,
          text:
              'Hoy, kumusta! I\'m Butty — I eat Baybayin for breakfast. '
              'Ask me about the ancient script, why it almost disappeared, '
              'how to write your name, or literally anything about Philippine '
              'writing. I\'m hyped. Go.',
        ),
      ],
      responding: false,
    );
  }

  final List<ChatMsg> messages;
  final bool responding;

  ButtyChatState copyWith({List<ChatMsg>? messages, bool? responding}) {
    return ButtyChatState(
      messages: messages ?? this.messages,
      responding: responding ?? this.responding,
    );
  }
}

final NotifierProvider<ButtyChatController, ButtyChatState>
buttyChatControllerProvider =
    NotifierProvider<ButtyChatController, ButtyChatState>(
      ButtyChatController.new,
    );

class ButtyChatController extends Notifier<ButtyChatState> {
  @override
  ButtyChatState build() => ButtyChatState.initial();

  Future<void> send(String text) async {
    final String trimmed = text.trim();
    if (trimmed.isEmpty || state.responding) {
      return;
    }

    final AiPreference mode =
        ref.read(appPreferencesNotifierProvider).value?.aiPreference ??
        AiPreference.cloud;
    debugPrint(
      '[Butty] send requested | mode=${mode.name} | chars=${trimmed.length}',
    );

    final List<ChatMsg> nextMessages = <ChatMsg>[
      ...state.messages,
      (isButty: false, text: trimmed),
    ];
    state = state.copyWith(messages: nextMessages, responding: true);

    final List<ChatMessage> history = nextMessages
        .map((ChatMsg msg) {
          return ChatMessage(
            text: msg.text,
            isUser: !msg.isButty,
            timestamp: DateTime.now(),
          );
        })
        .toList(growable: false);

    try {
      final Stream<String> responseStream = ref
          .read(aiInferenceNotifierProvider.notifier)
          .generateResponse(
            history,
            systemInstruction: GemmaPrompts.assistantMode,
          );
      debugPrint('[Butty] response stream opened');

      state = state.copyWith(
        messages: <ChatMsg>[...state.messages, (isButty: true, text: '')],
      );

      final StringBuffer buffer = StringBuffer();
      await for (final String chunk in responseStream) {
        buffer.write(chunk);
        final String displayText = cleanAssistantOutput(buffer.toString());
        state = state.copyWith(
          messages: <ChatMsg>[
            ...state.messages.take(state.messages.length - 1),
            (isButty: true, text: displayText),
          ],
        );
      }
      debugPrint(
        '[Butty] response completed | chars=${buffer.toString().length}',
      );
    } catch (_) {
      debugPrint('[Butty] response failed');
      state = state.copyWith(
        messages: <ChatMsg>[
          ...state.messages,
          (
            isButty: true,
            text: 'Oops, I had trouble thinking about that. Try again?',
          ),
        ],
      );
    } finally {
      debugPrint('[Butty] responding=false');
      state = state.copyWith(responding: false);
    }
  }
}
