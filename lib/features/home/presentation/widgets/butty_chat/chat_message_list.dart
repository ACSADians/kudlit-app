import 'package:flutter/material.dart';

import 'butty_bubble.dart';
import 'chat_msg.dart';
import 'typing_bubble.dart';
import 'user_bubble.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.scroll,
    required this.responding,
  });

  final List<ChatMsg> messages;
  final ScrollController scroll;
  final bool responding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: messages.length + (responding ? 1 : 0),
      itemBuilder: (_, int i) {
        if (i == messages.length) return const TypingBubble();
        final ChatMsg msg = messages[i];
        return msg.isButty
            ? ButtyBubble(text: msg.text)
            : UserBubble(text: msg.text);
      },
    );
  }
}
