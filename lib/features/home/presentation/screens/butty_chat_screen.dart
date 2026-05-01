import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_message_list.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_msg.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';

class ButtyChatScreen extends ConsumerStatefulWidget {
  const ButtyChatScreen({super.key});

  @override
  ConsumerState<ButtyChatScreen> createState() => _ButtyChatScreenState();
}

class _ButtyChatScreenState extends ConsumerState<ButtyChatScreen> {
  final List<ChatMsg> _messages = <ChatMsg>[
    (
      isButty: true,
      text:
          'Kumusta! Ask me anything about Baybayin \u2014 the script, the kudlit, '
          'history, or how to write. I\'m here.',
    ),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _responding = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _responding) return;
    _controller.clear();
    
    setState(() {
      _messages.add((isButty: false, text: text));
      _responding = true;
    });
    _scrollToBottom();

    final List<ChatMessage> history = _messages.map((ChatMsg msg) {
      return ChatMessage(
        text: msg.text,
        isUser: !msg.isButty,
        timestamp: DateTime.now(),
      );
    }).toList();

    try {
      final Stream<String> responseStream = ref
          .read(aiInferenceNotifierProvider.notifier)
          .generateResponse(
            history,
            systemInstruction: GemmaPrompts.assistantMode,
          );

      setState(() {
        _messages.add((isButty: true, text: ''));
      });

      final StringBuffer buffer = StringBuffer();
      await for (final String chunk in responseStream) {
        buffer.write(chunk);
        if (mounted) {
          setState(() {
            _messages.last = (isButty: true, text: buffer.toString());
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add((
            isButty: true,
            text: 'Oops, I had trouble thinking about that. Try again?',
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _responding = false;
        });
        _scrollToBottom();
      }
    }
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
    return DecoratedBox(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
      child: Column(
        children: <Widget>[
          const ButtyHeader(),
          Expanded(
            child: ChatMessageList(
              messages: _messages,
              scroll: _scroll,
              responding: _responding,
            ),
          ),
          ChatInputBar(
            controller: _controller,
            responding: _responding,
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
