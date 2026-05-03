import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

import 'profile_management_action_button.dart';

/// Tracks whether a given YOLO model id has a cached file on disk.
final _yoloInstalledProvider =
    FutureProvider.autoDispose.family<bool, String>((Ref ref, String modelId) async {
  final String? path = await YoloModelCache.instance.pathFor(modelId);
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
      await YoloModelCache.instance.download(
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
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<AiModelInfo>> modelsAsync =
        ref.watch(availableYoloModelsProvider);

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
      return _DownloadProgressRow(
        label: model.name,
        progress: _progress,
      );
    }
    if (_error != null) {
      return _ErrRow(message: _error!);
    }
    return _VisionStatusRow(
      model: model,
      onDownload: () => _download(model),
    );
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
      return Row(
        children: <Widget>[
          _StatusBadge(label: '${model.name} installed', ok: true),
          const Spacer(),
          ProfileManagementActionButton(
            label: 'Re-download',
            onTap: onDownload,
          ),
        ],
      );
    }
    return Row(
      children: <Widget>[
        const _StatusBadge(label: 'Not downloaded', ok: false),
        const Spacer(),
        ProfileManagementActionButton(
          label: 'Download',
          isPrimary: true,
          onTap: onDownload,
        ),
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
          'Downloading $label… $progress%',
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'KudVis-1-Turbo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Text(
              'Baybayin OCR scanner  ·  YOLO TFLite',
              style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(128)),
            ),
          ],
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
    final Color bg = ok
        ? Colors.green.shade800.withAlpha(40)
        : Colors.red.shade800.withAlpha(40);
    final Color fg =
        ok ? Colors.green.shade300 : Colors.red.shade300;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: fg)),
    );
  }
}

class _NoModelRow extends StatelessWidget {
  const _NoModelRow();

  @override
  Widget build(BuildContext context) {
    return Text(
      'No vision model configured — add a row with model_type=\'vision\' in Supabase.',
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
      'Checking…',
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
    return Text(
      'Error: $message',
      style: TextStyle(
        fontSize: 12,
        color: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
