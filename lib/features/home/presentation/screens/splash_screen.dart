import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/baybayin_backdrop.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scanner_provider.dart';

/// Startup splash screen shown while auth + preferences resolve.
///
/// Pre-warms [baybayinDetectorProvider] on mobile.
/// Navigation is handled entirely by the router redirect — this screen
/// holds until loading finishes.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kIsWeb) {
      ref.watch(baybayinDetectorProvider);
    }
    return const _SplashBody();
  }
}

class _SplashBody extends StatefulWidget {
  const _SplashBody();

  @override
  State<_SplashBody> createState() => _SplashBodyState();
}

class _SplashBodyState extends State<_SplashBody>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: _kBackground),
      child: Stack(
        children: <Widget>[
          const BaybayinBackdrop(),
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: const _SplashCenter(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const LinearGradient _kBackground = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: <Color>[KudlitColors.blue200, KudlitColors.neutralBlack],
  stops: <double>[0.0, 0.85],
);

class _SplashCenter extends StatelessWidget {
  const _SplashCenter();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[_SplashLogo(), SizedBox(height: 56), _SplashLoader()],
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const <Widget>[
        _SplashMark(),
        SizedBox(height: 20),
        Text(
          'Kudlit',
          style: TextStyle(
            color: KudlitColors.blue900,
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Baybayin · Learn · Translate',
          style: TextStyle(
            color: KudlitColors.grey300,
            fontSize: 13,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class _SplashMark extends StatelessWidget {
  const _SplashMark();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/brand/BaybayInscribe-AppIcon.webp',
      width: 88,
      height: 88,
      errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) =>
          const _FallbackMark(),
    );
  }
}

class _FallbackMark extends StatelessWidget {
  const _FallbackMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      decoration: BoxDecoration(
        color: KudlitColors.blue400,
        borderRadius: BorderRadius.circular(24),
      ),
      alignment: Alignment.center,
      child: const Text(
        'K',
        style: TextStyle(
          color: KudlitColors.blue900,
          fontSize: 48,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: KudlitColors.blue700,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Starting Kudlit…',
          style: TextStyle(
            color: KudlitColors.grey300,
            fontSize: 12,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
