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
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Baybayin tutor',
          style: TextStyle(fontSize: 11.5, color: Colors.white.withAlpha(180)),
        ),
      ],
    );
  }
}
