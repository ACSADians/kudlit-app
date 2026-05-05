import 'package:flutter/material.dart';

/// Full-width primary auth action button (e.g. "Continue with Phone Number").
class PrimaryAuthOptionButton extends StatelessWidget {
  const PrimaryAuthOptionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.imagePath,
    super.key,
  }) : assert(
         icon != null || imagePath != null,
         'Provide either icon or imagePath',
       );

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: cs.primary,
        borderRadius: BorderRadius.circular(12),
        elevation: 0,
        shadowColor: const Color(0x400E1425),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Color(0x400E1425),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (imagePath != null)
                  Image.asset(imagePath!, width: 18, height: 18)
                else
                  Icon(icon, color: cs.onPrimary, size: 18),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: cs.onPrimary,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
