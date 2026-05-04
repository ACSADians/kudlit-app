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
    // Exclude the transient empty streaming placeholder so it doesn't
    // render as a blank bubble alongside the TypingBubble.
    final List<ChatMsg> visible = messages
        .where((ChatMsg m) => !m.isButty || m.text.isNotEmpty)
        .toList(growable: false);

    // Show TypingBubble only while waiting for Butty's first token.
    // Once the streaming message has text, the bubble takes over.
    final bool waitingForToken =
        responding && (visible.isEmpty || !visible.last.isButty);

    return ListView.builder(
      controller: scroll,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      itemCount: visible.length + (waitingForToken ? 1 : 0),
      itemBuilder: (_, int i) {
        if (i == visible.length) return const TypingBubble();
        final ChatMsg msg = visible[i];
        return msg.isButty
            ? ButtyBubble(text: msg.text)
            : UserBubble(text: msg.text);
      },
    );
  }
}
