import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/baybayin_backdrop.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/model_setup_model_card.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

/// Shown once on first launch (mobile only).
///
/// Transparently explains that Kudlit uses AI models for on-device
/// Baybayin recognition and translation, and asks whether the user
/// wants to download the model now or skip to cloud mode.
class ModelSetupScreen extends ConsumerStatefulWidget {
  const ModelSetupScreen({super.key});

  @override
  ConsumerState<ModelSetupScreen> createState() => _ModelSetupScreenState();
}

class _ModelSetupScreenState extends ConsumerState<ModelSetupScreen> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final AiInferenceState? inferenceState = ref
        .watch(aiInferenceNotifierProvider)
        .value;
    final AiModelInfo? model = _resolveModel(inferenceState);

    return Scaffold(
      backgroundColor: KudlitColors.neutralBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SetupBackground(),
          _ModelSetupBody(
            model: model,
            busy: _busy,
            onDownload: model != null ? () => _onDownload(model) : null,
            onSkip: _onSkip,
          ),
        ],
      ),
    );
  }

  AiModelInfo? _resolveModel(AiInferenceState? s) => switch (s) {
    AiReady(:final AiModelInfo activeModel) => activeModel,
    AiLocalModelMissing(:final AiModelInfo model) => model,
    AiDownloading(:final AiModelInfo model) => model,
    _ => null,
  };

  Future<void> _onDownload(AiModelInfo llmModel) async {
    if (_busy) return;
    setState(() => _busy = true);

    // 1. Gemma LLM (offline chatbot / Butty) — flutter_gemma / MediaPipe.
    //    Fires in the background; AiInferenceNotifier tracks progress.
    ref
        .read(aiInferenceNotifierProvider.notifier)
        .triggerLocalDownload(llmModel);

    // 2. KudVis vision model (OCR / camera detection) — YoloModelCache.
    //    Uses a separate vision-typed row from the catalog, never the LLM model.
    if (!kIsWeb) {
      try {
        final List<AiModelInfo> visionModels =
            await ref.read(availableYoloModelsProvider.future);
        final AiModelInfo? visionModel =
            visionModels.isNotEmpty ? visionModels.first : null;
        if (visionModel != null) {
          final String yoloUrl = Platform.isIOS
              ? (visionModel.iosModelLink ?? visionModel.modelLink)
              : (visionModel.androidModelLink ?? visionModel.modelLink);
          if (yoloUrl.isNotEmpty) {
            await YoloModelCache.instance.download(
              visionModel.id,
              yoloUrl,
              version: visionModel.version,
            );
            ref.invalidate(yoloModelPathProvider);
          }
        }
      } catch (e) {
        debugPrint('[ModelSetup] YOLO download failed: $e');
        // Non-fatal — camera pipeline retries on next use.
      }
    }

    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .setAiPreference(AiPreference.local);
    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .markModelsDownloaded();
    // Router redirects automatically when hasDownloadedModels becomes true.
  }

  Future<void> _onSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
    // Set a session-only flag — no persistence.
    // The router will navigate away this session, but on the next cold
    // launch the setup screen shows again until models are downloaded.
    ref.read(modelSetupSkippedProvider.notifier).state = true;
  }
}

class _SetupBackground extends StatelessWidget {
  const _SetupBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        // Deep blue-to-black gradient
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[KudlitColors.blue200, KudlitColors.neutralBlack],
              stops: <double>[0.0, 0.75],
            ),
          ),
        ),
        // Faded Baybayin glyphs
        const BaybayinBackdrop(),
        // Soft radial aura concentrated in the upper third (behind Butty)
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    KudlitColors.blue400.withAlpha(90),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ModelSetupBody extends StatelessWidget {
  const _ModelSetupBody({
    required this.model,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final AiModelInfo? model;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Spacer(flex: 2),
            const _SetupHero(),
            const SizedBox(height: 20),
            const _SetupHeadline(),
            const SizedBox(height: 18),
            ModelSetupModelCard(model: model),
            const SizedBox(height: 10),
            const _DownloadNotice(),
            const Spacer(flex: 3),
            _SetupActions(busy: busy, onDownload: onDownload, onSkip: onSkip),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SetupHero extends StatelessWidget {
  const _SetupHero();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/brand/ButtyRead.webp',
          height: 110,
          errorBuilder: (context, error, stackTrace) =>
              const SizedBox(height: 110),
        ),
      ),
    );
  }
}

class _SetupHeadline extends StatelessWidget {
  const _SetupHeadline();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Power up Kudlit',
          style: TextStyle(
            color: KudlitColors.blue900,
            fontSize: 28,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Kudlit uses on-device AI models for Baybayin recognition '
          'and translation — no internet needed once downloaded.',
          style: TextStyle(
            color: KudlitColors.grey300,
            fontSize: 15,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class _DownloadNotice extends StatelessWidget {
  const _DownloadNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: KudlitColors.blue100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KudlitColors.blue300.withAlpha(60)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(Icons.info_outline, size: 13, color: KudlitColors.blue800),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'AI model files are typically 1–5 GB. '
              'Wi-Fi recommended. Download continues in the background.',
              style: TextStyle(
                color: KudlitColors.blue800,
                fontSize: 11,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SetupActions extends StatelessWidget {
  const _SetupActions({
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: busy ? null : onDownload,
          icon: busy
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: KudlitColors.blue900,
                  ),
                )
              : const Icon(Icons.download_rounded),
          label: const Text('Download AI model'),
          style: FilledButton.styleFrom(
            backgroundColor: KudlitColors.blue400,
            foregroundColor: KudlitColors.blue900,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: busy ? null : onSkip,
          child: const Text(
            'Not now — use cloud AI',
            style: TextStyle(color: KudlitColors.grey300, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
