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
class AiModelsSection extends StatelessWidget {
  const AiModelsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SettingsSectionLabel(text: 'AI models'),
        SettingsCard(
          children: <Widget>[
            const LlmDownloadTile(),
            const SettingsDivider(),
            const VisionDownloadTile(),
          ],
        ),
      ],
    );
  }
}
