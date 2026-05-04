import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_gemma_status_banner.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';

class TranslateHeader extends StatelessWidget {
  const TranslateHeader({
    super.key,
    required this.aiMode,
    required this.workspaceMode,
    required this.offlineStatus,
    required this.onAiModeChanged,
    required this.onWorkspaceModeChanged,
  });

  final AiPreference aiMode;
  final TranslateWorkspaceMode workspaceMode;
  final AsyncValue<TranslateOfflineStatus> offlineStatus;
  final ValueChanged<AiPreference> onAiModeChanged;
  final ValueChanged<TranslateWorkspaceMode> onWorkspaceModeChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Translate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ),
              TranslateModeSwitch(
                mode: workspaceMode,
                onChanged: onWorkspaceModeChanged,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Switch between text transliteration and sketchpad feedback.',
            style: TextStyle(
              fontSize: 12.5,
              color: cs.onSurface.withAlpha(170),
            ),
          ),
          const SizedBox(height: 10),
          TranslateGemmaStatusBanner(
            mode: aiMode,
            offlineStatus: offlineStatus,
            onModeChanged: onAiModeChanged,
          ),
        ],
      ),
    );
  }
}
