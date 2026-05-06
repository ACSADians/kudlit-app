import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/direction_toggle.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/output_stage.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_feedback_card.dart';

class TranslateTextModePanel extends StatelessWidget {
  const TranslateTextModePanel({
    super.key,
    required this.state,
    required this.inputEnabled,
    required this.disabledReason,
    required this.aiMode,
    required this.offlineStatus,
    required this.onDirectionChanged,
    required this.onInputChanged,
    required this.onClear,
    required this.onExplain,
    required this.onCheckInput,
    required this.onCopy,
    required this.onShare,
  });

  final TranslateTextState state;
  final bool inputEnabled;
  final String? disabledReason;
  final AiPreference aiMode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final ValueChanged<bool> onDirectionChanged;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onClear;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 160),
                  child: OutputStage(
                    baybayinText: state.baybayinText,
                    latinText: state.latinText,
                    hasInput: state.hasInput,
                    copyLabel: 'Copy',
                    shareLabel: 'Share',
                    onCopy: onCopy,
                    onShare: onShare,
                  ),
                ),
                if (state.aiResponse.trim().isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  TranslateFeedbackCard(
                    title: 'AI feedback',
                    body: state.aiResponse,
                    sourceLabel: state.aiSource?.label,
                  ),
                ],
              ],
            ),
          ),
        ),
        _TranslateInputBar(
          state: state,
          aiMode: aiMode,
          offlineStatus: offlineStatus,
          inputEnabled: inputEnabled,
          disabledReason: disabledReason,
          onDirectionChanged: onDirectionChanged,
          onInputChanged: onInputChanged,
          onClear: onClear,
          onExplain: onExplain,
          onCheckInput: onCheckInput,
        ),
      ],
    );
  }
}

// ─── Sticky Input Bar ────────────────────────────────────────────────────────

class _TranslateInputBar extends StatefulWidget {
  const _TranslateInputBar({
    required this.state,
    required this.aiMode,
    required this.offlineStatus,
    required this.inputEnabled,
    required this.disabledReason,
    required this.onDirectionChanged,
    required this.onInputChanged,
    required this.onClear,
    required this.onExplain,
    required this.onCheckInput,
  });

  final TranslateTextState state;
  final AiPreference aiMode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final bool inputEnabled;
  final String? disabledReason;
  final ValueChanged<bool> onDirectionChanged;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onClear;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;

  @override
  State<_TranslateInputBar> createState() => _TranslateInputBarState();
}

class _TranslateInputBarState extends State<_TranslateInputBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.state.inputText;
  }

  @override
  void didUpdateWidget(covariant _TranslateInputBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.state.inputText) {
      _controller.value = TextEditingValue(
        text: widget.state.inputText,
        selection: TextSelection.collapsed(offset: widget.state.inputText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool checking =
        widget.aiMode == AiPreference.local && widget.offlineStatus.isLoading;
    final TranslateOfflineStatus? status = widget.offlineStatus.value;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // Direction toggle
          DirectionToggle(
            latinToBaybayin: widget.state.latinToBaybayin,
            onToggle: widget.onDirectionChanged,
          ),
          const SizedBox(height: 8),
          // Row 2: Input container
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: cs.outline),
            ),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (
                BuildContext ctx,
                TextEditingValue value,
                Widget? child,
              ) {
                final bool hasText = value.text.isNotEmpty;
                final bool actionsEnabled =
                    widget.inputEnabled && hasText && !widget.state.aiBusy;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            enabled: widget.inputEnabled && !widget.state.aiBusy,
                            onChanged: widget.onInputChanged,
                            maxLines: null,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: widget.state.latinToBaybayin
                                  ? 'Type in Filipino...'
                                  : 'Paste Baybayin Unicode...',
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 4),
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: cs.onSurface.withAlpha(110),
                              ),
                            ),
                          ),
                        ),
                        if (hasText)
                          GestureDetector(
                            onTap: () {
                              _controller.clear();
                              widget.onClear();
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 8, bottom: 2),
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: cs.onSurface.withAlpha(130),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (hasText) ...<Widget>[
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          _InputActionChip(
                            label: widget.state.aiBusy ? 'Working…' : 'Explain',
                            icon: Icons.auto_awesome_rounded,
                            enabled: actionsEnabled,
                            onTap: widget.onExplain,
                          ),
                          const SizedBox(width: 6),
                          _InputActionChip(
                            label: 'Check',
                            icon: Icons.spellcheck_rounded,
                            enabled: actionsEnabled,
                            onTap: widget.onCheckInput,
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
          // Row 3: Status hint
          const SizedBox(height: 6),
          _AiStatusHint(
            checking: checking,
            mode: widget.aiMode,
            status: status,
            disabledReason: widget.disabledReason,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ─── AI Status Hint ───────────────────────────────────────────────────────────

class _AiStatusHint extends StatelessWidget {
  const _AiStatusHint({
    required this.checking,
    required this.mode,
    required this.status,
    required this.disabledReason,
  });

  final bool checking;
  final AiPreference mode;
  final TranslateOfflineStatus? status;
  final String? disabledReason;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String hint = disabledReason ?? _defaultHint();
    return Row(
      children: <Widget>[
        _StatusDot(checking: checking, mode: mode, status: status),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            hint,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              color: cs.onSurface.withAlpha(160),
            ),
          ),
        ),
      ],
    );
  }

  String _defaultHint() {
    if (mode == AiPreference.cloud) return 'Online Gemma is active.';
    if (checking) return 'Preparing offline Gemma…';
    if (status?.usable ?? false) {
      return status?.modelName == null
          ? 'Offline ready.'
          : 'Offline ready: ${status!.modelName}.';
    }
    if (status?.installed ?? false) {
      return 'Offline model found, but local runtime is unavailable.';
    }
    return status?.detail ?? 'Offline model is unavailable.';
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({
    required this.checking,
    required this.mode,
    required this.status,
  });

  final bool checking;
  final AiPreference mode;
  final TranslateOfflineStatus? status;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    if (checking) {
      return SizedBox(
        width: 12,
        height: 12,
        child: CircularProgressIndicator(strokeWidth: 1.5, color: cs.primary),
      );
    }
    final Color color = switch (mode) {
      AiPreference.cloud => cs.primary,
      AiPreference.local when status?.usable ?? false =>
        const Color(0xFF46B986),
      _ => cs.error,
    };
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ─── Input Action Chip ────────────────────────────────────────────────────────

class _InputActionChip extends StatelessWidget {
  const _InputActionChip({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 13, color: cs.onSurface),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
