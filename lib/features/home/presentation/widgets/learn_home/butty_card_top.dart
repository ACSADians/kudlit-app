import 'package:flutter/material.dart';

class ButtyCardTop extends StatelessWidget {
  const ButtyCardTop({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Row(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primaryContainer,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/brand/ButtyRead.webp',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 1,
              right: 1,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: const Color(0xFF46B986),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surfaceContainerLow, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Butty',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'AI tutor · always available',
              style: TextStyle(
                fontSize: 11,
                color: cs.onSurface.withAlpha(140),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
