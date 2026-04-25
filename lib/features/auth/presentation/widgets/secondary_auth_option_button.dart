import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Outline secondary auth option button (e.g. "Email", "Google").
class SecondaryAuthOptionButton extends StatelessWidget {
  const SecondaryAuthOptionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.imagePath,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: KudlitColors.grey400, width: 1.25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (imagePath != null)
              Image.asset(imagePath!, width: 16, height: 16)
            else if (icon != null)
              Icon(icon, color: KudlitColors.blue300, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: KudlitColors.blue300,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
