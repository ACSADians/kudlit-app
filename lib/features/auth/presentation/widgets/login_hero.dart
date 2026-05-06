import 'package:flutter/widgets.dart';

import 'login_hero_background.dart';
import 'login_hero_content.dart';

/// Hero panel shared by all auth screens.
/// Sized by its parent (a [Positioned] in [AuthScreenShell] or [LoginScreen]).
class LoginHero extends StatelessWidget {
  const LoginHero({
    this.buttyAsset = 'assets/brand/ButtyWave.webp',
    this.bubbleText = 'Kumusta! I\'m Butty. Let\'s learn Baybayin together!',
    this.showBackButton = false,
    this.showLanguageToggle = true,
    this.showButtyArea = true,
    super.key,
  });

  final String buttyAsset;
  final String bubbleText;
  final bool showBackButton;
  final bool showLanguageToggle;
  final bool showButtyArea;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const LoginHeroBackground(),
        SafeArea(
          bottom: false,
          child: LoginHeroContent(
            buttyAsset: buttyAsset,
            bubbleText: bubbleText,
            showBackButton: showBackButton,
            showLanguageToggle: showLanguageToggle,
            showButtyArea: showButtyArea,
          ),
        ),
      ],
    );
  }
}
