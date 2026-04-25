import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

/// Large tool card used in the Home tab for Scanner and Transliterator.
class HomeToolCard extends StatelessWidget {
  const HomeToolCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.accentColor,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KudlitColors.paper,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: KudlitColors.grey400, width: 1.25),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x1A0E1425),
              blurRadius: 8,
              offset: Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ToolIcon(icon: icon, accentColor: accentColor),
            const SizedBox(height: 10),
            _ToolText(title: title, description: description),
            const SizedBox(height: 10),
            const _OpenLabel(),
          ],
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.icon, required this.accentColor});

  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: accentColor,
        borderRadius: BorderRadius.circular(13),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x150E1425),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, size: 24, color: KudlitColors.blue900),
    );
  }
}

class _ToolText extends StatelessWidget {
  const _ToolText({required this.title, required this.description});

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KudlitColors.blue300,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          description,
          style: const TextStyle(
            fontSize: 11.5,
            color: KudlitColors.grey300,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _OpenLabel extends StatelessWidget {
  const _OpenLabel();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'Open ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: KudlitColors.blue400,
          ),
        ),
        Icon(
          Icons.arrow_forward_rounded,
          size: 13,
          color: KudlitColors.blue400,
        ),
      ],
    );
  }
}
