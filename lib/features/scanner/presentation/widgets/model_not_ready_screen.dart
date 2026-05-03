import 'package:flutter/material.dart';

/// Shown on mobile when the Baybayin YOLO model has not yet been bundled.
/// Replace with a real error screen once the model is exported and ready.
class ModelNotReadyScreen extends StatelessWidget {
  const ModelNotReadyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _ModelNotReadyContent(cs: cs),
          ),
        ),
      ),
    );
  }
}

class _ModelNotReadyContent extends StatelessWidget {
  const _ModelNotReadyContent({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          Icons.construction_rounded,
          size: 56,
          color: cs.primary.withAlpha(180),
        ),
        const SizedBox(height: 20),
        Text(
          'Scanner Coming Soon',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'The Baybayin character recognition model is '
          'still being prepared. Check back in a future update!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: cs.onSurface.withAlpha(160),
          ),
        ),
      ],
    );
  }
}
