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
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: cs.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
    );
  }
}
