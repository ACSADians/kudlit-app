import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/presentation/providers/app_preferences_provider.dart';
import 'package:kudlit_ph/features/translator/data/datasources/local_gemma_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/gemma_model_info.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

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
    final AsyncValue<AppPreferences> prefsAsync = ref.watch(
      appPreferencesNotifierProvider,
    );
    final AsyncValue<LocalGemmaReadiness> readinessAsync = ref.watch(
      localModelReadinessProvider,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _TileHeader(
            icon: Icons.psychology_rounded,
            label: 'Butty AI',
            sublabel: 'Offline chat  ·  large download',
          ),
          const SizedBox(height: 10),
          _LlmStatusRow(
            stateAsync: stateAsync,
            prefsAsync: prefsAsync,
            readinessAsync: readinessAsync,
            onCancel: notifier.cancelDownload,
            onTrigger: (GemmaModelInfo model) =>
                notifier.triggerLocalDownload(model),
          ),
        ],
      ),
    );
  }
}

class _LlmStatusRow extends StatelessWidget {
  const _LlmStatusRow({
    required this.stateAsync,
    required this.prefsAsync,
    required this.readinessAsync,
    required this.onCancel,
    required this.onTrigger,
  });

  final AsyncValue<AiInferenceState> stateAsync;
  final AsyncValue<AppPreferences> prefsAsync;
  final AsyncValue<LocalGemmaReadiness> readinessAsync;
  final VoidCallback onCancel;
  final void Function(GemmaModelInfo model) onTrigger;

  @override
  Widget build(BuildContext context) {
    if (stateAsync.hasError) {
      return _ErrRow(
        message: _friendlyLlmModelError(stateAsync.asError!.error.toString()),
      );
    }

    final AiInferenceState? state = stateAsync.value;
    if (state is AiDownloading) {
      return _ProgressRow(
        progress: state.progress,
        onCancel: onCancel,
        statusMessage: state.statusMessage,
      );
    }
    if (state is AiInferenceError) {
      return _ErrRow(message: _friendlyLlmModelError(state.message));
    }

    if (prefsAsync.hasError) {
      return _ErrRow(
        message: _friendlyLlmModelError(prefsAsync.asError!.error.toString()),
      );
    }
    if (readinessAsync.hasError) {
      return _ErrRow(
        message: _friendlyLlmModelError(readinessAsync.error.toString()),
      );
    }

    final LocalGemmaReadiness? readiness = readinessAsync.value;
    final GemmaModelInfo? activeModel = switch (state) {
      AiReady(:final GemmaModelInfo activeModel) => activeModel,
      AiLocalModelMissing(:final GemmaModelInfo model) => model,
      _ => null,
    };

    if (readiness == null || activeModel == null) {
      return const _CheckingRow();
    }

    if (readiness.installed && readiness.usable) {
      return const _StatusRow(note: 'Downloaded');
    }

    if (readiness.installed) {
      return _StatusRow(
        note: 'Finishing setup…',
        action: _CompactIconActionButton(
          tooltip: 'Reload Butty AI',
          icon: Icons.refresh_rounded,
          onTap: () => onTrigger(activeModel),
        ),
      );
    }

    return _StatusRow(
      note: 'Download to use Butty offline.',
      action: _CompactIconActionButton(
        tooltip: 'Download Butty AI',
        icon: Icons.download_rounded,
        onTap: () => onTrigger(activeModel),
        isPrimary: true,
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({this.note, this.action});

  final String? note;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final Widget statusCopy = Text(
      note ?? '',
      style: TextStyle(
        fontSize: 11,
        height: 1.25,
        color: cs.onSurface.withAlpha(150),
      ),
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
    required this.progress,
    required this.onCancel,
    this.statusMessage,
  });

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
                'Downloading… $progress%',
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
      'Checking…',
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
    return 'Offline setup is paused. You can stay on internet mode and try again later.';
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
    return 'Offline downloads are not available right now. You can stay on internet mode for now.';
  }

  final bool looksTechnical =
      lower.contains('exception') ||
      lower.contains('stacktrace') ||
      lower.contains('statuscode') ||
      lower.contains('errno') ||
      lower.contains('uri=') ||
      lower.contains('https://');
  if (looksTechnical) {
    return 'Offline setup is paused. You can stay on internet mode and try again later.';
  }

  return message;
}
