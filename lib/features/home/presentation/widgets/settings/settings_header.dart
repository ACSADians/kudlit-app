import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kudlit_ph/app/constants.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color headerBg =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    final Color fgColor =
        theme.appBarTheme.foregroundColor ?? theme.colorScheme.onSurface;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: headerBg,
        border: Border(bottom: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 4, 16, 4),
        child: Row(
          children: <Widget>[
            IconButton(
              onPressed: () => _handleBack(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: fgColor.withAlpha(170),
              ),
            ),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: fgColor,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    context.go(AppConstants.routeHome);
  }
}
