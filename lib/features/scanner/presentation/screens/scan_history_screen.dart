import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/core/utils/baybayify.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/scan_result.dart';
import 'package:kudlit_ph/features/scanner/presentation/providers/scan_history_provider.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ScanHistoryHeader(),
            const Expanded(child: _ScanHistoryList()),
          ],
        ),
      ),
    );
  }
}

class _ScanHistoryHeader extends StatelessWidget {
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
            'Scanner History',
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

class _ScanHistoryList extends ConsumerWidget {
  const _ScanHistoryList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ScanResult>> historyAsync =
        ref.watch(scanHistoryNotifierProvider);

    return historyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (Object e, _) => _ErrorState(message: e.toString()),
      data: (List<ScanResult> results) {
        if (results.isEmpty) return const _EmptyState();
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: results.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (BuildContext context, int i) =>
              _ScanResultCard(result: results[i]),
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
              Icons.document_scanner_outlined,
              size: 48,
              color: cs.onSurface.withAlpha(80),
            ),
            const SizedBox(height: 16),
            Text(
              'No scans yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withAlpha(140),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Scan some Baybayin and your history will appear here.',
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
          style: TextStyle(
            fontSize: 13,
            color: cs.error,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ScanResultCard extends StatelessWidget {
  const _ScanResultCard({required this.result});

  final ScanResult result;

  String _formattedDate(DateTime dt) {
    final DateTime now = DateTime.now();
    final Duration diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final String word = result.tokens.join('');
    final String baybayin = baybayifyWord(word);
    final bool hasTranslation = result.translation.isNotEmpty;

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
                    if (baybayin.isNotEmpty)
                      Text(
                        baybayin,
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
                      word.isEmpty ? result.tokens.join(' · ') : word,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formattedDate(result.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurface.withAlpha(110),
                ),
              ),
            ],
          ),
          if (hasTranslation) ...<Widget>[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.translation,
                style: TextStyle(
                  fontSize: 12.5,
                  color: cs.onSurface.withAlpha(200),
                  height: 1.45,
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
          _TokenRow(tokens: result.tokens, cs: cs),
        ],
      ),
    );
  }
}

class _TokenRow extends StatelessWidget {
  const _TokenRow({required this.tokens, required this.cs});

  final List<String> tokens;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: tokens
          .map(
            (String t) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                t,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface.withAlpha(160),
                  letterSpacing: 0.3,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}
