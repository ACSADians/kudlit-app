import 'package:flutter/material.dart';

class ButtyHeaderText extends StatelessWidget {
  const ButtyHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Butty',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Ask me anything about Baybayin',
          style: TextStyle(fontSize: 11.5, color: Colors.white.withAlpha(180)),
        ),
      ],
    );
  }
}
