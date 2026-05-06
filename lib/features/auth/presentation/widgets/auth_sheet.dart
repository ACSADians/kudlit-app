import 'package:flutter/material.dart';

/// Scrollable container with the branded rounded-top decoration.
/// Wrap the column content of each auth sheet with this.
class AuthSheet extends StatelessWidget {
  const AuthSheet({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final Color surface = Theme.of(context).colorScheme.surface;
    final Size screenSize = MediaQuery.sizeOf(context);
    final bool landscape = screenSize.width > screenSize.height;
    final bool keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    final double keyboardClearance = keyboardVisible
        ? (landscape ? 260 : 40)
        : 0;

    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x260E1425),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 24 + keyboardClearance),
          child: child,
        ),
      ),
    );
  }
}
