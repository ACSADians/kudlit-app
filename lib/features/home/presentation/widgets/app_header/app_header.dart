import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';
import 'package:kudlit_ph/features/auth/domain/entities/auth_user.dart';
import 'package:kudlit_ph/features/auth/presentation/providers/auth_notifier.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';

import 'login_button.dart';
import 'profile_button.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key, this.showTranslateControls = false});

  final bool showTranslateControls;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final ThemeData theme = Theme.of(context);
    final double textScale = MediaQuery.textScalerOf(context).scale(1.0);
    final AuthUser? user = ref.watch(authNotifierProvider).value;
    final AiPreference aiMode =
        ref.watch(appPreferencesNotifierProvider).value?.aiPreference ??
        AiPreference.cloud;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.appBarTheme.backgroundColor ?? cs.surfaceContainerHigh,
        border: Border(bottom: BorderSide(color: cs.outline)),
      ),
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool keyboardOpen =
                MediaQuery.viewInsetsOf(context).bottom > 0;
            final bool compact = constraints.maxWidth < 640;
            final bool isTablet = constraints.maxWidth >= 768;
            final bool isDesktop = constraints.maxWidth >= 1200;
            final bool ultraCompact =
                constraints.maxWidth < 290 || (textScale > 1.35 && compact);
            final bool denseMode = compact || keyboardOpen;
            final double? fixedHeaderHeight = keyboardOpen ? 56.0 : null;
            final double titleFontSize = keyboardOpen
                ? (ultraCompact ? 14 : 15)
                : denseMode
                ? (ultraCompact ? 14 : 16)
                : isDesktop
                ? 20
                : isTablet
                ? 19
                : 17;
            final double iconSize = keyboardOpen
                ? (denseMode ? 22 : 24)
                : denseMode
                ? (ultraCompact ? 22 : 24)
                : isDesktop
                ? 32
                : isTablet
                ? 30
                : 28;
            final double gap = denseMode
                ? (ultraCompact ? 4 : 7)
                : isTablet
                ? 12
                : 10;
            final EdgeInsets padding = EdgeInsets.fromLTRB(
              denseMode
                  ? (ultraCompact ? 10 : 14)
                  : isDesktop
                  ? 28
                  : isTablet
                  ? 24
                  : 20,
              keyboardOpen
                  ? 4
                  : denseMode
                  ? (ultraCompact ? 8 : 10)
                  : isDesktop
                  ? 16
                  : isTablet
                  ? 14
                  : 12,
              denseMode
                  ? (ultraCompact ? 8 : 12)
                  : isDesktop
                  ? 20
                  : isTablet
                  ? 18
                  : 18,
              keyboardOpen
                  ? 4
                  : denseMode
                  ? (ultraCompact ? 8 : 10)
                  : isDesktop
                  ? 18
                  : isTablet
                  ? 16
                  : 12,
            );
            return SizedBox(
              height: fixedHeaderHeight,
              child: Padding(
                padding: padding,
                child: Row(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/brand/BaybayInscribe-AppIcon.webp',
                        width: iconSize,
                        height: iconSize,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: gap),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          showTranslateControls ? 'Translate' : 'Kudlit',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    ),
                    if (showTranslateControls) ...<Widget>[
                      SizedBox(width: isTablet ? 12 : 8),
                      _AiSourceSwitch(
                        mode: aiMode,
                        compact: denseMode,
                        ultraCompact: ultraCompact,
                        tabletDensity: isTablet,
                        onChanged: (AiPreference nextMode) {
                          ref
                              .read(appPreferencesNotifierProvider.notifier)
                              .setAiPreference(nextMode);
                        },
                      ),
                    ],
                    const SizedBox(width: 8),
                    if (user == null)
                      LoginButton(
                        compact: denseMode,
                        onTap: () => context.go(AppConstants.routeLogin),
                      )
                    else
                      const ProfileButton(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AiSourceSwitch extends StatelessWidget {
  const _AiSourceSwitch({
    required this.mode,
    required this.compact,
    required this.ultraCompact,
    this.tabletDensity = false,
    required this.onChanged,
  });

  final AiPreference mode;
  final bool compact;
  final bool ultraCompact;
  final bool tabletDensity;
  final ValueChanged<AiPreference> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Container(
      padding: tabletDensity
          ? const EdgeInsets.all(4)
          : const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _AiSourcePill(
            label: ultraCompact ? 'On' : 'Online',
            active: mode == AiPreference.cloud,
            compact: compact,
            ultraCompact: ultraCompact,
            tabletDensity: tabletDensity,
            onTap: () => onChanged(AiPreference.cloud),
          ),
          _AiSourcePill(
            label: ultraCompact ? 'Off' : 'Offline',
            active: mode == AiPreference.local,
            compact: compact,
            ultraCompact: ultraCompact,
            tabletDensity: tabletDensity,
            onTap: () => onChanged(AiPreference.local),
          ),
        ],
      ),
    );
  }
}

class _AiSourcePill extends StatelessWidget {
  const _AiSourcePill({
    required this.label,
    required this.active,
    required this.compact,
    required this.ultraCompact,
    required this.tabletDensity,
    required this.onTap,
  });

  final String label;
  final bool active;
  final bool compact;
  final bool ultraCompact;
  final bool tabletDensity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          constraints: BoxConstraints(
            minHeight: compact
                ? 30
                : tabletDensity
                ? 36
                : 34,
            minWidth: compact
                ? (ultraCompact ? 36 : 46)
                : tabletDensity
                ? 64
                : 54,
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            horizontal: compact
                ? (ultraCompact ? 3 : 5)
                : tabletDensity
                ? 11
                : 10,
            vertical: compact ? 5 : (tabletDensity ? 7 : 6),
          ),
          decoration: BoxDecoration(
            color: active ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: compact
                    ? (ultraCompact ? 8 : 9)
                    : (tabletDensity ? 11 : 10.5),
                fontWeight: FontWeight.w700,
                color: active ? cs.onPrimary : cs.onSurface.withAlpha(170),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
