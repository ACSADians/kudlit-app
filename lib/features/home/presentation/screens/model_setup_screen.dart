import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/core/design_system/widgets/kudlit_loading_indicator.dart';
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
    final AsyncValue<AiInferenceState> inferenceState = ref.watch(
      aiInferenceNotifierProvider,
    );
    final GemmaModelInfo? model = _resolveModel(inferenceState.value);
    final _SetupStatus status = _resolveStatus(inferenceState, setupState);

    return Scaffold(
      backgroundColor: KudlitColors.neutralBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SetupBackground(),
          _ModelSetupBody(
            model: model,
            status: status,
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

  _SetupStatus _resolveStatus(
    AsyncValue<AiInferenceState> asyncState,
    ModelSetupState setupState,
  ) {
    final String? setupError = setupState.errorMessage;
    if (setupError != null && setupError.trim().isNotEmpty) {
      return _SetupStatus.error(
        title: 'Download needs attention',
        message: setupError,
      );
    }

    return asyncState.when(
      loading: () => _SetupStatus.loading(
        title: 'Preparing AI catalog',
        message: 'Checking available local models.',
      ),
      error: (Object error, StackTrace stackTrace) => _SetupStatus.error(
        title: 'Model status unavailable',
        message: 'You can skip setup and use cloud AI for now.',
      ),
      data: (AiInferenceState state) => switch (state) {
        AiLocalModelMissing(:final GemmaModelInfo model) => _SetupStatus.ready(
          title: 'Ready to download',
          message: '${model.name} is selected for local use.',
        ),
        AiDownloading(:final int progress, :final String? statusMessage) =>
          _SetupStatus.downloading(
            title: 'Downloading model',
            message: statusMessage ?? 'Keep Kudlit open while the model saves.',
            progress: progress,
          ),
        AiReady() => _SetupStatus.ready(
          title: 'Local AI is ready',
          message: 'You can continue with on-device learning tools.',
        ),
        AiInferenceError(:final String message) => _SetupStatus.error(
          title: 'Model setup paused',
          message: message,
        ),
        AiInferenceIdle() => _SetupStatus.loading(
          title: 'Preparing AI catalog',
          message: 'Checking available local models.',
        ),
      },
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
    required this.status,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final _SetupStatus status;
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
                  status: status,
                  busy: busy,
                  onDownload: onDownload,
                  onSkip: onSkip,
                )
              : shortPortrait
              ? _ShortPortraitSetupLayout(
                  model: model,
                  status: status,
                  busy: busy,
                  onDownload: onDownload,
                  onSkip: onSkip,
                )
              : _PortraitSetupLayout(
                  model: model,
                  status: status,
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
    required this.status,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final _SetupStatus status;
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
          _SetupStatusPanel(status: status),
          const SizedBox(height: 10),
          const _DownloadNotice(),
          const Spacer(flex: 3),
          _SetupActions(
            hasModel: model != null,
            busy: busy,
            onDownload: onDownload,
            onSkip: onSkip,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ShortPortraitSetupLayout extends StatelessWidget {
  const _ShortPortraitSetupLayout({
    required this.model,
    required this.status,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final _SetupStatus status;
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
          _SetupStatusPanel(status: status, compact: true),
          const SizedBox(height: 10),
          const _DownloadNotice(compact: true),
          const SizedBox(height: 18),
          _SetupActions(
            hasModel: model != null,
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
    required this.status,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
  });

  final GemmaModelInfo? model;
  final _SetupStatus status;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
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
                    const SizedBox(height: 8),
                    _SetupStatusPanel(status: status, compact: true),
                    const SizedBox(height: 8),
                    const _DownloadNotice(compact: true),
                    const SizedBox(height: 10),
                    _SetupActions(
                      hasModel: model != null,
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
  const _DownloadNotice({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 10,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: KudlitColors.blue100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KudlitColors.blue300.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.info_outline,
            size: compact ? 12 : 13,
            color: KudlitColors.blue800,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'AI model files are typically 1–5 GB. '
              'Wi-Fi recommended. Download continues in the background.',
              style: TextStyle(
                color: KudlitColors.blue800,
                fontSize: compact ? 10 : 11,
                height: compact ? 1.35 : 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SetupStatusTone { loading, ready, downloading, error }

class _SetupStatus {
  const _SetupStatus({
    required this.title,
    required this.message,
    required this.tone,
    this.progress,
  });

  const _SetupStatus.loading({required String title, required String message})
    : this(title: title, message: message, tone: _SetupStatusTone.loading);

  const _SetupStatus.ready({required String title, required String message})
    : this(title: title, message: message, tone: _SetupStatusTone.ready);

  const _SetupStatus.downloading({
    required String title,
    required String message,
    required int progress,
  }) : this(
         title: title,
         message: message,
         tone: _SetupStatusTone.downloading,
         progress: progress,
       );

  const _SetupStatus.error({required String title, required String message})
    : this(title: title, message: message, tone: _SetupStatusTone.error);

  final String title;
  final String message;
  final _SetupStatusTone tone;
  final int? progress;
}

class _SetupStatusPanel extends StatelessWidget {
  const _SetupStatusPanel({required this.status, this.compact = false});

  final _SetupStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color accent = switch (status.tone) {
      _SetupStatusTone.error => KudlitColors.danger400,
      _SetupStatusTone.ready => KudlitColors.success400,
      _SetupStatusTone.downloading => KudlitColors.blue400,
      _SetupStatusTone.loading => KudlitColors.yellow300,
    };
    final IconData icon = switch (status.tone) {
      _SetupStatusTone.error => Icons.error_outline_rounded,
      _SetupStatusTone.ready => Icons.check_circle_outline_rounded,
      _SetupStatusTone.downloading => Icons.downloading_rounded,
      _SetupStatusTone.loading => Icons.hourglass_top_rounded,
    };
    final int? progress = status.progress?.clamp(0, 100);

    return Semantics(
      container: true,
      liveRegion: status.tone == _SetupStatusTone.downloading,
      label: '${status.title}. ${status.message}',
      child: Container(
        padding: EdgeInsets.all(compact ? 8 : 12),
        decoration: BoxDecoration(
          color: KudlitColors.neutralBlack.withAlpha(120),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withAlpha(120)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _StatusIcon(
                  accent: accent,
                  icon: icon,
                  tone: status.tone,
                  compact: compact,
                ),
                SizedBox(width: compact ? 8 : 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        status.title,
                        style: TextStyle(
                          color: KudlitColors.blue900,
                          fontSize: compact ? 12 : 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        status.message,
                        style: TextStyle(
                          color: KudlitColors.grey200,
                          fontSize: compact ? 11 : 12,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (progress != null) ...<Widget>[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: progress / 100,
                  backgroundColor: KudlitColors.blue100.withAlpha(120),
                  valueColor: AlwaysStoppedAnimation<Color>(accent),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$progress% complete',
                style: const TextStyle(
                  color: KudlitColors.grey300,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({
    required this.accent,
    required this.icon,
    required this.tone,
    required this.compact,
  });

  final Color accent;
  final IconData icon;
  final _SetupStatusTone tone;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 24 : 28,
      height: compact ? 24 : 28,
      decoration: BoxDecoration(
        color: accent.withAlpha(35),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: tone == _SetupStatusTone.loading
            ? KudlitLoadingIndicator(
                size: compact ? 13 : 15,
                strokeWidth: 2,
                color: accent,
              )
            : Icon(icon, size: compact ? 15 : 16, color: accent),
      ),
    );
  }
}

class _SetupActions extends StatelessWidget {
  const _SetupActions({
    required this.hasModel,
    required this.busy,
    required this.onDownload,
    required this.onSkip,
    this.compact = false,
  });

  final bool hasModel;
  final bool busy;
  final VoidCallback? onDownload;
  final VoidCallback onSkip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool canDownload = !busy && onDownload != null;
    final String label = busy
        ? 'Downloading model'
        : hasModel
        ? 'Download AI model'
        : 'Waiting for model';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          button: true,
          enabled: canDownload,
          label: label,
          hint: hasModel
              ? 'Downloads the selected model for local use.'
              : 'Model information is still loading.',
          child: FilledButton.icon(
            onPressed: canDownload ? onDownload : null,
            icon: busy
                ? const KudlitLoadingIndicator(
                    size: 16,
                    strokeWidth: 2,
                    color: KudlitColors.blue900,
                  )
                : const Icon(Icons.download_rounded),
            label: Text(label),
            style: FilledButton.styleFrom(
              minimumSize: Size.fromHeight(compact ? 46 : 52),
              backgroundColor: KudlitColors.blue400,
              disabledBackgroundColor: KudlitColors.grey300.withAlpha(60),
              foregroundColor: KudlitColors.blue900,
              disabledForegroundColor: KudlitColors.grey300,
              padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        SizedBox(height: compact ? 8 : 12),
        TextButton(
          onPressed: busy ? null : onSkip,
          style: TextButton.styleFrom(
            minimumSize: Size.fromHeight(compact ? 44 : 48),
            padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
            foregroundColor: KudlitColors.grey300,
            disabledForegroundColor: KudlitColors.grey500,
          ),
          child: const Text(
            'Not now - use cloud AI',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
