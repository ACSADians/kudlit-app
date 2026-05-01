import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_provider.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/ai_inference_state.dart';

class LocalModelStatusRow extends ConsumerWidget {
  const LocalModelStatusRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final AsyncValue<AiInferenceState> stateAsync = ref.watch(aiInferenceNotifierProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 44), // Align with text of other rows
          Expanded(
            child: stateAsync.when(
              loading: () => Text(
                'Checking local model status...',
                style: TextStyle(color: cs.onSurface.withAlpha(150), fontSize: 13),
              ),
              error: (Object e, _) => Text(
                'Error: $e',
                style: TextStyle(color: cs.error, fontSize: 13),
              ),
              data: (AiInferenceState state) {
                if (state is AiReady) {
                  return Text(
                    'Local model is installed and ready.',
                    style: TextStyle(color: Colors.green.shade600, fontSize: 13, fontWeight: FontWeight.w600),
                  );
                } else if (state is AiLocalModelMissing) {
                  return Row(
                    children: <Widget>[
                      Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Local model not installed. Requires ~1.5GB download.',
                          style: TextStyle(color: cs.error, fontSize: 13),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(aiInferenceNotifierProvider.notifier).downloadLocalModel();
                        },
                        child: const Text('Download', style: TextStyle(fontSize: 12)),
                      )
                    ],
                  );
                } else if (state is AiDownloading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            'Downloading model... ${state.progress}%',
                            style: TextStyle(color: cs.primary, fontSize: 13),
                          ),
                          InkWell(
                            onTap: () => ref.read(aiInferenceNotifierProvider.notifier).cancelDownload(),
                            child: Icon(Icons.cancel_rounded, size: 16, color: cs.error),
                          )
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: state.progress / 100),
                    ],
                  );
                } else if (state is AiInferenceError) {
                  return Text(
                    'Model Error: ${state.message}',
                    style: TextStyle(color: cs.error, fontSize: 13),
                  );
                } else {
                  return Text(
                    'Initializing AI...',
                    style: TextStyle(color: cs.onSurface.withAlpha(150), fontSize: 13),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
