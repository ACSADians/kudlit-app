import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/butty_chat_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_model_mode_selector.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_message_list.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/suggested_questions_row.dart';

class ButtyChatScreen extends ConsumerStatefulWidget {
  const ButtyChatScreen({super.key});

  @override
  ConsumerState<ButtyChatScreen> createState() => _ButtyChatScreenState();
}

class _ButtyChatScreenState extends ConsumerState<ButtyChatScreen>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // Fire-and-forget: distill any new turns into long-term memory before
      // the OS may suspend us. The service throttles itself, so repeated
      // pause/resume cycles do not spam the model.
      unawaited(
        ref.read(buttyChatControllerProvider.notifier).flushMemoryNow(),
      );
    }
  }

  void _onSendTap() {
    unawaited(_handleSend());
  }

  Future<void> _handleSend() async {
    final String text = _controller.text.trim();
    if (text.isEmpty) {
      return;
    }

    _controller.clear();
    await ref.read(buttyChatControllerProvider.notifier).send(text);
  }

  void _handleSuggestion(String question) {
    _controller.text = question;
    _onSendTap();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ButtyChatState chatState = ref.watch(buttyChatControllerProvider);
    final AsyncValue<AppPreferences> prefsAsync = ref.watch(
      appPreferencesNotifierProvider,
    );
    final AsyncValue<ButtyOfflineStatus> offlineStatusAsync = ref.watch(
      buttyOfflineStatusProvider,
    );
    final AiPreference mode =
        prefsAsync.value?.aiPreference ?? AiPreference.cloud;
    final ButtyOfflineStatus? offlineStatus = offlineStatusAsync.value;
    final bool offlinePending =
        mode == AiPreference.local && offlineStatusAsync.isLoading;
    final bool offlineUnavailable =
        mode == AiPreference.local &&
        !offlineStatusAsync.isLoading &&
        !(offlineStatus?.usable ?? false);
    final bool inputEnabled =
        !chatState.responding && !offlinePending && !offlineUnavailable;
    final String? disabledHint = switch (mode) {
      AiPreference.local when offlinePending =>
        'Preparing offline Gemma for Butty...',
      AiPreference.local when offlineUnavailable =>
        offlineStatus?.detail ?? 'Offline Gemma is not ready yet.',
      _ => null,
    };
    if (_lastMessageCount != chatState.messages.length) {
      _lastMessageCount = chatState.messages.length;
      _scrollToBottom();
    }

    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: <Widget>[
          const ButtyHeader(),
          Expanded(
            child: ChatMessageList(
              messages: chatState.messages,
              scroll: _scroll,
              responding: chatState.responding,
            ),
          ),
          if (offlinePending || offlineUnavailable)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: <Widget>[
                  if (offlinePending) ...<Widget>[
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      disabledHint ?? 'Preparing offline Gemma...',
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withAlpha(170),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (chatState.messages.length == 1 &&
              !chatState.responding &&
              inputEnabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SuggestedQuestionsRow(onTap: _handleSuggestion),
            ),
          ChatInputBar(
            controller: _controller,
            responding: chatState.responding,
            enabled: inputEnabled,
            disabledHint: disabledHint,
            onSend: _onSendTap,
          ),
        ],
      ),
    );
  }
}
