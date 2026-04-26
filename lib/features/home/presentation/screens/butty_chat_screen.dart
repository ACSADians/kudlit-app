import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/butty_header.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_input_bar.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_message_list.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/butty_chat/chat_msg.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';

String buttyReply(String input) {
  final String lower = input.toLowerCase();
  if (lower.contains('hello') ||
      lower.contains('hi') ||
      lower.contains('kumusta')) {
    return 'Kumusta! I\'m Butty, your Baybayin guide. What would you like to know?';
  }
  if (lower.contains('baybayin')) {
    return 'Baybayin is an ancient pre-colonial Philippine script. '
        'It\'s an abugida \u2014 each character represents a syllable, not just a letter.';
  }
  if (lower.contains('kudlit')) {
    return 'A kudlit is a diacritic placed above or below a Baybayin character '
        'to change its vowel sound. Above gives E or I; below gives O or U.';
  }
  if (lower.contains('lesson') ||
      lower.contains('learn') ||
      lower.contains('start')) {
    return 'Head to the Learn tab and tap Lesson 1 \u2014 '
        'I\'ll walk you through each character step by step.';
  }
  if (lower.contains('vowel')) {
    return 'Baybayin has three vowel characters: A, E/I, and O/U. '
        'Two vowels share one glyph \u2014 a feature called vowel pairing.';
  }
  if (lower.contains('consonant')) {
    return 'Without a kudlit, every Baybayin consonant reads with an implied "a" '
        'sound. Add a kudlit to change the vowel.';
  }
  return 'Good question. I\'m still growing, but try the Lesson 1 in the '
      'Learn tab and I\'ll walk you through the basics of Baybayin writing.';
}

class ButtyChatScreen extends StatefulWidget {
  const ButtyChatScreen({super.key});

  @override
  State<ButtyChatScreen> createState() => _ButtyChatScreenState();
}

class _ButtyChatScreenState extends State<ButtyChatScreen> {
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

  void _handleSend() {
    final String text = _controller.text.trim();
    if (text.isEmpty || _responding) return;
    _controller.clear();
    setState(() {
      _messages.add((isButty: false, text: text));
      _responding = true;
    });
    _scrollToBottom();
    Future<void>.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        _messages.add((isButty: true, text: buttyReply(text)));
        _responding = false;
      });
      _scrollToBottom();
    });
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
