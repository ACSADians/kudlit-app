import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/utils/safe_ai_output.dart';

class TranslateFeedbackCard extends StatelessWidget {
  const TranslateFeedbackCard({
    super.key,
    required this.title,
    required this.body,
    this.warning,
    this.tryThis,
    this.sourceLabel,
  });

  final String title;
  final String body;
  final String? warning;
  final String? tryThis;
  final String? sourceLabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String displayBody = cleanAssistantOutput(body);
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
            displayBody,
            style: TextStyle(fontSize: 13, color: cs.onSurface.withAlpha(195)),
          ),
          if (warning != null && warning!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 10),
            _FeedbackSlot(
              label: 'Warning',
              body: warning!,
              icon: Icons.info_outline_rounded,
              color: cs.error,
            ),
          ],
          if (tryThis != null && tryThis!.trim().isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            _FeedbackSlot(
              label: 'Try this',
              body: tryThis!,
              icon: Icons.tips_and_updates_outlined,
              color: cs.primary,
            ),
          ],
        ],
      ),
    );
  }
}

class _FeedbackSlot extends StatelessWidget {
  const _FeedbackSlot({
    required this.label,
    required this.body,
    required this.icon,
    required this.color,
  });

  final String label;
  final String body;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon, size: 15, color: color.withAlpha(190)),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 12.5,
                height: 1.35,
                color: cs.onSurface.withAlpha(185),
              ),
              children: <InlineSpan>[
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                TextSpan(text: body),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
