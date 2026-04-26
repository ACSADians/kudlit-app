import 'package:flutter/material.dart';

import 'pad_button.dart';

class PadActions extends StatelessWidget {
  const PadActions({
    super.key,
    required this.hasStrokes,
    required this.onClear,
    required this.onSubmit,
  });

  final bool hasStrokes;
  final VoidCallback onClear;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Row(
        children: <Widget>[
          PadButton(
            label: 'Clear',
            onTap: hasStrokes ? onClear : null,
            primary: false,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PadButton(
              label: 'Submit',
              onTap: hasStrokes ? onSubmit : null,
              primary: true,
            ),
          ),
        ],
      ),
    );
  }
}
