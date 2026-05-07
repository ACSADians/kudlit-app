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
        final bool wide = constraints.maxWidth >= 900;
        final double topPadding = wide ? 16 : (narrow ? 10 : 12);
        final double horizontalPadding = wide ? 24 : 16;
        final double bottomPadding = narrow ? 8 : 12;
        final double spacing = wide ? 12 : 8;
        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Wrap(
                spacing: spacing,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  TranslateModeSwitch(
                    mode: workspaceMode,
                    onChanged: onWorkspaceModeChanged,
                    compact: narrow,
                    tabletDensity: wide,
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
