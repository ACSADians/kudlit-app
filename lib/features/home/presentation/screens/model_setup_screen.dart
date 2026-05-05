import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/baybayin_backdrop.dart';
import 'package:kudlit_ph/features/home/presentation/providers/model_setup_controller.dart';
import 'package:kudlit_ph/features/home/presentation/widgets/model_setup_model_card.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
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
  @override
  Widget build(BuildContext context) {
    final ModelSetupState setupState = ref.watch(modelSetupControllerProvider);
    final AiInferenceState? inferenceState = ref
        .watch(aiInferenceNotifierProvider)
        .value;
    final GemmaModelInfo? model = _resolveModel(inferenceState);

    return Scaffold(
      backgroundColor: KudlitColors.neutralBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SetupBackground(),
          _ModelSetupBody(
            model: model,
            busy: setupState.busy,
            onDownload: model == null
                ? null
                : () => ref
                      .read(modelSetupControllerProvider.notifier)
                      .download(model),
            onSkip: () =>
                ref.read(modelSetupControllerProvider.notifier).skip(),
          ),
        ],
      ),
    );
  }

  GemmaModelInfo? _resolveModel(AiInferenceState? s) => switch (s) {
    AiReady(:final GemmaModelInfo activeModel) => activeModel,
    AiLocalModelMissing(:final GemmaModelInfo model) => model,
    AiDownloading(:final GemmaModelInfo model) => model,
    _ => null,
  };
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

  final GemmaModelInfo? model;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool landscape = constraints.maxWidth > constraints.maxHeight;
          final bool shortPortrait = constraints.maxHeight < 680;
          return landscape
              ? _LandscapeSetupLayout(
                  model: model,
                  busy: busy,
                  onDownload: onDownload,
                  onSkip: onSkip,
                )
              : shortPortrait
              ? _ShortPortraitSetupLayout(
                  model: model,
                  busy: busy,
                  onDownload: onDownload,
                  onSkip: onSkip,
                )
              : _PortraitSetupLayout(
                  model: model,
                  busy: busy,
                  onDownload: onDownload,
                  onSkip: onSkip,
                );
        },
      ),
    );
  }
}

class _PortraitSetupLayout extends StatelessWidget {
  const _PortraitSetupLayout({
    required this.model,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Spacer(flex: 2),
          const _SetupHero(),
          const SizedBox(height: 20),
          const _SetupHeadline(),
          const SizedBox(height: 18),
          ModelSetupModelCard(modelName: model?.name),
          const SizedBox(height: 10),
          const _DownloadNotice(),
          const Spacer(flex: 3),
          _SetupActions(busy: busy, onDownload: onDownload, onSkip: onSkip),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ShortPortraitSetupLayout extends StatelessWidget {
  const _ShortPortraitSetupLayout({
    required this.model,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _SetupHero(height: 86),
          const SizedBox(height: 14),
          const _SetupHeadline(compact: true),
          const SizedBox(height: 16),
          ModelSetupModelCard(modelName: model?.name),
          const SizedBox(height: 10),
          const _DownloadNotice(),
          const SizedBox(height: 18),
          _SetupActions(
            busy: busy,
            onDownload: onDownload,
            onSkip: onSkip,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _LandscapeSetupLayout extends StatelessWidget {
  const _LandscapeSetupLayout({
    required this.model,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SetupHero(height: 86),
                    SizedBox(height: 14),
                    _SetupHeadline(compact: true),
                  ],
                ),
              ),
              const SizedBox(width: 22),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ModelSetupModelCard(modelName: model?.name),
                    const SizedBox(height: 10),
                    const _DownloadNotice(),
                    const SizedBox(height: 14),
                    _SetupActions(
                      busy: busy,
                      onDownload: onDownload,
                      onSkip: onSkip,
                      compact: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupHero extends StatelessWidget {
  const _SetupHero({this.height = 110});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Center(
        child: Image.asset(
          'assets/brand/ButtyRead.webp',
          height: height,
          errorBuilder: (context, error, stackTrace) =>
              SizedBox(height: height),
        ),
      ),
    );
  }
}

class _SetupHeadline extends StatelessWidget {
  const _SetupHeadline({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Power up Kudlit',
          style: TextStyle(
            color: KudlitColors.blue900,
            fontSize: compact ? 24 : 28,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: compact ? 8 : 10),
        Text(
          'Kudlit uses on-device AI models for Baybayin recognition '
          'and translation — no internet needed once downloaded.',
          style: TextStyle(
            color: KudlitColors.grey300,
            fontSize: compact ? 13 : 15,
            height: compact ? 1.35 : 1.55,
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
    this.compact = false,
  });

  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;
  final bool compact;

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
            padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
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
