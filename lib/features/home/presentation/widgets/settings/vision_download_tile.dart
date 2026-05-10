import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/scanner/data/datasources/web_vision_model_preflight.dart';
import 'package:kudlit_ph/features/scanner/data/datasources/yolo_model_cache.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/yolo_model_selection_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/ai_model_info.dart';

import 'profile_management_action_button.dart';

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
        await YoloModelCache.instance.download(
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
        checkingWebModel: kIsWeb,
      );
    }
    if (_error != null) {
      return _ErrRow(message: _error!);
    }
    return _VisionStatusRow(model: model, onPrepare: () => _prepare(model));
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
          final String installedLabel = kIsWeb
              ? '${model.name} ready in browser'
              : '${model.name} installed';
          return Row(
            children: <Widget>[
              _StatusBadge(label: installedLabel, ok: true),
              const Spacer(),
              ProfileManagementActionButton(
                label: kIsWeb ? 'Reload' : 'Re-download',
                onTap: onPrepare,
              ),
            ],
          );
        }
        final String actionLabel = kIsWeb ? 'Load in browser' : 'Download';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const _StatusBadge(label: 'Not ready', ok: false),
                const Spacer(),
                ProfileManagementActionButton(
                  label: actionLabel,
                  isPrimary: true,
                  onTap: onPrepare,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              status.message,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
              ),
            ),
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
          Text(
            'Loading $label in the browser…',
            style: TextStyle(color: cs.primary, fontSize: 13),
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
                kIsWeb
                    ? 'Baybayin OCR scanner  ·  YOLOv12 via tflite_web'
                    : 'Baybayin OCR scanner  ·  YOLO TFLite',
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
    final Color bg = ok
        ? Colors.green.shade800.withAlpha(40)
        : Colors.red.shade800.withAlpha(40);
    final Color fg = ok ? Colors.green.shade300 : Colors.red.shade300;

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
