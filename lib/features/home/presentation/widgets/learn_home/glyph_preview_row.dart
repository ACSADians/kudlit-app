import 'package:flutter/material.dart';

import 'glyph_item.dart';

class GlyphPreviewRow extends StatelessWidget {
  const GlyphPreviewRow({super.key});

  static const List<(String, String)> _items = <(String, String)>[
    ('a', 'A'),
    ('e', 'E / I'),
    ('o', 'O / U'),
    ('b', 'BA'),
    ('k', 'KA'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items
            .map(
              ((String, String) item) =>
                  GlyphItem(glyph: item.$1, label: item.$2),
            )
            .toList(),
      ),
    );
  }
}
