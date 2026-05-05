import 'package:flutter/material.dart';

import 'output_action_pill.dart';

class OutputActions extends StatelessWidget {
  const OutputActions({
    super.key,
    required this.copyLabel,
    required this.shareLabel,
    required this.onCopy,
    required this.onShare,
  });

  final String copyLabel;
  final String shareLabel;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutputActionPill(
          icon: Icons.copy_rounded,
          label: copyLabel,
          onTap: onCopy,
        ),
        const SizedBox(width: 8),
        OutputActionPill(
          icon: Icons.share_rounded,
          label: shareLabel,
          onTap: onShare,
        ),
      ],
    );
  }
}
