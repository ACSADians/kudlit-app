import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

import 'profile_management_action_button.dart';

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
            label: 'Gemma 4 E2B',
            sublabel: 'Butty offline AI  ·  ~2.4 GB',
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
              onTrigger: (GemmaModelInfo m) => notifier.triggerLocalDownload(m),
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
    required this.onTrigger,
  });

  final AiInferenceState state;
  final Future<void> Function() onDownload;
  final void Function() onCancel;
  final void Function(GemmaModelInfo) onTrigger;

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AiReady(:final AiPreference mode, :final GemmaModelInfo activeModel) =>
        _ReadyRow(
          modelName: activeModel.name,
          cloudMode: mode == AiPreference.cloud,
        ),
      AiLocalModelMissing(:final String? note) => _ActionRow(
        badge: const _StatusBadge(label: 'Not downloaded', ok: false),
        primary: 'Download',
        onPrimary: onDownload,
        note: note,
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

class _ReadyRow extends StatelessWidget {
  const _ReadyRow({required this.modelName, required this.cloudMode});

  final String modelName;
  final bool cloudMode;

  @override
  Widget build(BuildContext context) {
    if (cloudMode) {
      return const _StatusBadge(label: 'Cloud mode — not needed', ok: null);
    }
    return Row(
      children: <Widget>[_StatusBadge(label: '$modelName installed', ok: true)],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.badge,
    required this.primary,
    required this.onPrimary,
    this.note,
  });

  final Widget badge;
  final String primary;
  final VoidCallback onPrimary;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            badge,
            const Spacer(),
            ProfileManagementActionButton(
              label: primary,
              isPrimary: true,
              onTap: onPrimary,
            ),
          ],
        ),
        if (note != null) ...<Widget>[
          const SizedBox(height: 8),
          Text(
            note!,
            style: TextStyle(fontSize: 11, color: cs.onSurface.withAlpha(150)),
          ),
        ],
      ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Downloading $label… $progress%',
              style: TextStyle(color: cs.primary, fontSize: 13),
            ),
            GestureDetector(
              onTap: onCancel,
              child: Text(
                'Cancel',
                style: TextStyle(color: cs.error, fontSize: 12),
              ),
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

/// `ok: true` → green installed, `ok: false` → red missing, `ok: null` → muted.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.ok});

  final String label;
  final bool? ok;

  @override
  Widget build(BuildContext context) {
    final Color bg = ok == true
        ? Colors.green.shade800.withAlpha(40)
        : ok == false
        ? Colors.red.shade800.withAlpha(40)
        : Theme.of(context).colorScheme.surfaceContainerHigh;
    final Color fg = ok == true
        ? Colors.green.shade300
        : ok == false
        ? Colors.red.shade300
        : Theme.of(context).colorScheme.onSurface.withAlpha(150);

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
