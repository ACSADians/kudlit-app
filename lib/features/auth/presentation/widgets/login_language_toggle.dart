import 'package:flutter/material.dart';

/// Language selector pill displayed in the top-right corner of the login hero.
class LoginLanguageToggle extends StatelessWidget {
  const LoginLanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(7, 4, 9, 4),
      decoration: BoxDecoration(
        color: const Color(0x26FFFFFF),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color(0x40FFFFFF), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipOval(
            child: Image.asset(
              'assets/brand/flag-ph.webp',
              width: 16,
              height: 16,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'EN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 13),
        ],
      ),
    );
  }
}
