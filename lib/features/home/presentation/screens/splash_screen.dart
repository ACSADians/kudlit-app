import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';

/// Startup splash screen shown while auth state resolves.
///
/// Pre-warms [baybayinDetectorProvider] on mobile so the YOLO controller
/// is instantiated before the camera tab opens, avoiding a cold-start delay.
///
/// Navigation is handled entirely by the router's redirect — this screen
/// simply holds until auth loading finishes, at which point the redirect
/// sends the user to home or login automatically.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Pre-warm the detector on mobile so it's alive before the scan tab.
    if (!kIsWeb) {
      ref.watch(baybayinDetectorProvider);
    }

    return const _SplashContent();
  }
}

class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: KudlitColors.neutralBlack,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _KudlitLogo(),
            SizedBox(height: 48),
            _LoadingIndicator(),
          ],
        ),
      ),
    );
  }
}

class _KudlitLogo extends StatelessWidget {
  const _KudlitLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image.asset(
          'assets/brand/kudlit-logo.png',
          width: 72,
          height: 72,
          errorBuilder: (BuildContext context, Object error, StackTrace? _) =>
              const _FallbackMark(),
        ),
        const SizedBox(height: 16),
        const Text(
          'Kudlit',
          style: TextStyle(
            color: KudlitColors.blue900,
            fontSize: 32,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Baybayin · Learn · Translate',
          style: TextStyle(
            color: KudlitColors.grey300,
            fontSize: 13,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}

/// Shown when the logo asset is missing (e.g. web or missing file).
class _FallbackMark extends StatelessWidget {
  const _FallbackMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: KudlitColors.blue400,
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      child: const Text(
        'K',
        style: TextStyle(
          color: KudlitColors.blue900,
          fontSize: 40,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: KudlitColors.blue700,
      ),
    );
  }
}
