import 'package:flutter/material.dart';

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
    required this.onDirectionChanged,
    required this.onInputChanged,
    required this.onClear,
    required this.onExplain,
    required this.onCheckInput,
    required this.onCopy,
    required this.onShare,
    this.compactLayout = false,
  });

  final TranslateTextState state;
  final bool inputEnabled;
  final String? disabledReason;
  final ValueChanged<bool> onDirectionChanged;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onClear;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final bool compactLayout;

  @override
  Widget build(BuildContext context) {
    if (compactLayout) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 4),
        child: _BottomInputArea(
          state: state,
          inputEnabled: inputEnabled,
          disabledReason: disabledReason,
          compact: true,
          onDirectionChanged: onDirectionChanged,
          onInputChanged: onInputChanged,
          onClear: onClear,
          onExplain: onExplain,
          onCheckInput: onCheckInput,
        ),
      );
    }

    if (!state.hasInput && state.aiResponse.trim().isEmpty) {
      final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
      final double previewHeight = keyboardOpen
          ? 92
          : MediaQuery.sizeOf(context).height < 700
          ? 132
          : 172;
      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 4),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
              child: SizedBox(
                height: previewHeight,
                child: const Center(child: EmptyOutput()),
              ),
            ),
            _BottomInputArea(
              state: state,
              inputEnabled: inputEnabled,
              disabledReason: disabledReason,
              compact: false,
              onDirectionChanged: onDirectionChanged,
              onInputChanged: onInputChanged,
              onClear: onClear,
              onExplain: onExplain,
              onCheckInput: onCheckInput,
            ),
          ],
        ),
      );
    }

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
          compact: false,
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
    required this.compact,
    required this.onDirectionChanged,
    required this.onInputChanged,
    required this.onClear,
    required this.onExplain,
    required this.onCheckInput,
  });

  final TranslateTextState state;
  final bool inputEnabled;
  final String? disabledReason;
  final bool compact;
  final ValueChanged<bool> onDirectionChanged;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onClear;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bool keyboardCompact = compact || keyboardOpen;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline.withAlpha(80))),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        keyboardCompact ? 4 : 10,
        16,
        keyboardCompact ? 6 : 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DirectionToggle(
            latinToBaybayin: state.latinToBaybayin,
            compact: keyboardCompact,
            onToggle: onDirectionChanged,
          ),
          SizedBox(height: keyboardCompact ? 4 : 8),
          _InputField(
            text: state.inputText,
            enabled: inputEnabled && !state.aiBusy,
            expanded: !keyboardCompact,
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
              compact: keyboardCompact,
              onExplain: onExplain,
              onCheckInput: onCheckInput,
            ),
          ],
          if (disabledReason != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              disabledReason!,
              style: TextStyle(
                fontSize: 12,
                color: cs.onSurface.withAlpha(160),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InputField extends StatefulWidget {
  const _InputField({
    required this.text,
    required this.enabled,
    required this.expanded,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  final String text;
  final bool enabled;
  final bool expanded;
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
    _controller.addListener(() => setState(() {}));
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
      key: ValueKey<String>(
        widget.hintText.contains('Baybayin Unicode')
            ? 'translate-baybayin-unicode-input'
            : 'translate-filipino-input',
      ),
      controller: _controller,
      enabled: widget.enabled,
      keyboardType: widget.expanded
          ? TextInputType.multiline
          : TextInputType.text,
      textInputAction: widget.expanded
          ? TextInputAction.newline
          : TextInputAction.done,
      minLines: widget.expanded ? 4 : 1,
      maxLines: widget.expanded ? 7 : 1,
      textAlignVertical: widget.expanded
          ? TextAlignVertical.top
          : TextAlignVertical.center,
      onChanged: widget.onChanged,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: cs.surfaceContainerLow,
        isDense: !widget.expanded,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 14,
          vertical: widget.expanded ? 14 : 12,
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
        hintStyle: TextStyle(color: cs.onSurface.withAlpha(120), fontSize: 14),
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
    required this.compact,
    required this.onExplain,
    required this.onCheckInput,
  });

  final bool busy;
  final bool enabled;
  final bool compact;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        children: <Widget>[
          Expanded(
            child: _ActionButton(
              label: busy ? 'Working...' : 'Explain',
              enabled: enabled && !busy,
              compact: true,
              onTap: onExplain,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'Check Input',
              enabled: enabled && !busy,
              compact: true,
              onTap: onCheckInput,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _ActionButton(
          label: busy ? 'Working...' : 'Explain',
          enabled: enabled && !busy,
          compact: false,
          onTap: onExplain,
        ),
        _ActionButton(
          label: 'Check Input',
          enabled: enabled && !busy,
          compact: false,
          onTap: onCheckInput,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: enabled ? onTap : null,
        child: Container(
          constraints: BoxConstraints(minHeight: compact ? 40 : 44),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 7 : 9,
          ),
          decoration: BoxDecoration(
            color: enabled ? cs.surfaceContainer : cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: enabled ? cs.outline : cs.outline.withAlpha(90),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: enabled ? cs.onSurface : cs.onSurface.withAlpha(120),
            ),
          ),
        ),
      ),
    );
  }
}
