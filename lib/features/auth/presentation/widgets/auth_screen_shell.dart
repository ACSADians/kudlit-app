import 'package:flutter/material.dart';

/// Shared scaffold for all auth sub-screens: a hero panel overlaid by
/// a rounded bottom-sheet card. Both panels are sized from [heroFraction].
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    required this.hero,
    required this.sheet,
    this.heroFraction = 0.38,
    super.key,
  });

  final Widget hero;
  final Widget sheet;

  /// Fraction of screen height given to the hero (0–1).
  final double heroFraction;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool landscape = screenSize.width > screenSize.height;

    if (landscape) {
      return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(flex: 5, child: hero),
            Expanded(flex: 6, child: sheet),
          ],
        ),
      );
    }

    final double heroHeight = screenSize.height * heroFraction;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: heroHeight,
            child: hero,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: heroHeight - 22,
            bottom: 0,
            child: sheet,
          ),
        ],
      ),
    );
  }
}
