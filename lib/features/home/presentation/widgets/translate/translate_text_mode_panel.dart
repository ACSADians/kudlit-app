import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/direction_toggle.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/empty_output.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/filled_output.dart';
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Center(
              child: state.hasInput
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        FilledOutput(
                          baybayin: state.baybayinText,
                          latin: state.latinText,
                          copyLabel: 'Copy',
                          shareLabel: 'Share',
                          onCopy: onCopy,
                          onShare: onShare,
                        ),
                        if (state.aiResponse.trim().isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          TranslateFeedbackCard(
                            title: 'AI feedback',
                            body: state.aiResponse,
                            sourceLabel: state.aiSource?.label,
                          ),
                        ],
                      ],
                    )
                  : const EmptyOutput(),
            ),
          ),
        ),
        _BottomInputArea(
          state: state,
          inputEnabled: inputEnabled,
          disabledReason: disabledReason,
          aiMode: aiMode,
          offlineStatus: offlineStatus,
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

class _BottomInputArea extends StatelessWidget {
  const _BottomInputArea({
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

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool checking =
        aiMode == AiPreference.local && offlineStatus.isLoading;
    final TranslateOfflineStatus? status = offlineStatus.value;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline.withAlpha(80))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DirectionToggle(
            latinToBaybayin: state.latinToBaybayin,
            onToggle: onDirectionChanged,
          ),
          const SizedBox(height: 8),
          _InputField(
            text: state.inputText,
            enabled: inputEnabled && !state.aiBusy,
            hintText: state.latinToBaybayin
                ? 'Type in Filipino...'
                : 'Type Baybayin Unicode...',
            onChanged: onInputChanged,
            onClear: onClear,
          ),
          if (state.hasInput) ...<Widget>[
            const SizedBox(height: 8),
            _TextActionsRow(
              busy: state.aiBusy,
              enabled: inputEnabled && state.hasInput,
              onExplain: onExplain,
              onCheckInput: onCheckInput,
            ),
          ],
          const SizedBox(height: 6),
          _AiStatusHint(
            checking: checking,
            mode: aiMode,
            status: status,
            disabledReason: disabledReason,
          ),
        ],
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  const _InputField({
    required this.text,
    required this.enabled,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final String text;
  final bool enabled;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<_InputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
  }

  @override
  void didUpdateWidget(covariant _InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.text) return;
    _controller.value = TextEditingValue(
      text: widget.text,
      selection: TextSelection.collapsed(offset: widget.text.length),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return TextField(
      controller: _controller,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cs.outline.withAlpha(100)),
        ),
        hintStyle: TextStyle(
          color: cs.onSurface.withAlpha(120),
          fontSize: 14,
        ),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: cs.onSurface.withAlpha(130),
                ),
                onPressed: () {
                  _controller.clear();
                  widget.onClear();
                },
              )
            : null,
      ),
    );
  }
}

class _TextActionsRow extends StatelessWidget {
  const _TextActionsRow({
    required this.busy,
    required this.enabled,
    required this.onExplain,
    required this.onCheckInput,
  });

  final bool busy;
  final bool enabled;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _InputActionChip(
          label: busy ? 'Working…' : 'Explain',
          icon: Icons.auto_awesome_rounded,
          enabled: enabled && !busy,
          onTap: onExplain,
        ),
        const SizedBox(width: 6),
        _InputActionChip(
          label: 'Check',
          icon: Icons.spellcheck_rounded,
          enabled: enabled && !busy,
          onTap: onCheckInput,
        ),
      ],
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
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: enabled ? cs.surfaceContainer : cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: cs.outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? cs.onSurface : cs.onSurface.withAlpha(110),
          ),
        ),
      ),
    );
  }
}
