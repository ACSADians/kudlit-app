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
    final String? actionReason = _disabledReason(canRequest);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _SketchpadIntro(target: widget.state.target),
          const SizedBox(height: 12),
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
          ] else if (actionReason != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              actionReason,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(170),
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            'Sketch feedback uses your selected Gemma mode.',
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(120),
            ),
          ),
          const SizedBox(height: 10),
          _SketchSummary(
            strokeCount: _latestStrokes.length,
            pointCount: _latestStrokes.fold<int>(
              0,
              (int total, List<Offset> stroke) => total + stroke.length,
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

  String? _disabledReason(bool canRequest) {
    if (canRequest) return null;
    if (!widget.aiActionsEnabled) {
      return widget.disabledReason ?? 'Model unavailable for sketch feedback.';
    }
    if (widget.state.aiBusy) return 'Feedback is already running.';
    if (widget.state.target.trim().isEmpty) {
      return 'Enter a target before opening feedback.';
    }
    if (_latestStrokes.isEmpty) {
      return 'Draw first, then request feedback.';
    }
    return null;
  }
}

class _SketchpadIntro extends StatelessWidget {
  const _SketchpadIntro({required this.target});

  final String target;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String preview = target.trim().isEmpty ? 'ba' : target.trim();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: cs.outline),
            ),
            child: Text(
              preview,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Baybayin Simple TAWBID',
                fontSize: 28,
                color: cs.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Sketch a Target',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter the glyph or syllable you want to practice, then draw it in the sheet.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: cs.onSurface.withAlpha(165),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SketchSummary extends StatelessWidget {
  const _SketchSummary({required this.strokeCount, required this.pointCount});

  final int strokeCount;
  final int pointCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool hasSketch = strokeCount > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: hasSketch ? cs.surfaceContainerLow : cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            hasSketch ? Icons.gesture_rounded : Icons.edit_outlined,
            size: 18,
            color: cs.onSurface.withAlpha(150),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasSketch
                  ? 'Sketch ready: $strokeCount stroke(s), $pointCount points.'
                  : 'No sketch yet. Open Sketchpad and draw your target.',
              style: TextStyle(
                fontSize: 12.5,
                color: cs.onSurface.withAlpha(175),
              ),
            ),
          ),
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
