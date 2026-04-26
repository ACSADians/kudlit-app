import 'package:flutter/material.dart';

/// Compact lesson card for the 2-column grid on the Home tab.
class LessonPreviewCard extends StatelessWidget {
  const LessonPreviewCard({
    required this.title,
    required this.description,
    required this.imageAsset,
    this.tag,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final String imageAsset;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outline),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0F0E1425),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _PreviewImageStrip(imageAsset: imageAsset, tag: tag),
            _PreviewText(title: title, description: description),
          ],
        ),
      ),
    );
  }
}

class _PreviewImageStrip extends StatelessWidget {
  const _PreviewImageStrip({required this.imageAsset, this.tag});

  final String imageAsset;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 88,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
            child: Container(
              color: cs.surfaceContainerLow,
              padding: const EdgeInsets.all(8),
              child: Image.asset(imageAsset, fit: BoxFit.contain),
            ),
          ),
          if (tag != null)
            Positioned(top: 6, left: 6, child: _LessonTag(tag: tag!)),
        ],
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            description,
            style: TextStyle(
              fontSize: 11,
              color: cs.onSurface.withAlpha(170),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTag extends StatelessWidget {
  const _LessonTag({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        tag,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: cs.onPrimary,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
