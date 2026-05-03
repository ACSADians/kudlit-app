import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/butty_chat_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_message_list.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/suggested_questions_row.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';

class ButtyChatScreen extends ConsumerStatefulWidget {
  const ButtyChatScreen({super.key});

  @override
  ConsumerState<ButtyChatScreen> createState() => _ButtyChatScreenState();
}

class _ButtyChatScreenState extends ConsumerState<ButtyChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  int _lastMessageCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
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
    _handleSend();
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
    final ButtyChatState chatState = ref.watch(buttyChatControllerProvider);
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
          if (chatState.messages.length == 1 && !chatState.responding)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SuggestedQuestionsRow(onTap: _handleSuggestion),
            ),
          ChatInputBar(
            controller: _controller,
            responding: chatState.responding,
            onSend: _handleSend,
          ),
          SizedBox(
            height:
                MediaQuery.paddingOf(context).bottom +
                kFloatingNavClearance +
                8,
          ),
        ],
      ),
    );
  }
}
