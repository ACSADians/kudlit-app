import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import 'package:kudlit_ph/features/home/domain/entities/translation_result.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translate_text_controller.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translation_history_provider.dart';
import 'output_action_pill.dart';

class OutputActions extends ConsumerWidget {
  const OutputActions({
    super.key,
    this.copyLabel = 'Copy',
    this.shareLabel = 'Share',
    this.onCopy,
    this.onShare,
  });

  final String copyLabel;
  final String shareLabel;
  final VoidCallback? onCopy;
  final VoidCallback? onShare;

  String _outputText(TranslateTextState state) =>
      state.latinToBaybayin ? state.baybayinText : state.latinText;

  Future<void> _copy(BuildContext context, TranslateTextState state) async {
    final String text = _outputText(state);
    if (text.trim().isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Copied to clipboard.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _share(TranslateTextState state) async {
    final String output = _outputText(state);
    if (output.trim().isEmpty) return;
    final String shareText = state.latinToBaybayin
        ? '"${state.inputText}" in Baybayin: $output'
        : '"${state.inputText}" -> $output';
    await SharePlus.instance.share(ShareParams(text: shareText));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TranslateTextState state = ref.watch(translateTextControllerProvider);
    final bool hasOutput = _outputText(state).trim().isNotEmpty;

    final TranslationResult? latest = ref
        .watch(translationHistoryNotifierProvider)
        .value
        ?.firstOrNull;
    final bool isBookmarked = latest?.isBookmarked ?? false;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        OutputActionPill(
          icon: Icons.copy_rounded,
          label: copyLabel,
          onTap: onCopy ?? (hasOutput ? () => _copy(context, state) : null),
        ),
        const SizedBox(width: 8),
        OutputActionPill(
          icon: Icons.share_rounded,
          label: shareLabel,
          onTap: onShare ?? (hasOutput ? () => _share(state) : null),
        ),
        const SizedBox(width: 8),
        OutputActionPill(
          icon: isBookmarked
              ? Icons.bookmark_rounded
              : Icons.bookmark_add_outlined,
          label: isBookmarked ? 'Saved' : 'Save',
          onTap: hasOutput && latest?.id != null
              ? () => ref
                    .read(translationHistoryNotifierProvider.notifier)
                    .toggleBookmark(latest!.id!, !isBookmarked)
              : null,
        ),
      ],
    );
  }
}
