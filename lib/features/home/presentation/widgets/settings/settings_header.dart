import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/home/domain/entities/profile_summary.dart';
import 'package:kudlit_ph/features/home/presentation/providers/profile_management_provider.dart';

/// Hero-style header for the Settings / profile dashboard.
///
/// Ocean-tinted gradient (deep teal → cyan → foam) with a wave-shaped lower
/// edge and Butty mascot peeking from the right. Mirrors the visual energy
/// of [LearningProgressScreen]'s `SliverAppBar` so the profile dashboard feels
/// like a destination, not a plain page.
class SettingsHeader extends ConsumerWidget {
  const SettingsHeader({super.key});

  // Ocean palette — chosen to harmonize with cs.primary while feeling
  // distinctly "beach": deep, teal, cyan, foam.
  static const Color _deep = Color(0xFF0A4D68);
  static const Color _teal = Color(0xFF088395);
  static const Color _cyan = Color(0xFF05BFDB);
  static const Color _foam = Color(0xFFBBE1FA);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AuthUser? user = ref.watch(authNotifierProvider).value;
    final ProfileSummary? summary =
        ref.watch(profileSummaryNotifierProvider).value?.toNullable();
    final String? name = (summary?.displayName ?? user?.displayName)?.trim();
    final String greeting = _greeting(name);

    return ClipPath(
      clipper: const _WaveClipper(),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[_deep, _teal, _cyan],
            stops: <double>[0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: 168,
            child: Stack(
              children: <Widget>[
                // Decorative bubbles for ocean feel.
                Positioned(
                  top: 18,
                  right: 110,
                  child: _Bubble(size: 8, color: _foam.withAlpha(120)),
                ),
                Positioned(
                  top: 56,
                  right: 170,
                  child: _Bubble(size: 5, color: _foam.withAlpha(160)),
                ),
                Positioned(
                  bottom: 28,
                  left: 90,
                  child: _Bubble(size: 6, color: _foam.withAlpha(110)),
                ),
                // Butty mascot.
                Positioned(
                  right: -6,
                  bottom: 0,
                  child: Image.asset(
                    'assets/brand/ButtyWave.webp',
                    height: 132,
                    fit: BoxFit.fitHeight,
                  )
                      .animate(delay: 80.ms)
                      .slideX(
                        begin: 0.25,
                        end: 0,
                        duration: 420.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: 320.ms),
                ),
                // Back + title bar.
                Positioned(
                  left: 4,
                  right: 4,
                  top: 0,
                  child: Row(
                    children: <Widget>[
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                // Greeting block.
                Positioned(
                  left: 20,
                  right: 140,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _foam.withAlpha(120)),
                        ),
                        child: Text(
                          'KUDLIT · BEACH MODE',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: _foam,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        greeting,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.25,
                        ),
                      )
                          .animate(delay: 80.ms)
                          .fadeIn(duration: 260.ms)
                          .slideY(begin: 0.1, end: 0, duration: 260.ms),
                      const SizedBox(height: 4),
                      const Text(
                        'Profile, history, and Butty.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _foam,
                          fontWeight: FontWeight.w500,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _greeting(String? name) {
    final String trimmed = (name ?? '').trim();
    if (trimmed.isEmpty) return 'Kumusta!\nWelcome back to Kudlit.';
    return 'Kumusta, $trimmed!\nManage your journey here.';
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
        .moveY(
          begin: 0,
          end: -6,
          duration: 1800.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Soft wave on the bottom edge — gives the header that "shoreline" feeling
/// without committing to a heavy custom paint pass.
class _WaveClipper extends CustomClipper<Path> {
  const _WaveClipper();

  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..lineTo(0, size.height - 22)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        size.width * 0.5,
        size.height - 16,
      )
      ..quadraticBezierTo(
        size.width * 0.78,
        size.height - 32,
        size.width,
        size.height - 12,
      )
      ..lineTo(size.width, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
