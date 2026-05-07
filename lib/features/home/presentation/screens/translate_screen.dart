import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_page_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_sketchpad_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/export_sheet.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/translate/translate_header.dart';
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
    final Size screenSize = MediaQuery.sizeOf(context);
    final view = View.of(context);
    final double rawKeyboardInset =
        view.viewInsets.bottom / view.devicePixelRatio;
    final bool keyboardOpen =
        MediaQuery.viewInsetsOf(context).bottom > 0 || rawKeyboardInset > 0;
    final bool compactLandscape =
        screenSize.height < 500 && screenSize.width > screenSize.height;
    final double navClearance = keyboardOpen
        ? 0
        : compactLandscape
        ? 10
        : kFloatingNavClearance - 32;
    Widget textModePanel({required bool compactLayout}) {
      return TranslateTextModePanel(
        state: textState,
        inputEnabled: aiActionsEnabled,
        disabledReason: disabledReason,
        compactLayout: compactLayout,
        onDirectionChanged: ref
            .read(translateTextControllerProvider.notifier)
            .setDirection,
        onInputChanged: ref
            .read(translateTextControllerProvider.notifier)
            .setInput,
        onClear: ref.read(translateTextControllerProvider.notifier).clearInput,
        onExplain: () => unawaited(
          ref.read(translateTextControllerProvider.notifier).explain(),
        ),
        onCheckInput: () => unawaited(
          ref.read(translateTextControllerProvider.notifier).checkInput(),
        ),
        onCopy: () => _copyOutput(context, textState),
        onShare: () => _shareOutput(context, textState),
      );
    }

    Widget sketchpadPanel() {
      return TranslateSketchpadModePanel(
        state: sketchState,
        aiActionsEnabled: aiActionsEnabled,
        disabledReason: disabledReason,
        onTargetChanged: ref
            .read(translateSketchpadControllerProvider.notifier)
            .setTarget,
        onGetFeedback: ref
            .read(translateSketchpadControllerProvider.notifier)
            .requestFeedback,
      );
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool constrainedKeyboardLayout =
                keyboardOpen ||
                constraints.maxHeight < 560 ||
                (constraints.maxWidth > constraints.maxHeight &&
                    constraints.maxHeight < 500);
            if (constrainedKeyboardLayout) {
              return switch (pageState.mode) {
                TranslateWorkspaceMode.text => textModePanel(
                  compactLayout: true,
                ),
                TranslateWorkspaceMode.sketchpad => sketchpadPanel(),
              };
            }

            return Column(
              children: <Widget>[
                TranslateHeader(
                  workspaceMode: pageState.mode,
                  onWorkspaceModeChanged: ref
                      .read(translatePageControllerProvider.notifier)
                      .setMode,
                ),
                Expanded(
                  child: switch (pageState.mode) {
                    TranslateWorkspaceMode.text => textModePanel(
                      compactLayout: false,
                    ),
                    TranslateWorkspaceMode.sketchpad => sketchpadPanel(),
                  },
                ),
                SizedBox(
                  height: MediaQuery.paddingOf(context).bottom + navClearance,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _copyOutput(
    BuildContext context,
    TranslateTextState state,
  ) async {
    final String output = _textOutput(state);
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
    if (!state.hasInput) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Nothing to share yet.')));
      }
      return;
    }
    if (context.mounted) {
      await BaybayinExportSheet.show(
        context,
        baybayin: state.baybayinText,
        latin: state.latinText,
      );
    }
  }

  String _textOutput(TranslateTextState state) {
    return state.latinToBaybayin ? state.baybayinText : state.latinText;
  }
}
