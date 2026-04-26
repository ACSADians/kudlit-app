import 'package:flutter/material.dart';

import 'butty_card_top.dart';
import 'butty_chat_cta.dart';
import 'butty_preview_bubble.dart';

class ButtyTalkCard extends StatelessWidget {
  const ButtyTalkCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outline),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ButtyCardTop(),
            SizedBox(height: 12),
            ButtyPreviewBubble(),
            SizedBox(height: 10),
            ButtyChatCta(),
          ],
        ),
      ),
    );
  }
}
