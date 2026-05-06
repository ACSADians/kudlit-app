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
    return Card(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outline),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
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
      ),
    );
  }
}
