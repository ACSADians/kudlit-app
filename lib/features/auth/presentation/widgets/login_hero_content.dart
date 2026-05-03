import 'package:flutter/material.dart';

import 'login_butty_area.dart';
import 'login_hero_wordmark.dart';
import 'login_language_toggle.dart';

/// Foreground content column inside the login hero.
class LoginHeroContent extends StatelessWidget {
  const LoginHeroContent({
    required this.buttyAsset,
    required this.bubbleText,
    this.showBackButton = false,
    this.showLanguageToggle = true,
    super.key,
  });

  final String buttyAsset;
  final String bubbleText;
  final bool showBackButton;
  final bool showLanguageToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (showBackButton)
                const _HeroBackButton()
              else
                const SizedBox(width: 36),
              if (showLanguageToggle)
                const LoginLanguageToggle()
              else
                const SizedBox(width: 36),
            ],
          ),
          const SizedBox(height: 6),
          const LoginHeroWordmark(),
          Expanded(
            child: LoginButtyArea(
              buttyAsset: buttyAsset,
              bubbleText: bubbleText,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroBackButton extends StatelessWidget {
  const _HeroBackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0x26FFFFFF),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(color: const Color(0x40FFFFFF)),
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
      ),
    );
  }
}
