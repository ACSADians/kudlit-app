import 'package:flutter/material.dart';

import 'empty_output.dart';
import 'filled_output.dart';

class OutputStage extends StatelessWidget {
  const OutputStage({
    super.key,
    required this.baybayinText,
    required this.latinText,
    required this.hasInput,
    required this.copyLabel,
    required this.shareLabel,
    required this.onCopy,
    required this.onShare,
  });

  final String baybayinText;
  final String latinText;
  final bool hasInput;
  final String copyLabel;
  final String shareLabel;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: hasInput
            ? FilledOutput(
                baybayin: baybayinText,
                latin: latinText,
                copyLabel: copyLabel,
                shareLabel: shareLabel,
                onCopy: onCopy,
                onShare: onShare,
              )
            : const EmptyOutput(),
      ),
    );
  }
}
