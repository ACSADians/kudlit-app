import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_sketchpad_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/floating_tab_nav.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_gemma_status_banner.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_mode_switch.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_sketchpad_mode_panel.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_text_mode_panel.dart';

class TranslateScreen extends ConsumerWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TranslatePageState pageState = ref.watch(
      translatePageControllerProvider,
    );
    final TranslateTextState textState = ref.watch(
      translateTextControllerProvider,
    );
    final TranslateSketchpadState sketchState = ref.watch(
      translateSketchpadControllerProvider,
    );
    final AsyncValue<AppPreferences> prefsAsync = ref.watch(
      appPreferencesNotifierProvider,
    );
    final AsyncValue<TranslateOfflineStatus> offlineStatus = ref.watch(
      translateOfflineStatusProvider,
    );

    final AiPreference mode =
        prefsAsync.value?.aiPreference ?? AiPreference.cloud;
    final bool offlinePending =
        mode == AiPreference.local && offlineStatus.isLoading;
    final bool offlineUnavailable =
        mode == AiPreference.local &&
        !offlineStatus.isLoading &&
        !(offlineStatus.value?.usable ?? false);
    final bool aiActionsEnabled = !offlinePending && !offlineUnavailable;
    final String? disabledReason = switch (mode) {
      AiPreference.local when offlinePending => 'Preparing offline Gemma...',
      AiPreference.local when offlineUnavailable =>
        offlineStatus.value?.detail ??
            'Offline model is unavailable for this action.',
      _ => null,
    };

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Translate',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Switch between text transliteration and sketchpad feedback.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withAlpha(170),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TranslateGemmaStatusBanner(
                    mode: mode,
                    offlineStatus: offlineStatus,
                    onModeChanged: (AiPreference nextMode) {
                      unawaited(
                        ref
                            .read(appPreferencesNotifierProvider.notifier)
                            .setAiPreference(nextMode),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TranslateModeSwitch(
                      mode: pageState.mode,
                      onChanged: ref
                          .read(translatePageControllerProvider.notifier)
                          .setMode,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: switch (pageState.mode) {
                TranslateWorkspaceMode.text => TranslateTextModePanel(
                  state: textState,
                  inputEnabled: aiActionsEnabled,
                  disabledReason: disabledReason,
                  onDirectionChanged: ref
                      .read(translateTextControllerProvider.notifier)
                      .setDirection,
                  onInputChanged: ref
                      .read(translateTextControllerProvider.notifier)
                      .setInput,
                  onClear: ref
                      .read(translateTextControllerProvider.notifier)
                      .clearInput,
                  onExplain: () => unawaited(
                    ref
                        .read(translateTextControllerProvider.notifier)
                        .explain(),
                  ),
                  onCheckInput: () => unawaited(
                    ref
                        .read(translateTextControllerProvider.notifier)
                        .checkInput(),
                  ),
                  onCopy: () => _copyOutput(context, textState),
                  onShare: () => _shareOutput(context, textState),
                ),
                TranslateWorkspaceMode.sketchpad => TranslateSketchpadModePanel(
                  state: sketchState,
                  aiActionsEnabled: aiActionsEnabled,
                  disabledReason: disabledReason,
                  onTargetChanged: ref
                      .read(translateSketchpadControllerProvider.notifier)
                      .setTarget,
                  onGetFeedback: ref
                      .read(translateSketchpadControllerProvider.notifier)
                      .requestFeedback,
                ),
              },
            ),
            SizedBox(
              height:
                  MediaQuery.paddingOf(context).bottom +
                  kFloatingNavClearance +
                  8,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyOutput(
    BuildContext context,
    TranslateTextState state,
  ) async {
    final String output = state.latinToBaybayin
        ? state.baybayinText
        : state.latinText;
    if (output.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nothing to copy yet.')));
      }
      return;
    }
    await Clipboard.setData(ClipboardData(text: output));
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied output.')));
    }
  }

  Future<void> _shareOutput(
    BuildContext context,
    TranslateTextState state,
  ) async {
    final String output = state.latinToBaybayin
        ? state.baybayinText
        : state.latinText;
    if (output.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Generate output first.')));
      }
      return;
    }
    await Clipboard.setData(ClipboardData(text: output));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Output copied. Share it from any app.')),
      );
    }
  }
}
