import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

/// Settings tile for the Gemma 4 LLM model (Butty offline AI).
///
/// Shows install status and a download/cancel button driven by
/// [AiInferenceNotifier] so it stays in sync with the chat screen.
class LlmDownloadTile extends ConsumerWidget {
  const LlmDownloadTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AiInferenceNotifier notifier = ref.read(
      aiInferenceNotifierProvider.notifier,
    );
    final AsyncValue<AiInferenceState> stateAsync = ref.watch(
      aiInferenceNotifierProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _TileHeader(
            icon: Icons.psychology_rounded,
            label: 'Butty AI',
            sublabel: 'Offline chat  ·  ~2.4 GB',
          ),
          const SizedBox(height: 10),
          stateAsync.when(
            loading: () => const _CheckingRow(),
            error: (Object e, _) =>
                _ErrRow(message: _friendlyLlmModelError(e.toString())),
            data: (AiInferenceState s) => _LlmStatusRow(
              state: s,
              onDownload: notifier.downloadLocalModel,
              onCancel: notifier.cancelDownload,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── State row ────────────────────────────────────────────────────────────────

class _LlmStatusRow extends StatelessWidget {
  const _LlmStatusRow({
    required this.state,
    required this.onDownload,
    required this.onCancel,
  });

  final AiInferenceState state;
  final Future<void> Function() onDownload;
  final void Function() onCancel;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AiReady() => const _StatusRow(note: 'Downloaded'),
      AiLocalModelMissing(:final String? note) => _StatusRow(
        note: note ?? 'Download to use Butty offline.',
        action: _CompactIconActionButton(
          tooltip: 'Download Butty AI',
          icon: Icons.download_rounded,
          onTap: onDownload,
          isPrimary: true,
        ),
      ),
      AiDownloading(
        :final GemmaModelInfo model,
        :final int progress,
        :final String? statusMessage,
      ) =>
        _ProgressRow(
          label: model.name,
          progress: progress,
          onCancel: onCancel,
          statusMessage: statusMessage,
        ),
      AiInferenceError(:final String message) => _ErrRow(
        message: _friendlyLlmModelError(message),
      ),
      _ => const _CheckingRow(),
    };
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({this.note, this.action});

  final String? note;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final Widget statusCopy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (note != null)
          Text(
            note!,
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
              if (action != null) ...<Widget>[
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerLeft, child: action),
              ],
            ],
          );
        }

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
              child: statusCopy,
            ),
            if (action case final Widget compactAction) compactAction,
          ],
        );
      },
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.progress,
    required this.onCancel,
    this.statusMessage,
  });

  final String label;
  final int progress;
  final VoidCallback onCancel;
  final String? statusMessage;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 8,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 180, maxWidth: 260),
              child: Text(
                'Downloading $label · $progress%',
                style: TextStyle(color: cs.primary, fontSize: 13),
              ),
            ),
            _CompactIconActionButton(
              tooltip: 'Cancel Butty AI download',
              icon: Icons.close_rounded,
              onTap: onCancel,
            ),
          ],
        ),
        if (statusMessage != null) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            statusMessage!,
            style: TextStyle(color: cs.onSurface.withAlpha(150), fontSize: 11),
          ),
        ],
        const SizedBox(height: 6),
        LinearProgressIndicator(value: progress / 100),
      ],
    );
  }
}

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _TileHeader extends StatelessWidget {
  const _TileHeader({
    required this.icon,
    required this.label,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: 18, color: cs.primary),
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
                sublabel,
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

class _ErrRow extends StatelessWidget {
  const _ErrRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Setup failed: $message',
      child: Text(
        message,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(context).colorScheme.error,
        ),
      ),
    );
  }
}

String _friendlyLlmModelError(String rawMessage) {
  final String message = rawMessage.trim();
  if (message.isEmpty) {
    return 'Local AI setup is paused. You can use cloud AI and retry later.';
  }

  final String lower = message.toLowerCase();
  final bool looksLikeNetworkIssue =
      lower.contains('socketexception') ||
      lower.contains('clientexception') ||
      lower.contains('failed host lookup') ||
      lower.contains('network') ||
      lower.contains('connection') ||
      lower.contains('timeout') ||
      lower.contains('supabase.co');
  if (looksLikeNetworkIssue) {
    return 'Check your connection, then retry the model download.';
  }

  if (lower.contains('cancel')) {
    return 'Download canceled. You can retry when you are ready.';
  }

  if (lower.contains('no ai models configured')) {
    return 'The local model list is not available yet. You can use cloud AI for now.';
  }

  final bool looksTechnical =
      lower.contains('exception') ||
      lower.contains('stacktrace') ||
      lower.contains('statuscode') ||
      lower.contains('errno') ||
      lower.contains('uri=') ||
      lower.contains('https://');
  if (looksTechnical) {
    return 'Local AI setup is paused. You can use cloud AI and retry later.';
  }

  return message;
}
