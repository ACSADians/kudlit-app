import 'dart:ui';

import 'package:flutter/material.dart';

/// Vertical space (px) the floating nav occupies from the screen bottom,
/// excluding the device's safe-area inset.
const double kFloatingNavClearance = 56.0;

/// The three primary app tabs.
enum AppTab { scan, translate, learn }

/// Dark floating pill at the bottom-right corner.
/// Tapping it expands to reveal all three tabs; tapping again collapses.
/// While expanded, tapping any tab item selects it and collapses the nav.
class FloatingTabNav extends StatefulWidget {
  const FloatingTabNav({
    required this.activeTab,
    required this.onTabSelected,
    super.key,
  });

  final AppTab activeTab;
  final ValueChanged<AppTab> onTabSelected;

  @override
  State<FloatingTabNav> createState() => _FloatingTabNavState();
}

class _FloatingTabNavState extends State<FloatingTabNav> {
  bool _expanded = false;

  void _toggle() => setState(() => _expanded = !_expanded);

  void _select(AppTab tab) {
    widget.onTabSelected(tab);
    setState(() => _expanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final double pillWidth = MediaQuery.sizeOf(context).width * 0.42;
    const double collapsedSize = 54.0;

    return TapRegion(
      onTapOutside: (_) {
        if (_expanded) setState(() => _expanded = false);
      },
      child: GestureDetector(
        onTap: _expanded ? null : _toggle,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 36,
                spreadRadius: -4,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                width: _expanded ? pillWidth : collapsedSize,
                height: collapsedSize,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[Color(0xCC0E1730), Color(0xBB07091A)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Color(0x28FFFFFF), width: 1.0),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    IgnorePointer(
                      ignoring: _expanded,
                      child: AnimatedOpacity(
                        opacity: _expanded ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: _CollapsedPill(activeTab: widget.activeTab),
                      ),
                    ),
                    IgnorePointer(
                      ignoring: !_expanded,
                      child: AnimatedOpacity(
                        opacity: _expanded ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeOut,
                        child: _ExpandedItems(
                          activeTab: widget.activeTab,
                          onSelect: _select,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Collapsed state ───────────────────────────────────────────────────────────

class _CollapsedPill extends StatelessWidget {
  const _CollapsedPill({required this.activeTab});

  final AppTab activeTab;

  static const Map<AppTab, IconData> _icons = <AppTab, IconData>{
    AppTab.scan: Icons.qr_code_scanner,
    AppTab.translate: Icons.g_translate,
    AppTab.learn: Icons.auto_stories_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(_icons[activeTab]!, size: 22, color: Colors.white),
    );
  }
}

// ── Expanded state ────────────────────────────────────────────────────────────

class _ExpandedItems extends StatelessWidget {
  const _ExpandedItems({required this.activeTab, required this.onSelect});

  final AppTab activeTab;
  final ValueChanged<AppTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Expanded(
          child: _NavPill(
            icon: Icons.qr_code_scanner,
            label: 'Scan',
            active: activeTab == AppTab.scan,
            onTap: () => onSelect(AppTab.scan),
          ),
        ),
        Expanded(
          child: _NavPill(
            icon: Icons.g_translate,
            label: 'Translate',
            active: activeTab == AppTab.translate,
            onTap: () => onSelect(AppTab.translate),
          ),
        ),
        Expanded(
          child: _NavPill(
            icon: Icons.auto_stories_rounded,
            label: 'Learn',
            active: activeTab == AppTab.learn,
            onTap: () => onSelect(AppTab.learn),
          ),
        ),
      ],
    );
  }
}

class _NavPill extends StatelessWidget {
  const _NavPill({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33FFFFFF),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              icon,
              size: 17,
              color: active ? const Color(0xFF080C18) : const Color(0xBBFFFFFF),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? const Color(0xFF080C18)
                    : const Color(0xBBFFFFFF),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
