import 'package:flutter/material.dart';

class ProfileStatsBar extends StatelessWidget {
  const ProfileStatsBar({
    super.key,
    required this.lessons,
    required this.scans,
    required this.translations,
  });

  final int lessons;
  final int scans;
  final int translations;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _StatItem(count: lessons, label: 'lessons', cs: cs),
        _Separator(cs: cs),
        _StatItem(count: scans, label: 'scans', cs: cs),
        _Separator(cs: cs),
        _StatItem(count: translations, label: 'translated', cs: cs),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.count,
    required this.label,
    required this.cs,
  });

  final int count;
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          TextSpan(
            text: ' $label',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurface.withAlpha(140),
            ),
          ),
        ],
      ),
    );
  }
}

class _Separator extends StatelessWidget {
  const _Separator({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: cs.onSurface.withAlpha(70),
        ),
      ),
    );
  }
}
