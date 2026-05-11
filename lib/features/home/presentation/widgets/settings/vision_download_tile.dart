import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/web_vision_model_preflight.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

class VisionDownloadTile extends ConsumerStatefulWidget {
  const VisionDownloadTile({super.key});

  @override
  ConsumerState<VisionDownloadTile> createState() => _VisionDownloadTileState();
}

class _VisionDownloadTileState extends ConsumerState<VisionDownloadTile> {
  bool _downloading = false;
  int _progress = 0;
  String? _error;

  Future<void> _prepare(AiModelInfo model) async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });

    try {
      if (kIsWeb) {
        await createWebVisionModelPreflight().run(model.modelLink);
      } else {
        final String url = resolveYoloModelUrl(model);
        await ref
            .read(yoloModelCacheProvider)
            .download(
              model.id,
              url,
              version: model.version,
              onProgress: (int received, int total) {
                if (!mounted || total <= 0) return;
                setState(() => _progress = ((received / total) * 100).round());
              },
            );
      }

      ref.invalidate(visionModelSetupStatusProvider);
      ref.invalidate(yoloModelPathProvider);
      final AiModelInfo? activeCameraModel = ref
          .read(activeYoloModelProvider(YoloModelScope.camera))
          .value;
      if (!kIsWeb && activeCameraModel?.id == model.id) {
        unawaited(
          ref
              .read(yoloModelPathProvider(YoloModelScope.camera).future)
              .catchError((Object _) => ''),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => _error = kIsWeb
              ? friendlyVisionModelError(e.toString())
              : e.toString(),
        );
      }
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AiModelInfo>> modelsAsync = ref.watch(
      availableYoloModelsProvider,
    );
    final AsyncValue<AiModelInfo?> activeModelAsync = ref.watch(
      activeYoloModelProvider(YoloModelScope.camera),
    );
    final List<AiModelInfo>? availableModels = modelsAsync.asData?.value;
    final AiModelInfo? activeModel = activeModelAsync.asData?.value;
    final String headerLabel =
        activeModel?.name ??
        ((availableModels != null && availableModels.isNotEmpty)
            ? availableModels.first.name
            : 'Scanner model');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _VisionTileHeader(label: headerLabel),
          const SizedBox(height: 10),
          modelsAsync.when(
            loading: () => const _CheckingRow(),
            error: (Object e, _) => _ErrRow(message: e.toString()),
            data: (List<AiModelInfo> models) => _VisionDownloadBody(
              models: models,
              activeModelAsync: activeModelAsync,
              downloading: _downloading,
              progress: _progress,
              error: _error,
              onPrepare: _prepare,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionDownloadBody extends StatelessWidget {
  const _VisionDownloadBody({
    required this.models,
    required this.activeModelAsync,
    required this.downloading,
    required this.progress,
    required this.onPrepare,
    this.error,
  });

  final List<AiModelInfo> models;
  final AsyncValue<AiModelInfo?> activeModelAsync;
  final bool downloading;
  final int progress;
  final String? error;
  final ValueChanged<AiModelInfo> onPrepare;

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) return const _NoModelRow();
    return activeModelAsync.when(
      loading: () => const _CheckingRow(),
      error: (Object e, _) => _ErrRow(message: e.toString()),
      data: (AiModelInfo? activeModel) {
        final AiModelInfo model = activeModel ?? models.first;
        if (downloading) {
          return _DownloadProgressRow(
            label: model.name,
            progress: progress,
            checkingWebModel: kIsWeb,
          );
        }
        if (error != null) return _ErrRow(message: error!);
        return _VisionStatusRow(
          model: model,
          onPrepare: () => onPrepare(model),
        );
      },
    );
  }
}

class _VisionStatusRow extends ConsumerWidget {
  const _VisionStatusRow({required this.model, required this.onPrepare});

  final AiModelInfo model;
  final VoidCallback onPrepare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<VisionModelSetupStatus> statusAsync = ref.watch(
      visionModelSetupStatusProvider,
    );
    return statusAsync.when(
      loading: () => const _CheckingRow(),
      error: (Object e, _) => _ErrRow(message: e.toString()),
      data: (VisionModelSetupStatus status) {
        if (status.ready) {
          return _VisionActionRow(
            supportingText: 'Downloaded',
            action: _CompactIconActionButton(
              tooltip: 'Refresh scanner model',
              icon: Icons.refresh_rounded,
              onTap: onPrepare,
            ),
          );
        }

        return _VisionActionRow(
          supportingText: kIsWeb
              ? status.message
              : 'Download before using the scanner.',
          action: _CompactIconActionButton(
            tooltip: kIsWeb ? 'Load scanner model' : 'Download scanner model',
            icon: kIsWeb
                ? Icons.cloud_download_rounded
                : Icons.download_rounded,
            onTap: onPrepare,
            isPrimary: true,
          ),
        );
      },
    );
  }
}

class _VisionActionRow extends StatelessWidget {
  const _VisionActionRow({required this.supportingText, required this.action});

  final String supportingText;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Widget statusCopy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          supportingText,
          style: TextStyle(
            fontSize: 11,
            height: 1.25,
            color: cs.onSurface.withAlpha(150),
          ),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              statusCopy,
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerLeft, child: action),
            ],
          );
        }

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
              child: statusCopy,
            ),
            action,
          ],
        );
      },
    );
  }
}

class _DownloadProgressRow extends StatelessWidget {
  const _DownloadProgressRow({
    required this.label,
    required this.progress,
    required this.checkingWebModel,
  });

  final String label;
  final int progress;
  final bool checkingWebModel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    if (checkingWebModel) {
      return Row(
        children: <Widget>[
          Flexible(
            child: Text(
              'Getting camera reading ready...',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: cs.primary, fontSize: 13),
            ),
          ),
          const SizedBox(width: 10),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Downloading… $progress%',
          style: TextStyle(color: cs.primary, fontSize: 13),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress / 100),
      ],
    );
  }
}

class _VisionTileHeader extends StatelessWidget {
  const _VisionTileHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(Icons.camera_alt_rounded, size: 18, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                kIsWeb
                    ? 'Baybayin camera reading in this browser'
                    : 'Reads Baybayin with your camera',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoModelRow extends StatelessWidget {
  const _NoModelRow();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Scanner model setup is unavailable in this build.',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
      ),
    );
  }
}

class _CompactIconActionButton extends StatelessWidget {
  const _CompactIconActionButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: SizedBox(
        width: 44,
        height: 44,
        child: IconButton(
          onPressed: onTap,
          style: IconButton.styleFrom(
            backgroundColor: isPrimary ? cs.primary : cs.surface,
            foregroundColor: isPrimary ? cs.onPrimary : cs.onSurface,
            side: BorderSide(color: isPrimary ? cs.primary : cs.outline),
            shape: const CircleBorder(),
          ),
          icon: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _CheckingRow extends StatelessWidget {
  const _CheckingRow();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Checking status...',
      style: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.onSurface.withAlpha(128),
      ),
    );
  }
}

class _ErrRow extends StatelessWidget {
  const _ErrRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Setup failed: $message',
      child: Text(
        'Setup failed. Check your connection and try again.',
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}
