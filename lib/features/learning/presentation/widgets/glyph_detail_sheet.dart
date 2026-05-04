import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_entry.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/stroke_order_sheet.dart';

class GlyphDetailSheet extends StatelessWidget {
  const GlyphDetailSheet({super.key, required this.entry});

  final GlyphEntry entry;

  @override
  Widget build(BuildContext context) {
    final strokeOrder = entry.strokeOrder;
    if (strokeOrder != null && !strokeOrder.isEmpty) {
      return StrokeOrderSheet(
        glyph: entry.glyph,
        label: entry.label,
        data: strokeOrder,
      );
    }
    return _GlyphInfoSheet(entry: entry);
  }
}

class _GlyphInfoSheet extends StatelessWidget {
  const _GlyphInfoSheet({required this.entry});

  final GlyphEntry entry;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final TextTheme text = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.paddingOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            entry.glyph,
            style: TextStyle(
              fontFamily: 'Baybayin Simple TAWBID',
              fontSize: 96,
              height: 1,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            entry.label,
            style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            entry.group,
            style: text.labelMedium?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Stroke order not yet recorded.',
            style: text.bodySmall?.copyWith(
              color: cs.onSurface.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
