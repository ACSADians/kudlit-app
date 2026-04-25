import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Full-width lesson card for the Learn tab — image strip + content row.
class LessonDetailCard extends StatelessWidget {
  const LessonDetailCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.glyph,
    this.tag,
    this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String glyph;
  final String? tag;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KudlitColors.grey400, width: 1.25),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x140E1425),
              blurRadius: 8,
              offset: Offset(0, 2),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            _DetailImageStrip(
              imageAsset: imageAsset,
              glyph: glyph,
              tag: tag,
              title: title,
              subtitle: subtitle,
            ),
            _DetailBody(description: description),
          ],
        ),
      ),
    );
  }
}

class _DetailImageStrip extends StatelessWidget {
  const _DetailImageStrip({
    required this.imageAsset,
    required this.glyph,
    required this.title,
    required this.subtitle,
    this.tag,
  });

  final String imageAsset;
  final String glyph;
  final String title;
  final String subtitle;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
      child: Container(
        height: 110,
        color: KudlitColors.blue900,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Positioned(
              right: -4,
              bottom: -18,
              child: Text(
                glyph,
                style: const TextStyle(
                  fontFamily: 'Baybayin Simple TAWBID',
                  fontSize: 90,
                  color: Color(0x0FFFFFFF),
                  height: 1,
                ),
              ),
            ),
            _StripContent(tag: tag, title: title, subtitle: subtitle),
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Image.asset(imageAsset, height: 80, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripContent extends StatelessWidget {
  const _StripContent({required this.title, required this.subtitle, this.tag});

  final String title;
  final String subtitle;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (tag != null) ...<Widget>[
            _StripTag(tag: tag!),
            const SizedBox(height: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.2,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11.5, color: Color(0x8CFFFFFF)),
          ),
        ],
      ),
    );
  }
}

class _StripTag extends StatelessWidget {
  const _StripTag({required this.tag});

  final String tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: KudlitColors.blue500,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12.5,
                color: KudlitColors.grey200,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: KudlitColors.blue300,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: KudlitColors.blue900,
            ),
          ),
        ],
      ),
    );
  }
}
