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
    final double heroHeight = MediaQuery.sizeOf(context).height * heroFraction;

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

/// Scrollable container with the branded rounded-top decoration.
/// Wrap the column content of each auth sheet with this.
class AuthSheet extends StatelessWidget {
  const AuthSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x260E1425),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
          child: child,
        ),
      ),
    );
  }
}

/// Small pill handle at the top of every auth sheet.
class AuthDragHandle extends StatelessWidget {
  const AuthDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

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
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface.withAlpha(153),
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
