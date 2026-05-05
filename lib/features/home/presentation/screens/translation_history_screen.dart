import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/home/domain/entities/translation_result.dart';
import 'package:kudlit_ph/features/home/presentation/providers/translation_history_provider.dart';

class TranslationHistoryScreen extends StatelessWidget {
  const TranslationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _TranslationHistoryHeader(),
            const Expanded(child: _TranslationHistoryList()),
          ],
        ),
      ),
    );
  }
}

class _TranslationHistoryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: cs.onSurface,
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 4),
          Text(
            'Translation History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _TranslationHistoryList extends ConsumerWidget {
  const _TranslationHistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<TranslationResult>> historyAsync =
        ref.watch(translationHistoryNotifierProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => _ErrorState(message: e.toString()),
      data: (List<TranslationResult> results) {
        if (results.isEmpty) return const _EmptyState();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int i) =>
              _TranslationResultCard(result: results[i]),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.translate_rounded,
              size: 48,
              color: cs.onSurface.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No translations yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Translate Baybayin and your history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurface.withAlpha(100),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          'Could not load history.\n$message',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: cs.error, height: 1.5),
        ),
      ),
    );
  }
}

class _TranslationResultCard extends ConsumerWidget {
  const _TranslationResultCard({required this.result});

  final TranslationResult result;

  String _formattedDate(DateTime dt) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool hasAi = result.aiResponse.isNotEmpty;
    final bool isLatinToBaybayin = result.direction == 'latin_to_baybayin';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (result.baybayinText.isNotEmpty)
                      Text(
                        result.baybayinText,
                        style: TextStyle(
                          fontFamily: 'Baybayin Simple TAWBID',
                          fontSize: 22,
                          color: cs.onSurface,
                          letterSpacing: 4,
                          height: 1.2,
                        ),
                      ),
                    const SizedBox(height: 2),
                    Text(
                      result.latinText,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: <Widget>[
                        Text(
                          result.inputText,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: cs.onSurface.withAlpha(120),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          isLatinToBaybayin
                              ? Icons.arrow_forward_rounded
                              : Icons.arrow_back_rounded,
                          size: 11,
                          color: cs.onSurface.withAlpha(100),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: result.id != null
                        ? () => ref
                              .read(
                                translationHistoryNotifierProvider.notifier,
                              )
                              .toggleBookmark(result.id!, !result.isBookmarked)
                        : null,
                    child: Icon(
                      result.isBookmarked
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_add_outlined,
                      size: 18,
                      color: result.isBookmarked
                          ? cs.primary
                          : cs.onSurface.withAlpha(100),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formattedDate(result.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurface.withAlpha(110),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasAi) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.aiResponse,
                style: TextStyle(
                  fontSize: 12.5,
                  color: cs.onSurface.withAlpha(200),
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
