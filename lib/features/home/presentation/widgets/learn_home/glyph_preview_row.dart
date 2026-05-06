import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'glyph_item.dart';

class GlyphPreviewRow extends StatelessWidget {
  const GlyphPreviewRow({super.key, required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final Color shimmerColor =
        Theme.of(context).colorScheme.primary.withAlpha(50);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items.indexed
            .map(
              ((int, (String, String)) entry) => GlyphItem(
                glyph: entry.$2.$1,
                label: entry.$2.$2,
              )
                  .animate(delay: (entry.$1 * 70).ms)
                  .shimmer(
                    duration: 1000.ms,
                    color: shimmerColor,
                    delay: 80.ms,
                  )
                  .fadeIn(duration: 280.ms)
                  .scaleXY(
                    begin: 0.85,
                    end: 1.0,
                    duration: 320.ms,
                    curve: Curves.easeOutBack,
                  ),
            )
            .toList(),
      ),
    );
  }
}
