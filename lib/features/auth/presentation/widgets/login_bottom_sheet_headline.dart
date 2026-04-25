import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Headline and subhead shown at the top of the login bottom sheet.
class LoginBottomSheetHeadline extends StatelessWidget {
  const LoginBottomSheetHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: <Widget>[
        Text(
          'Welcome, ka-Baybayin!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: KudlitColors.blue300,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Sign in to save your progress and earn badges.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: KudlitColors.grey200,
            fontSize: 12,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
