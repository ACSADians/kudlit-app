import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Horizontal "or" divider between primary and secondary auth options.
class LoginAuthOrDivider extends StatelessWidget {
  const LoginAuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Divider(color: KudlitColors.grey400, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'or',
              style: TextStyle(
                color: KudlitColors.grey300.withValues(alpha: 0.9),
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const Expanded(
            child: Divider(color: KudlitColors.grey400, thickness: 1),
          ),
        ],
      ),
    );
  }
}
