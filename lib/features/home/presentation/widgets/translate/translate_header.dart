import 'package:flutter/material.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      child: Text(
        '',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
