import 'package:flutter/material.dart';

class ProfileManagementActionButton extends StatelessWidget {
  const ProfileManagementActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isPrimary;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Opacity(
        opacity: isLoading ? 0.75 : 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isPrimary ? cs.primary : cs.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: isPrimary ? cs.primary : cs.outline),
          ),
          child: isLoading
              ? SizedBox(
                  width: 13,
                  height: 13,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isPrimary ? cs.onPrimary : cs.primary,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: isPrimary ? cs.onPrimary : cs.onSurface,
                  ),
                ),
        ),
      ),
    );
  }
}
