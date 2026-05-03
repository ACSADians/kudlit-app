import 'package:flutter/material.dart';

class ProfileHeroAvatar extends StatelessWidget {
  const ProfileHeroAvatar({
    super.key,
    required this.initials,
    required this.onTap,
  });

  final String initials;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.primaryContainer,
              border: Border.all(color: cs.primary.withAlpha(60), width: 2),
            ),
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: cs.primary,
              ),
            ),
          ),
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
              border: Border.all(color: cs.outline, width: 1.5),
            ),
            child: Icon(Icons.add_a_photo_outlined, size: 11, color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
