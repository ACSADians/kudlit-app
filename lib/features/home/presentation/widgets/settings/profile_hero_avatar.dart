import 'package:flutter/material.dart';

/// Circular avatar with a subtle ocean-tinted ring. Quiet by design —
/// the camera badge is small and unobtrusive.
class ProfileHeroAvatar extends StatelessWidget {
  const ProfileHeroAvatar({
    super.key,
    required this.initials,
    required this.avatarUrl,
    required this.onTap,
    this.isUploading = false,
  });

  final String initials;
  final String? avatarUrl;
  final VoidCallback? onTap;
  final bool isUploading;

  static const Color _deep = Color(0xFF0A4D68);
  static const Color _cyan = Color(0xFF05BFDB);

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String? safeAvatarUrl =
        avatarUrl != null && avatarUrl!.trim().isNotEmpty
        ? avatarUrl!.trim()
        : null;
    return Semantics(
      label: 'Profile picture, $initials',
      hint: isUploading
          ? 'Avatar upload is in progress'
          : 'Double tap to choose a new profile picture',
      button: true,
      enabled: onTap != null,
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
                clipBehavior: Clip.antiAlias,
                child: _AvatarFace(
                  avatarUrl: safeAvatarUrl,
                  initials: initials,
                  isUploading: isUploading,
                ),
              ),
            ),
            // Small camera badge with a full 44x44 touch target.
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cs.surface,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: isUploading
                          ? Padding(
                              padding: const EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.primary,
                              ),
                            )
                          : Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
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

class _AvatarFace extends StatelessWidget {
  const _AvatarFace({
    required this.avatarUrl,
    required this.initials,
    required this.isUploading,
  });

  final String? avatarUrl;
  final String initials;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Widget face = avatarUrl != null
        ? Image.network(
            avatarUrl!,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder:
                (BuildContext context, Object error, StackTrace? stack) {
                  return Center(child: _InitialsLabel(initials: initials));
                },
          )
        : Center(child: _InitialsLabel(initials: initials));

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        face,
        if (isUploading)
          ColoredBox(
            color: cs.scrim.withAlpha(72),
            child: Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _InitialsLabel extends StatelessWidget {
  const _InitialsLabel({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    return Text(
      initials,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: ProfileHeroAvatar._deep,
        letterSpacing: -0.5,
      ),
    );
  }
}
