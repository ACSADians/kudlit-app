import 'dart:io';

import 'package:flutter/material.dart';

/// Shown when the current device does not meet the minimum OS requirements
/// to run on-device YOLO inference.
///
/// Android requires API 23 (Android 6.0) or later for TFLite + CameraX.
/// iOS requires 12.0 or later for CoreML 2.
class ModelNotSupportedScreen extends StatelessWidget {
  const ModelNotSupportedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return ColoredBox(
      color: cs.surface,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _ModelNotSupportedContent(cs: cs),
          ),
        ),
      ),
    );
  }
}

class _ModelNotSupportedContent extends StatelessWidget {
  const _ModelNotSupportedContent({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(Icons.block_rounded, size: 56, color: cs.error.withAlpha(200)),
        const SizedBox(height: 20),
        Text(
          'Device Not Supported',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _subtitle,
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

  String get _subtitle {
    if (Platform.isAndroid) {
      return 'On-device Baybayin recognition requires '
          'Android 6.0 (API 23) or later.';
    }
    if (Platform.isIOS) {
      return 'On-device Baybayin recognition requires iOS 12.0 or later.';
    }
    return 'On-device Baybayin recognition is not supported on this platform.';
  }
}
