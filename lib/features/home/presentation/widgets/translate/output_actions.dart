import 'package:flutter/material.dart';

import 'output_action_pill.dart';

class OutputActions extends StatelessWidget {
  const OutputActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutputActionPill(icon: Icons.copy_rounded, label: 'Copy', onTap: () {}),
        const SizedBox(width: 8),
        OutputActionPill(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () {},
        ),
      ],
    );
  }
}
