import 'package:flutter/material.dart';

import 'glyph_item.dart';

class GlyphPreviewRow extends StatelessWidget {
  const GlyphPreviewRow({super.key, required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items
            .map(
              ((String, String) item) =>
                  GlyphItem(glyph: item.$1, label: item.$2),
            )
            .toList(),
      ),
    );
  }
}
