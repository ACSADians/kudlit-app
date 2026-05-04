import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_sketchpad_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/drawing_pad_sheet.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_feedback_card.dart';

class TranslateSketchpadModePanel extends StatefulWidget {
  const TranslateSketchpadModePanel({
    super.key,
    required this.state,
    required this.aiActionsEnabled,
    required this.disabledReason,
    required this.onTargetChanged,
    required this.onGetFeedback,
  });

  final TranslateSketchpadState state;
  final bool aiActionsEnabled;
  final String? disabledReason;
  final ValueChanged<String> onTargetChanged;
  final Future<void> Function(List<List<Offset>> strokes) onGetFeedback;

  @override
  State<TranslateSketchpadModePanel> createState() =>
      _TranslateSketchpadModePanelState();
}

class _TranslateSketchpadModePanelState
    extends State<TranslateSketchpadModePanel> {
  final TextEditingController _targetController = TextEditingController();
  List<List<Offset>> _latestStrokes = <List<Offset>>[];

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TranslateSketchpadModePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    final String nextTarget = widget.state.target;
    if (_targetController.text != nextTarget) {
      _targetController.value = TextEditingValue(
        text: nextTarget,
        selection: TextSelection.collapsed(offset: nextTarget.length),
      );
    }
  }

  Future<void> _openPad() async {
    final String target = _targetController.text.trim();
    if (target.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Enter a target first.')));
      }
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DrawingPadSheet(
          targetGlyph: target,
          targetLabel: target,
          onSubmit: (List<List<Offset>> strokes) {
            setState(() => _latestStrokes = strokes);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canRequest =
        widget.aiActionsEnabled &&
        !widget.state.aiBusy &&
        _latestStrokes.isNotEmpty &&
        widget.state.target.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TextField(
            controller: _targetController,
            onChanged: widget.onTargetChanged,
            decoration: const InputDecoration(
              labelText: 'Target glyph or syllable',
              hintText: 'e.g. ᜊ (ba) or "ba"',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _ActionButton(
                label: 'Open Sketchpad',
                enabled: widget.state.target.trim().isNotEmpty,
                onTap: _openPad,
              ),
              _ActionButton(
                label: widget.state.aiBusy ? 'Working...' : 'Get Feedback',
                enabled: canRequest,
                onTap: () => widget.onGetFeedback(_latestStrokes),
              ),
              _ActionButton(
                label: 'Clear',
                enabled: _latestStrokes.isNotEmpty,
                onTap: () => setState(() => _latestStrokes = <List<Offset>>[]),
              ),
            ],
          ),
          if (widget.disabledReason != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              widget.disabledReason!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _latestStrokes.isEmpty
                ? 'No sketch yet. Open Sketchpad and draw your target.'
                : 'Sketch ready: ${_latestStrokes.length} stroke(s).',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(175),
            ),
          ),
          if (widget.state.aiResponse.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            TranslateFeedbackCard(
              title: 'Sketch feedback',
              body: widget.state.aiResponse,
              sourceLabel: widget.state.aiSource?.label,
            ),
          ],
        ],
      ),
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
