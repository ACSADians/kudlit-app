import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/lesson_step.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/ai_inference_repository.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

String _buildSystemPrompt(LessonStep step) {
  final StringBuffer sb = StringBuffer();
  sb.writeln(
    'You are Butty, a bubbly Baybayin learning companion inside the '
    'Kudlit app.',
  );
  sb.writeln();
  sb.writeln('## Thinking format (REQUIRED)');
  sb.writeln(
    'You MUST wrap your internal reasoning in <think> ... </think> tags '
    'BEFORE writing your reply. This block is hidden from the learner — use '
    'it freely to plan what to say. Example structure:',
  );
  sb.writeln();
  sb.writeln('<think>');
  sb.writeln('... your private reasoning here ...');
  sb.writeln('</think>');
  sb.writeln('... your actual reply to the learner here ...');
  sb.writeln();
  sb.writeln('## Reply rules');
  sb.writeln('- 1–3 short sentences in the reply — never longer.');
  sb.writeln('- Warm and encouraging tone, not lecturing.');
  sb.writeln(
    '- Only discuss Baybayin script, Filipino language, Philippine history, '
    'and Filipino culture. Politely decline anything else.',
  );
  sb.writeln();
  sb.writeln('## Current lesson step');
  sb.writeln('  Character / label: ${step.label}  (glyph: ${step.glyph})');
  if (step.narration != null) sb.writeln('  Narration: ${step.narration}');
  if (step.hint != null) sb.writeln('  Hint: ${step.hint}');
  if (step.buttyTip != null) sb.writeln("  Butty's tip: ${step.buttyTip}");
  sb.writeln(
    '  Activity type: ${step.mode.name} '
    '(reference = read/observe, draw = write the glyph, '
    'freeInput = type the answer)',
  );
  sb.writeln();
  sb.writeln(
    'The learner may be struggling with this step. '
    'Use your <think> block to decide the best nudge, then give it briefly.',
  );
  return sb.toString();
}

/// Splits a raw model response into its think-block content and the final
/// answer. Returns empty strings for absent sections.
({String think, String answer}) _parseResponse(String raw) {
  const String openTag = '<think>';
  const String closeTag = '</think>';
  final int openIdx = raw.indexOf(openTag);
  if (openIdx == -1) return (think: '', answer: raw.trim());
  final int closeIdx = raw.indexOf(closeTag, openIdx);
  if (closeIdx == -1) {
    // Think block still open — still in reasoning phase.
    return (think: raw.substring(openIdx + openTag.length), answer: '');
  }
  final String think = raw.substring(openIdx + openTag.length, closeIdx).trim();
  final String answer = raw.substring(closeIdx + closeTag.length).trim();
  return (think: think, answer: answer);
}

class ButtyHelpSheet extends ConsumerStatefulWidget {
  const ButtyHelpSheet({super.key, required this.step});

  final LessonStep step;

  @override
  ConsumerState<ButtyHelpSheet> createState() => _ButtyHelpSheetState();
}

class _ButtyHelpSheetState extends ConsumerState<ButtyHelpSheet> {
  late final List<_HelpMessage> _messages;

  /// Parallel history list passed to the AI (user + model turns only).
  final List<ChatMessage> _history = <ChatMessage>[];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();

  /// Raw accumulated buffer from the stream. Null = idle.
  String? _streamingText;

  /// Parsed answer portion of [_streamingText]. Empty = still in think phase.
  String? _streamingAnswer;

  StreamSubscription<String>? _streamSub;

  @override
  void initState() {
    super.initState();
    _messages = <_HelpMessage>[
      _HelpMessage.butty(
        "Hey! We're on '${widget.step.label}' — "
        'want me to explain the stroke, the sound, or something else?',
      ),
    ];
  }

  @override
  void dispose() {
    _streamSub?.cancel();
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
    if (text.isEmpty || _streamingText != null) return;
    _controller.clear();

    _history.add(
      ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
    );
    setState(() {
      _messages.add(_HelpMessage.user(text));
      _streamingText = '';
    });
    _scrollToBottom();

    final AiInferenceRepository repo = ref.read(aiInferenceRepositoryProvider);
    final StringBuffer buffer = StringBuffer();

    _streamSub = repo
        .generateResponse(
          _history,
          systemInstruction: _buildSystemPrompt(widget.step),
        )
        .listen(
          (String token) {
            buffer.write(token);
            final ({String think, String answer}) parsed = _parseResponse(
              buffer.toString(),
            );
            if (!mounted) return;
            setState(() {
              _streamingText = buffer.toString();
              _streamingAnswer = parsed.answer;
            });
            _scrollToBottom();
          },
          onDone: () {
            final ({String think, String answer}) parsed = _parseResponse(
              buffer.toString(),
            );
            final String reply = parsed.answer.isEmpty
                ? buffer.toString()
                : parsed.answer;
            final String? think = parsed.think.isEmpty ? null : parsed.think;
            _history.add(
              ChatMessage(
                text: reply,
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
            if (!mounted) return;
            setState(() {
              _messages.add(_HelpMessage.butty(reply, thinkContent: think));
              _streamingText = null;
              _streamingAnswer = null;
            });
          },
          onError: (Object error) {
            if (!mounted) return;
            debugPrint(error.toString());
            setState(() {
              _messages.add(
                _HelpMessage.butty(
                  "Oops, couldn't reach the server. Try again?",
                ),
              );
              _streamingText = null;
              _streamingAnswer = null;
            });
          },
        );
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
                    if (_streamingText != null)
                      (_streamingAnswer == null || _streamingAnswer!.isEmpty)
                          ? const _TypingDots()
                          : _Bubble(
                              message: _HelpMessage.butty(_streamingAnswer!),
                            ),
                  ],
                ),
              ),
              _ChipRow(onChip: _handleChip),
              _ComposerBar(
                controller: _controller,
                enabled: _streamingText == null,
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

  final _HelpMessage message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool isButty = message.isButty;
    return Align(
      alignment: isButty ? Alignment.centerLeft : Alignment.centerRight,
      child: Column(
        crossAxisAlignment: isButty
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isButty && message.thinkContent != null)
            _ThinkPanel(content: message.thinkContent!),
          GestureDetector(
            onLongPress: () {
              Clipboard.setData(ClipboardData(text: message.text));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
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
              child: MarkdownBody(data: message.text),
            ),
          ),
        ],
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

class _ThinkPanel extends StatefulWidget {
  const _ThinkPanel({required this.content});

  final String content;

  @override
  State<_ThinkPanel> createState() => _ThinkPanelState();
}

class _ThinkPanelState extends State<_ThinkPanel> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.psychology_outlined,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Butty thought about this',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                widget.content,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HelpMessage {
  const _HelpMessage._(this.text, {required this.isButty, this.thinkContent});

  factory _HelpMessage.butty(String text, {String? thinkContent}) =>
      _HelpMessage._(text, isButty: true, thinkContent: thinkContent);

  factory _HelpMessage.user(String text) =>
      _HelpMessage._(text, isButty: false);

  final String text;
  final bool isButty;

  /// Non-null for Butty messages that contained a think block.
  final String? thinkContent;
}
