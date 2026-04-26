import 'package:flutter/material.dart';

import 'pad_actions.dart';
import 'pad_canvas.dart';
import 'pad_handle.dart';
import 'pad_header.dart';

class DrawingPadSheet extends StatefulWidget {
  const DrawingPadSheet({
    super.key,
    required this.targetGlyph,
    required this.targetLabel,
    required this.onSubmit,
  });

  final String targetGlyph;
  final String targetLabel;
  final void Function(List<List<Offset>> strokes) onSubmit;

  @override
  State<DrawingPadSheet> createState() => _DrawingPadSheetState();
}

class _DrawingPadSheetState extends State<DrawingPadSheet> {
  final List<List<Offset>> _strokes = <List<Offset>>[];
  final List<Offset> _current = <Offset>[];

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

  void _submit() {
    final List<List<Offset>> result = _strokes
        .map((List<Offset> s) => List<Offset>.from(s))
        .toList();
    Navigator.of(context).pop();
    widget.onSubmit(result);
  }

  @override
  Widget build(BuildContext context) {
    final bool hasStrokes = _strokes.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const PadHandle(),
            PadHeader(
              targetGlyph: widget.targetGlyph,
              targetLabel: widget.targetLabel,
            ),
            PadCanvas(
              strokes: _strokes,
              currentStroke: _current,
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
            ),
            PadActions(
              hasStrokes: hasStrokes,
              onClear: _clear,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
