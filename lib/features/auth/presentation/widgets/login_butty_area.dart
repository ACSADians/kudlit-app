import 'package:flutter/widgets.dart';

import 'butty_speech_bubble.dart';

/// Butty mascot with optional speech bubble, anchored to the bottom of the hero.
class LoginButtyArea extends StatelessWidget {
  const LoginButtyArea({
    required this.buttyAsset,
    required this.bubbleText,
    super.key,
  });

  final String buttyAsset;
  final String bubbleText;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        ButtySpeechBubble(text: bubbleText),
        const SizedBox(height: 2),
        Image.asset(buttyAsset, width: 130, height: 130, fit: BoxFit.contain),
      ],
    );
  }
}
