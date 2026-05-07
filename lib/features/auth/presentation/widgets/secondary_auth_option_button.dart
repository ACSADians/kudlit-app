import 'package:flutter/material.dart';

/// Outline secondary auth option button (e.g. "Email", "Google").
class SecondaryAuthOptionButton extends StatelessWidget {
  const SecondaryAuthOptionButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.imagePath,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final String? imagePath;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool enabled = onTap != null && !isLoading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Material(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool compact = constraints.maxWidth < 120;
            final double horizontalPadding = compact ? 8 : 14;
            final double gap = compact ? 5 : 8;

            return InkWell(
              onTap: enabled ? onTap : null,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: enabled ? cs.outline : cs.outlineVariant,
                    width: 1.25,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (isLoading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    else if (imagePath != null)
                      Image.asset(
                        imagePath!,
                        width: 16,
                        height: 16,
                        color: enabled
                            ? cs.primary
                            : cs.onSurface.withAlpha(120),
                        colorBlendMode: BlendMode.srcIn,
                      )
                    else if (icon != null)
                      Icon(icon, color: cs.primary, size: 16),
                    SizedBox(width: gap),
                    Flexible(
                      child: Text(
                        isLoading ? 'Opening...' : label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: enabled
                              ? cs.primary
                              : cs.onSurface.withAlpha(120),
                          fontSize: compact ? 12.5 : 13.5,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
