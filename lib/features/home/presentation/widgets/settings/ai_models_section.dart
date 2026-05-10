import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'llm_download_tile.dart';
import 'settings_card.dart';
import 'settings_divider.dart';
import 'settings_section_label.dart';
import 'vision_download_tile.dart';

/// Settings section that shows download status and controls for both
/// on-device AI models:
///
/// - **Gemma 4 E2B** — LLM used by Butty (offline chat / feedback).
/// - **KudVis-1-Turbo** — YOLO TFLite used by the OCR / camera scanner.
///
/// Hidden on web (both models are irrelevant; cloud AI is always used).
class AiModelsSection extends StatelessWidget {
  const AiModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'AI models'),
        SettingsCard(
          children: <Widget>[
            const _AiModelsIntro(),
            const SettingsDivider(),
            const LlmDownloadTile(),
            const SettingsDivider(),
            const VisionDownloadTile(),
          ],
        ),
      ],
    );
  }
}

class _AiModelsIntro extends StatelessWidget {
  const _AiModelsIntro();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.offline_bolt_rounded,
              size: 18,
              color: cs.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Local AI setup',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Install models once, then use Butty and Scanner on this device.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    color: cs.onSurface.withAlpha(160),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
