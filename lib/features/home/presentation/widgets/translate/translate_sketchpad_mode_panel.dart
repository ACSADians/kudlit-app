import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/providers/translate_sketchpad_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/learn/live_stroke_painter.dart';

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
  final List<List<Offset>> _strokes = <List<Offset>>[];
  final List<Offset> _current = <Offset>[];

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

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current
        ..clear()
        ..add(d.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() => _current.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails _) {
    if (_current.isNotEmpty) {
      setState(() {
        _strokes.add(List<Offset>.from(_current));
        _current.clear();
      });
    }
  }

  void _clear() {
    setState(() {
      _strokes.clear();
      _current.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canRequest =
        widget.aiActionsEnabled &&
        !widget.state.aiBusy &&
        _strokes.isNotEmpty &&
        widget.state.target.trim().isNotEmpty;

    final bool showFeedback =
        widget.state.aiBusy || widget.state.aiResponse.trim().isNotEmpty;

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _InlineCanvas(
            target: widget.state.target,
            strokes: _strokes,
            currentStroke: _current,
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
          ),
        ),
        if (showFeedback)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _ButtyFeedback(
                text: widget.state.aiResponse,
                isLoading: widget.state.aiBusy,
              ),
            ),
          )
        else
          const Spacer(),
        _BottomBar(
          targetController: _targetController,
          state: widget.state,
          canRequest: canRequest,
          disabledReason: widget.disabledReason,
          hasStrokes: _strokes.isNotEmpty,
          onTargetChanged: widget.onTargetChanged,
          onClear: _clear,
          onGetFeedback: () => widget.onGetFeedback(_strokes),
        ),
      ],
    );
  }
}

class _InlineCanvas extends StatelessWidget {
  const _InlineCanvas({
    required this.target,
    required this.strokes,
    required this.currentStroke,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final String target;
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String preview = target.trim().isEmpty ? '?' : target.trim();
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onPanStart: onPanStart,
              onPanUpdate: onPanUpdate,
              onPanEnd: onPanEnd,
              child: CustomPaint(
                painter: LiveStrokePainter(
                  strokes: strokes,
                  current: currentStroke,
                  strokeColor: cs.onSurface,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 12,
              child: Text(
                preview,
                style: TextStyle(
                  fontFamily: 'Baybayin Simple TAWBID',
                  fontSize: 48,
                  color: cs.onSurface.withAlpha(18),
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.targetController,
    required this.state,
    required this.canRequest,
    required this.disabledReason,
    required this.hasStrokes,
    required this.onTargetChanged,
    required this.onClear,
    required this.onGetFeedback,
  });

  final TextEditingController targetController;
  final TranslateSketchpadState state;
  final bool canRequest;
  final String? disabledReason;
  final bool hasStrokes;
  final ValueChanged<String> onTargetChanged;
  final VoidCallback onClear;
  final VoidCallback onGetFeedback;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: cs.outline.withAlpha(80))),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: targetController,
                  onChanged: onTargetChanged,
                  maxLength: 2,
                  decoration: InputDecoration(
                    hintText: 'Target glyph (e.g. ba)',
                    filled: true,
                    fillColor: cs.surfaceContainerLow,
                    isDense: true,
                    counterText: '',
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
                    hintStyle: TextStyle(
                      color: cs.onSurface.withAlpha(120),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _PillButton(
                label: 'Clear',
                enabled: hasStrokes,
                onTap: onClear,
              ),
              const SizedBox(width: 8),
              _PillButton(
                label: state.aiBusy ? 'Working...' : 'Get Feedback',
                enabled: canRequest,
                primary: true,
                onTap: onGetFeedback,
              ),
            ],
          ),
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

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.enabled,
    required this.onTap,
    this.primary = false,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = switch ((primary, enabled)) {
      (true, true) => cs.primary,
      (true, false) => cs.surfaceContainerLowest,
      (false, true) => cs.surfaceContainer,
      _ => cs.surfaceContainerLowest,
    };
    final Color fg = switch ((primary, enabled)) {
      (true, true) => cs.onPrimary,
      _ => cs.onSurface.withAlpha(enabled ? 220 : 110),
    };
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: cs.outline),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class _ButtyFeedback extends StatelessWidget {
  const _ButtyFeedback({required this.text, required this.isLoading});

  final String text;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool showDots = isLoading && text.trim().isEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Butty avatar circle.
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/brand/ButtyPaint.webp',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Speech bubble.
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: cs.outline),
              ),
              child: showDots
                  ? const _ThinkingDots()
                  : Text(
                      text.trim(),
                      style: TextStyle(
                        fontSize: 13.5,
                        color: cs.onSurface.withAlpha(220),
                        height: 1.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThinkingDots extends StatefulWidget {
  const _ThinkingDots();

  @override
  State<_ThinkingDots> createState() => _ThinkingDotsState();
}

class _ThinkingDotsState extends State<_ThinkingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
        final int next = (_ctrl.value * 3).floor() + 1;
        if (next != _dotCount) setState(() => _dotCount = next);
      });
    _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Text(
      'Butty is thinking${'.' * _dotCount}',
      style: TextStyle(
        fontSize: 13.5,
        color: cs.onSurface.withAlpha(140),
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
