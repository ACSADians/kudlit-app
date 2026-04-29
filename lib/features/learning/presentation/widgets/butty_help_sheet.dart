import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';

class ButtyHelpSheet extends StatefulWidget {
  const ButtyHelpSheet({super.key, required this.step});

  final LessonStep step;

  @override
  State<ButtyHelpSheet> createState() => _ButtyHelpSheetState();
}

class _ButtyHelpSheetState extends State<ButtyHelpSheet> {
  late final List<_HelpMessage> _messages;
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _replying = false;

  @override
  void initState() {
    super.initState();
    _messages = <_HelpMessage>[
      _HelpMessage.butty(
        "We're on '${widget.step.label}'. Want me to show the stroke order, "
        'explain the sound, or something else?',
      ),
    ];
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
    setState(() {
      _messages.add(_HelpMessage.user(text));
      _replying = true;
    });
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _messages.add(_HelpMessage.butty(_stubReply(text, widget.step)));
      _replying = false;
    });
    _scrollToBottom();
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
                    for (final _HelpMessage m in _messages) _Bubble(message: m),
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

String _stubReply(String input, LessonStep step) {
  final String lower = input.toLowerCase();
  if (lower.contains('stroke') || lower.contains('order')) {
    return 'For ${step.label}, start at the top and follow the curve in one '
        'continuous motion. Stroke-order animation is coming soon.';
  }
  if (lower.contains('sound') || lower.contains('pronoun')) {
    return '${step.label} is pronounced as in Filipino — short and clean.';
  }
  if (lower.contains('mean') || lower.contains('what')) {
    return '${step.label} is a Baybayin glyph. '
        '${step.narration ?? step.hint ?? "Study the shape, then draw it."}';
  }
  return "Good question. I'm still learning, but for ${step.label}: "
      '${step.hint ?? step.narration ?? "follow the reference glyph closely."}';
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

  final _HelpMessage message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isButty = message.isButty;
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

class _HelpMessage {
  const _HelpMessage._(this.text, {required this.isButty});

  factory _HelpMessage.butty(String text) =>
      _HelpMessage._(text, isButty: true);

  factory _HelpMessage.user(String text) =>
      _HelpMessage._(text, isButty: false);

  final String text;
  final bool isButty;
}
