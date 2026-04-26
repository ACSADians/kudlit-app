import 'package:flutter/material.dart';

class FeedbackCard extends StatelessWidget {
  const FeedbackCard({super.key, required this.correct, required this.text});

  final bool correct;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color accentColor = correct ? const Color(0xFF46B986) : cs.error;
    final Color borderColor = accentColor.withAlpha(120);
    final Color bgColor = accentColor.withAlpha(40);
    final IconData icon = correct
        ? Icons.check_circle_outline
        : Icons.error_outline;
    final String verdict = correct ? 'Correct' : 'Not quite';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, size: 18, color: accentColor),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    verdict,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 13,
                      color: cs.onSurface.withAlpha(210),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
