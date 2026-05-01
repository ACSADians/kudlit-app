import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/gemma_prompts.dart';
import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';

class ButtyHelpSheet extends ConsumerStatefulWidget {
  const ButtyHelpSheet({super.key, required this.step});

  final LessonStep step;

  @override
  ConsumerState<ButtyHelpSheet> createState() => _ButtyHelpSheetState();
}

class _ButtyHelpSheetState extends ConsumerState<ButtyHelpSheet> {
  final List<ChatMessage> _messages = <ChatMessage>[];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _replying = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text: "We're on '${widget.step.label}'. Want me to show the stroke order, "
            'explain the sound, or something else?',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _handleChip(String prompt) {
    _controller.text = prompt;
    _send();
  }

  Future<void> _send() async {
    final String text = _controller.text.trim();
    if (text.isEmpty || _replying) return;
    _controller.clear();
    
    final ChatMessage userMsg = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _replying = true;
    });
    _scrollToBottom();

    try {
      final Stream<String> responseStream = ref
          .read(aiInferenceNotifierProvider.notifier)
          .generateResponse(
            _messages,
            systemInstruction: GemmaPrompts.coachMode(widget.step.label),
          );

      final ChatMessage aiMsg = ChatMessage(
        text: '',
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      setState(() {
        _messages.add(aiMsg);
      });

      final StringBuffer buffer = StringBuffer();
      await for (final String chunk in responseStream) {
        buffer.write(chunk);
        if (mounted) {
          setState(() {
            _messages.last = aiMsg.copyWith(text: buffer.toString());
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Oops, I had trouble thinking about that. Try again?',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _replying = false;
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
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (BuildContext context, ScrollController sheetScroll) {
        return Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: <Widget>[
              const _SheetHandle(),
              _SheetHeader(
                stepLabel: widget.step.label,
                onClose: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  children: <Widget>[
                    for (final ChatMessage m in _messages) _Bubble(message: m),
                    if (_replying) const _TypingDots(),
                  ],
                ),
              ),
              _ChipRow(onChip: _handleChip),
              _ComposerBar(
                controller: _controller,
                enabled: !_replying,
                onSend: _send,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: cs.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.stepLabel, required this.onClose});

  final String stepLabel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 8),
      child: Row(
        children: <Widget>[
          const CircleAvatar(
            radius: 16,
            backgroundImage: AssetImage('assets/brand/ButtyTextBubble.webp'),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Ask Butty',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  'About: $stepLabel',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_downward_rounded, size: 18),
            label: const Text('Back to lesson'),
          ),
        ],
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.onChip});

  final void Function(String prompt) onChip;

  static const List<String> _chips = <String>[
    'Show stroke order',
    'How is it pronounced?',
    'What does this mean?',
  ];

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _chips.length,
        separatorBuilder: (BuildContext context, int i) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int i) {
          return ActionChip(
            label: Text(_chips[i]),
            onPressed: () => onChip(_chips[i]),
            backgroundColor: cs.primaryContainer,
            labelStyle: TextStyle(color: cs.onPrimaryContainer),
            side: BorderSide(color: cs.outlineVariant),
          );
        },
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  const _ComposerBar({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        12 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              onSubmitted: (_) => onSend(),
              decoration: InputDecoration(
                hintText: 'Ask Butty about this step...',
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: TextStyle(color: cs.onSurface),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isButty = !message.isUser;
    
    // Hide empty bubbles while thinking
    if (message.text.isEmpty) return const SizedBox.shrink();
    
    return Align(
      alignment: isButty ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isButty ? cs.surfaceContainerHigh : cs.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: isButty ? cs.onSurface : cs.onPrimary,
            height: 1.35,
          ),
        ),
      ),
    );
  }
}

class _TypingDots extends StatelessWidget {
  const _TypingDots();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Butty is thinking...',
          style: TextStyle(color: cs.onSurface.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
