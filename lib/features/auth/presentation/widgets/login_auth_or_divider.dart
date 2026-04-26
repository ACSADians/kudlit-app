import 'package:flutter/material.dart';

/// Horizontal "or" divider between primary and secondary auth options.
class LoginAuthOrDivider extends StatelessWidget {
  const LoginAuthOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final Color dividerColor = Theme.of(context).colorScheme.outline;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: <Widget>[
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              'or',
              style: TextStyle(
                color: dividerColor,
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Expanded(child: Divider(color: dividerColor, thickness: 1)),
        ],
      ),
    );
  }
}
