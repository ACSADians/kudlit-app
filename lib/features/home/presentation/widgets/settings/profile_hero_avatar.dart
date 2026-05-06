import 'package:flutter/material.dart';

/// Circular avatar with a subtle ocean-tinted ring. Quiet by design —
/// the camera badge is small and unobtrusive.
class ProfileHeroAvatar extends StatelessWidget {
  const ProfileHeroAvatar({
    super.key,
    required this.initials,
    required this.onTap,
  });

  final String initials;
  final VoidCallback onTap;

  static const Color _deep = Color(0xFF0A4D68);
  static const Color _cyan = Color(0xFF05BFDB);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Profile picture, $initials',
      button: true,
      child: SizedBox(
        width: 88,
        height: 88,
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            // Thin ocean gradient ring around the avatar.
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[_deep, _cyan],
                ),
              ),
              padding: const EdgeInsets.all(2),
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFE6F4FA),
                ),
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _deep,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            // Small camera badge — tap target is 36x36 via SizedBox + InkWell.
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        size: 12,
                        color: cs.onSurface.withAlpha(150),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
