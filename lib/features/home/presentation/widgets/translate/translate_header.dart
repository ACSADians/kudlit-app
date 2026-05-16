import 'package:flutter/material.dart';

import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.workspaceMode,
    required this.onWorkspaceModeChanged,
  });

  final TranslateWorkspaceMode workspaceMode;
  final ValueChanged<TranslateWorkspaceMode> onWorkspaceModeChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool narrow = constraints.maxWidth < 420;
        final bool tabletDensity = constraints.maxWidth >= 768;
        final bool desktopDensity = constraints.maxWidth >= 1200;
        final double topPadding = desktopDensity
            ? 18
            : tabletDensity
            ? 16
            : (narrow ? 10 : 12);
        final double horizontalPadding = desktopDensity
            ? 32
            : tabletDensity
            ? 24
            : 16;
        final double bottomPadding = tabletDensity ? 14 : (narrow ? 8 : 12);
        final double spacing = desktopDensity
            ? 16
            : tabletDensity
            ? 12
            : 8;
        final double runSpacing = tabletDensity ? 10 : 8;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding - (tabletDensity ? 3 : 0),
            topPadding - (tabletDensity ? 1 : 0),
            horizontalPadding - (tabletDensity ? 3 : 0),
            bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: tabletDensity ? spacing - 2 : spacing,
                runSpacing: tabletDensity ? runSpacing - 2 : runSpacing,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  TranslateModeSwitch(
                    mode: workspaceMode,
                    onChanged: onWorkspaceModeChanged,
                    compact: narrow,
                    tabletDensity: tabletDensity,
                    desktopDensity: desktopDensity,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
