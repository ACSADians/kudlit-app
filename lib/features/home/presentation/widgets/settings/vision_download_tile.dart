import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

import 'profile_management_action_button.dart';

/// Tracks whether a given YOLO model id has a cached file on disk.
final _yoloInstalledProvider = FutureProvider.autoDispose.family<bool, String>((
  Ref ref,
  String modelId,
) async {
  final String? path = await ref.read(yoloModelCacheProvider).pathFor(modelId);
  return path != null;
});

/// Settings tile for the KudVis vision model (YOLO OCR / camera scanner).
///
/// Manages its own download progress locally; invalidates the cache-status
/// provider after a successful download so the status badge refreshes.
class VisionDownloadTile extends ConsumerStatefulWidget {
  const VisionDownloadTile({super.key});

  @override
  ConsumerState<VisionDownloadTile> createState() => _VisionDownloadTileState();
}

class _VisionDownloadTileState extends ConsumerState<VisionDownloadTile> {
  bool _downloading = false;
  int _progress = 0;
  String? _error;

  Future<void> _download(AiModelInfo model) async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });

    final String url = Platform.isIOS
        ? (model.iosModelLink ?? model.modelLink)
        : (model.androidModelLink ?? model.modelLink);

    try {
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
      ref.invalidate(_yoloInstalledProvider(model.id));
      ref.invalidate(yoloModelPathProvider);
      unawaited(
        ref
            .read(yoloModelPathProvider(YoloModelScope.camera).future)
            .catchError((_) => ''),
      );
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AiModelInfo>> modelsAsync = ref.watch(
      availableYoloModelsProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _VisionTileHeader(),
          const SizedBox(height: 10),
          modelsAsync.when(
            loading: () => const _CheckingRow(),
            error: (Object e, _) => _ErrRow(message: e.toString()),
            data: (List<AiModelInfo> models) => _body(models),
          ),
        ],
      ),
    );
  }

  Widget _body(List<AiModelInfo> models) {
    if (models.isEmpty) {
      return const _NoModelRow();
    }
    final AiModelInfo model = models.first;

    if (_downloading) {
      return _DownloadProgressRow(label: model.name, progress: _progress);
    }
    if (_error != null) {
      return _ErrRow(message: _error!);
    }
    return _VisionStatusRow(model: model, onDownload: () => _download(model));
  }
}

// ─── Install-status row (watches cache) ───────────────────────────────────────

class _VisionStatusRow extends ConsumerWidget {
  const _VisionStatusRow({required this.model, required this.onDownload});

  final AiModelInfo model;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool? installed = ref.watch(_yoloInstalledProvider(model.id)).value;

    if (installed == null) return const _CheckingRow();

    if (installed) {
      return _VisionActionRow(
        badge: _StatusBadge(label: '${model.name} ready', ok: true),
        supportingText: 'Ready for local scanner startup.',
        action: ProfileManagementActionButton(
          label: 'Re-download',
          onTap: onDownload,
        ),
      );
    }
    return _VisionActionRow(
      badge: const _StatusBadge(label: 'Setup needed', ok: false),
      supportingText: 'Download once before live recognition.',
      action: ProfileManagementActionButton(
        label: 'Download',
        isPrimary: true,
        onTap: onDownload,
      ),
    );
  }
}

class _VisionActionRow extends StatelessWidget {
  const _VisionActionRow({
    required this.badge,
    required this.supportingText,
    required this.action,
  });

  final Widget badge;
  final String supportingText;
  final Widget action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: <Widget>[
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              badge,
              const SizedBox(height: 6),
              Text(
                supportingText,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.25,
                  color: cs.onSurface.withAlpha(150),
                ),
              ),
            ],
          ),
        ),
        action,
      ],
    );
  }
}

// ─── Progress row ─────────────────────────────────────────────────────────────

class _DownloadProgressRow extends StatelessWidget {
  const _DownloadProgressRow({required this.label, required this.progress});

  final String label;
  final int progress;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Downloading $label · $progress%',
          style: TextStyle(color: cs.primary, fontSize: 13),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress / 100),
      ],
    );
  }
}

// ─── Small shared widgets ─────────────────────────────────────────────────────

class _VisionTileHeader extends StatelessWidget {
  const _VisionTileHeader();

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
                'KudVis-1-Turbo',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              Text(
                'Local scanner recognition',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.ok});

  final String label;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = ok ? cs.primaryContainer : cs.errorContainer;
    final Color fg = ok ? cs.onPrimaryContainer : cs.onErrorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 11, color: fg),
      ),
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
