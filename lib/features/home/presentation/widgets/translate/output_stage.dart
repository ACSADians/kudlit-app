import 'package:flutter/material.dart';

import 'empty_output.dart';
import 'filled_output.dart';

class OutputStage extends StatelessWidget {
  const OutputStage({
    super.key,
    required this.baybayinText,
    required this.latinText,
    required this.hasInput,
  });

  final String baybayinText;
  final String latinText;
  final bool hasInput;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: hasInput
            ? FilledOutput(baybayin: baybayinText, latin: latinText)
            : const EmptyOutput(),
      ),
    );
  }
}
