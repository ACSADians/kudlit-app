import 'package:flutter/material.dart';

/// App icon badge, "Kudlit" wordmark, and tagline shown at the centre
/// of the login hero section.
class LoginHeroWordmark extends StatelessWidget {
  const LoginHeroWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x400E1425),
                blurRadius: 4,
                offset: Offset(0, 4),
              ),
            ],
            image: const DecorationImage(
              image: AssetImage('assets/brand/BaybayInscribe-AppIcon.webp'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Kudlit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'Baybayin, made simple.',
          style: TextStyle(
            color: Color(0xD1FFFFFF),
            fontSize: 12,
            letterSpacing: 0.25,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
