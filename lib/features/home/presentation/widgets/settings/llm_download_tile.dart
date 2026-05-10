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
            sublabel: 'Offline Butty chat  ·  ~2.4 GB',
          ),
          const SizedBox(height: 10),
          stateAsync.when(
            loading: () => const _CheckingRow(),
            error: (Object e, _) => _ErrRow(message: e.toString()),
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
        badge: const _StatusBadge(label: 'Setup needed', ok: false),
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
      AiInferenceError(:final String message) => _ErrRow(message: message),
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
      return const _ActionRow(
        badge: _StatusBadge(label: 'Cloud active', ok: null),
        note: 'Optional while Cloud is active.',
      );
    }
    return _ActionRow(
      badge: _StatusBadge(label: '$modelName ready', ok: true),
      note: 'Ready for local Butty replies.',
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.badge,
    this.primary,
    this.onPrimary,
    this.note,
  });

  final Widget badge;
  final String? primary;
  final VoidCallback? onPrimary;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;

    final Widget statusCopy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        badge,
        if (note != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            note!,
            style: TextStyle(
              fontSize: 11,
              height: 1.25,
              color: cs.onSurface.withAlpha(150),
            ),
          ),
        ],
      ],
    );
    final Widget? action = primary != null && onPrimary != null
        ? ProfileManagementActionButton(
            label: primary!,
            isPrimary: true,
            onTap: onPrimary,
          )
        : null;

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
            ?action,
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
            ProfileManagementActionButton(label: 'Cancel', onTap: onCancel),
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
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Color bg = ok == true
        ? cs.primaryContainer
        : ok == false
        ? cs.errorContainer
        : cs.surfaceContainerHigh;
    final Color fg = ok == true
        ? cs.onPrimaryContainer
        : ok == false
        ? cs.onErrorContainer
        : cs.onSurface.withAlpha(150);

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
