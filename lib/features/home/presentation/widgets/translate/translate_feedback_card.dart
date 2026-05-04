import 'package:flutter/material.dart';

class TranslateFeedbackCard extends StatelessWidget {
  const TranslateFeedbackCard({
    super.key,
    required this.title,
    required this.body,
    this.sourceLabel,
  });

  final String title;
  final String body;
  final String? sourceLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              if (sourceLabel != null) ...<Widget>[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    sourceLabel!,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(195)),
          ),
        ],
      ),
    );
  }
}
