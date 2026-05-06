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
    final bool enabled = onTap != null && !isLoading;
    final BorderRadius radius = BorderRadius.circular(999);

    return Semantics(
      button: true,
      enabled: enabled,
      label: isLoading ? '$label, loading' : label,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: isLoading ? 0.75 : 1,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: isPrimary ? cs.primary : cs.surface,
                borderRadius: radius,
                border: Border.all(color: isPrimary ? cs.primary : cs.outline),
              ),
              child: InkWell(
                onTap: enabled ? onTap : null,
                borderRadius: radius,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Center(
                      widthFactor: 1,
                      child: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
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
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
