import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

import 'baybayin_backdrop.dart';

/// Full-bleed background for the login hero: background photo + dark
/// gradient tint + faded Baybayin glyph overlay.
class LoginHeroBackground extends StatelessWidget {
  const LoginHeroBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            color: KudlitColors.blue300,
            image: DecorationImage(
              image: AssetImage('assets/brand/bg.login.webp'),
              fit: BoxFit.cover,
            ),
          ),
          foregroundDecoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                Color(0x8C0E1425),
                Color(0xBF0E1425),
                Color(0xF20E1425),
              ],
              stops: <double>[0.0, 0.6, 1.0],
            ),
          ),
        ),
        const BaybayinBackdrop(),
      ],
    );
  }
}
