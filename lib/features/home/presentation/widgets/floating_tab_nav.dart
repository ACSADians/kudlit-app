import 'dart:ui';

import 'package:flutter/material.dart';

/// Vertical space (px) reserved by scrollable screens so the floating nav does
/// not cover bottom content. Excludes the device's safe-area inset.
const double kFloatingNavClearance = 112.0;

/// The three primary app tabs.
enum AppTab { scan, translate, learn, butty }

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
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double pillWidth = (screenWidth * 0.88).clamp(280.0, 360.0);

    return TapRegion(
      onTapOutside: (_) {
        if (_expanded) setState(() => _expanded = false);
      },
      child: GestureDetector(
        onTap: _expanded ? null : _toggle,
        child: _NavPillSurface(
          expanded: _expanded,
          pillWidth: pillWidth,
          activeTab: widget.activeTab,
          onSelect: _select,
        ),
      ),
    );
  }
}

// ── Pill surface (blurred glass container with collapsed/expanded slots) ─────

class _NavPillSurface extends StatelessWidget {
  const _NavPillSurface({
    required this.expanded,
    required this.pillWidth,
    required this.activeTab,
    required this.onSelect,
  });

  final bool expanded;
  final double pillWidth;
  final AppTab activeTab;
  final ValueChanged<AppTab> onSelect;

  static const double _collapsedSize = 64.0;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return DecoratedBox(
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
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            width: expanded ? pillWidth : _collapsedSize,
            height: _collapsedSize,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: cs.outline, width: 1.0),
            ),
            child: _NavPillContents(
              expanded: expanded,
              activeTab: activeTab,
              onSelect: onSelect,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Stacked collapsed/expanded contents with crossfade ──────────────────────

class _NavPillContents extends StatelessWidget {
  const _NavPillContents({
    required this.expanded,
    required this.activeTab,
    required this.onSelect,
  });

  final bool expanded;
  final AppTab activeTab;
  final ValueChanged<AppTab> onSelect;

  static const Duration _fade = Duration(milliseconds: 180);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        IgnorePointer(
          ignoring: expanded,
          child: AnimatedOpacity(
            opacity: expanded ? 0.0 : 1.0,
            duration: _fade,
            curve: Curves.easeOut,
            child: _CollapsedPill(activeTab: activeTab),
          ),
        ),
        IgnorePointer(
          ignoring: !expanded,
          child: AnimatedOpacity(
            opacity: expanded ? 1.0 : 0.0,
            duration: _fade,
            curve: Curves.easeOut,
            child: _ExpandedItems(activeTab: activeTab, onSelect: onSelect),
          ),
        ),
      ],
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
    AppTab.butty: Icons.chat_bubble_outline_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        _icons[activeTab]!,
        size: 22,
        color: Theme.of(context).colorScheme.onSurface,
      ),
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
        Expanded(
          child: _NavPill(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Butty',
            active: activeTab == AppTab.butty,
            onTap: () => onSelect(AppTab.butty),
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color activeFg = cs.onPrimary;
    final Color inactiveFg = cs.onSurface.withAlpha(180);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 17, color: active ? activeFg : inactiveFg),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? activeFg : inactiveFg,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
