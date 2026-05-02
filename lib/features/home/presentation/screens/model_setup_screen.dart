import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/design_system/kudlit_colors.dart';
import 'package:kudlit_ph/features/auth/presentation/widgets/baybayin_backdrop.dart';
import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

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
  GemmaModelInfo? _selectedGemma;
  AiModelInfo? _selectedYolo;

  @override
  Widget build(BuildContext context) {
    final List<GemmaModelInfo> gemmaModels =
        ref.watch(availableGemmaModelsProvider).value ?? const [];
    final List<AiModelInfo> yoloModels =
        ref.watch(availableYoloModelsProvider).value ?? const [];

    if (_selectedGemma == null && gemmaModels.isNotEmpty) {
      _selectedGemma = gemmaModels.first;
    }
    if (_selectedYolo == null && yoloModels.isNotEmpty) {
      _selectedYolo = yoloModels.first;
    }

    return Scaffold(
      backgroundColor: KudlitColors.neutralBlack,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          const _SetupBackground(),
          _ModelSetupBody(
            gemmaModels: gemmaModels,
            yoloModels: yoloModels,
            selectedGemma: _selectedGemma,
            selectedYolo: _selectedYolo,
            busy: _busy,
            onGemmaChanged: (GemmaModelInfo? m) =>
                setState(() => _selectedGemma = m),
            onYoloChanged: (AiModelInfo? m) =>
                setState(() => _selectedYolo = m),
            onDownloadAll: _selectedGemma != null ? _onDownloadAll : null,
            onSkip: _onSkip,
          ),
        ],
      ),
    );
  }

  Future<void> _onDownloadAll() async {
    if (_busy || _selectedGemma == null) return;
    setState(() => _busy = true);

    ref
        .read(aiInferenceNotifierProvider.notifier)
        .triggerLocalDownload(_selectedGemma!);

    if (!kIsWeb && _selectedYolo != null) {
      final AiModelInfo yolo = _selectedYolo!;
      final String yoloUrl;
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        yoloUrl = yolo.iosModelLink ?? yolo.modelLink;
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        yoloUrl = yolo.androidModelLink ?? yolo.modelLink;
      } else {
        yoloUrl = yolo.modelLink;
      }
      if (yoloUrl.isNotEmpty) {
        try {
          await YoloModelCache.instance.download(
            yolo.id,
            yoloUrl,
            version: yolo.version,
          );
          ref.invalidate(yoloModelPathProvider);
        } catch (e) {
          debugPrint('[ModelSetup] YOLO download failed: $e');
        }
      }
    }

    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .setAiPreference(AiPreference.local);
    await ref
        .read(appPreferencesNotifierProvider.notifier)
        .markModelsDownloaded();
  }

  Future<void> _onSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
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
    required this.gemmaModels,
    required this.yoloModels,
    required this.selectedGemma,
    required this.selectedYolo,
    required this.busy,
    required this.onGemmaChanged,
    required this.onYoloChanged,
    required this.onDownloadAll,
    required this.onSkip,
  });

  final List<GemmaModelInfo> gemmaModels;
  final List<AiModelInfo> yoloModels;
  final GemmaModelInfo? selectedGemma;
  final AiModelInfo? selectedYolo;
  final bool busy;
  final ValueChanged<GemmaModelInfo?> onGemmaChanged;
  final ValueChanged<AiModelInfo?> onYoloChanged;
  final VoidCallback? onDownloadAll;
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
            _ModelSelectionSection(
              gemmaModels: gemmaModels,
              yoloModels: yoloModels,
              selectedGemma: selectedGemma,
              selectedYolo: selectedYolo,
              onGemmaChanged: onGemmaChanged,
              onYoloChanged: onYoloChanged,
            ),
            const SizedBox(height: 10),
            const _DownloadNotice(),
            const Spacer(flex: 3),
            _SetupActions(
              busy: busy,
              onDownloadAll: onDownloadAll,
              onSkip: onSkip,
            ),
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
    required this.onDownloadAll,
    required this.onSkip,
  });

  final bool busy;
  final VoidCallback? onDownloadAll;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        FilledButton.icon(
          onPressed: busy ? null : onDownloadAll,
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
          label: const Text('Download all'),
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

class _ModelSelectionSection extends StatelessWidget {
  const _ModelSelectionSection({
    required this.gemmaModels,
    required this.yoloModels,
    required this.selectedGemma,
    required this.selectedYolo,
    required this.onGemmaChanged,
    required this.onYoloChanged,
  });

  final List<GemmaModelInfo> gemmaModels;
  final List<AiModelInfo> yoloModels;
  final GemmaModelInfo? selectedGemma;
  final AiModelInfo? selectedYolo;
  final ValueChanged<GemmaModelInfo?> onGemmaChanged;
  final ValueChanged<AiModelInfo?> onYoloChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ModelDropdown<GemmaModelInfo>(
          label: 'Translation model (Gemma)',
          models: gemmaModels,
          selected: selectedGemma,
          onChanged: onGemmaChanged,
          nameOf: (GemmaModelInfo m) => m.name,
        ),
        const SizedBox(height: 10),
        _ModelDropdown<AiModelInfo>(
          label: 'Recognition model (YOLO)',
          models: yoloModels,
          selected: selectedYolo,
          onChanged: onYoloChanged,
          nameOf: (AiModelInfo m) => m.name,
        ),
      ],
    );
  }
}

class _ModelDropdown<T> extends StatelessWidget {
  const _ModelDropdown({
    required this.label,
    required this.models,
    required this.selected,
    required this.onChanged,
    required this.nameOf,
  });

  final String label;
  final List<T> models;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final String Function(T) nameOf;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: selected,
      items: models
          .map((T m) => DropdownMenuItem<T>(value: m, child: Text(nameOf(m))))
          .toList(growable: false),
      onChanged: models.isEmpty ? null : onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: KudlitColors.blue800, fontSize: 13),
        filled: true,
        fillColor: KudlitColors.blue100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KudlitColors.blue300.withAlpha(80)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: KudlitColors.blue300.withAlpha(80)),
        ),
      ),
      dropdownColor: KudlitColors.blue100,
      style: const TextStyle(color: KudlitColors.blue900, fontSize: 14),
      hint: Text(
        models.isEmpty ? 'Loading…' : 'Select a model',
        style: const TextStyle(color: KudlitColors.blue800, fontSize: 14),
      ),
    );
  }
}
