import 'package:flutter/material.dart';

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
    required this.onDirectionChanged,
    required this.onInputChanged,
    required this.onClear,
    required this.onExplain,
    required this.onCheckInput,
    required this.onCopy,
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 160),
            child: OutputStage(
              baybayinText: state.baybayinText,
              latinText: state.latinText,
              hasInput: state.hasInput,
            ),
          ),
          _TextActionsRow(
            busy: state.aiBusy,
            enabled: inputEnabled && state.hasInput,
            copyEnabled: state.hasInput,
            onExplain: onExplain,
            onCheckInput: onCheckInput,
            onCopy: onCopy,
          ),
          if (disabledReason != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              disabledReason!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
            ),
          ],
          const SizedBox(height: 10),
          DirectionToggle(
            latinToBaybayin: state.latinToBaybayin,
            onToggle: onDirectionChanged,
          ),
          _TextInputField(
            text: state.inputText,
            enabled: inputEnabled && !state.aiBusy,
            onChanged: onInputChanged,
            onClear: onClear,
            hintText: state.latinToBaybayin
                ? 'Type in Filipino...'
                : 'Type Baybayin Unicode...',
          ),
          if (state.feedbackMessages.isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            for (final String note in state.feedbackMessages)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $note',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(175),
                  ),
                ),
              ),
          ],
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
    );
  }
}

class _TextInputField extends StatefulWidget {
  const _TextInputField({
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
  State<_TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<_TextInputField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.text;
    _controller.addListener(() => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant _TextInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text == widget.text) {
      return;
    }
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
    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: widget.enabled,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isDense: true,
                hintStyle: TextStyle(
                  color: cs.onSurface.withAlpha(120),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onClear();
              },
              child: Icon(
                Icons.close_rounded,
                size: 18,
                color: cs.onSurface.withAlpha(130),
              ),
            ),
        ],
      ),
    );
  }
}

class _TextActionsRow extends StatelessWidget {
  const _TextActionsRow({
    required this.busy,
    required this.enabled,
    required this.copyEnabled,
    required this.onExplain,
    required this.onCheckInput,
    required this.onCopy,
  });

  final bool busy;
  final bool enabled;
  final bool copyEnabled;
  final VoidCallback onExplain;
  final VoidCallback onCheckInput;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        _ActionButton(
          label: busy ? 'Working...' : 'Explain',
          enabled: enabled && !busy,
          onTap: onExplain,
        ),
        _ActionButton(
          label: 'Check Input',
          enabled: enabled && !busy,
          onTap: onCheckInput,
        ),
        _ActionButton(label: 'Copy', enabled: copyEnabled, onTap: onCopy),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
