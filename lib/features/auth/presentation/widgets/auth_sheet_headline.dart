import 'package:flutter/material.dart';

/// Title + subtitle text block at the top of every auth sheet.
class AuthSheetHeadline extends StatelessWidget {
  const AuthSheetHeadline({
    required this.title,
    required this.subtitle,
    super.key,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            softWrap: true,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          softWrap: true,
          style: TextStyle(
            color: cs.onSurface.withAlpha(185),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
