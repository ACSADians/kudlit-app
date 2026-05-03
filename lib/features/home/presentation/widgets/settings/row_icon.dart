import 'package:flutter/material.dart';

class RowIcon extends StatelessWidget {
  const RowIcon({super.key, required this.icon, this.iconColor, this.bgColor});

  final IconData icon;
  final Color? iconColor;
  final Color? bgColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor ?? cs.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, size: 16, color: iconColor ?? cs.primary),
    );
  }
}
