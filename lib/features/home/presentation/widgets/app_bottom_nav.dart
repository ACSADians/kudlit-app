import 'package:flutter/material.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavDef> _defs = <_NavDef>[
    _NavDef(Icons.home_outlined, Icons.home_rounded, 'Home'),
    _NavDef(Icons.document_scanner_outlined, Icons.document_scanner, 'Scan'),
    _NavDef(Icons.auto_stories_outlined, Icons.auto_stories, 'Learn'),
    _NavDef(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: KudlitColors.paper,
        border: Border(top: BorderSide(color: KudlitColors.grey400)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 58,
          child: Row(
            children: List<Widget>.generate(
              _defs.length,
              (int i) => _NavItem(
                def: _defs[i],
                active: currentIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavDef {
  const _NavDef(this.icon, this.activeIcon, this.label);

  final IconData icon;
  final IconData activeIcon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.def,
    required this.active,
    required this.onTap,
  });

  final _NavDef def;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = active ? KudlitColors.blue300 : KudlitColors.grey300;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 4),
            Icon(active ? def.activeIcon : def.icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              def.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: KudlitColors.blue300,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
