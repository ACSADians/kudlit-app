import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kudlit_ph/features/learning/domain/entities/glyph_entry.dart';
import 'package:kudlit_ph/features/learning/presentation/providers/character_gallery_provider.dart';
import 'package:kudlit_ph/features/learning/presentation/widgets/glyph_detail_sheet.dart';

const List<String> _kGroupOrder = <String>['Vowels', 'Consonants', 'Kudlit'];

class CharacterGalleryScreen extends ConsumerWidget {
  const CharacterGalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<GlyphEntry>> state =
        ref.watch(characterGalleryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('All Glyphs')),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, _) => const _GalleryErrorBody(),
        data: (List<GlyphEntry> entries) => _GalleryBody(entries: entries),
      ),
    );
  }
}

// ─── Body ──────────────────────────────────────────────────────────────────────

class _GalleryErrorBody extends StatelessWidget {
  const _GalleryErrorBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Could not load glyphs.',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

class _GalleryBody extends StatelessWidget {
  const _GalleryBody({required this.entries});

  final List<GlyphEntry> entries;

  @override
  Widget build(BuildContext context) {
    final Map<String, List<GlyphEntry>> grouped =
        <String, List<GlyphEntry>>{};
    for (final GlyphEntry entry in entries) {
      grouped.putIfAbsent(entry.group, () => <GlyphEntry>[]).add(entry);
    }
    final List<String> orderedGroups = _kGroupOrder
        .where(grouped.containsKey)
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: orderedGroups.length,
      itemBuilder: (BuildContext context, int i) => _GallerySection(
        title: orderedGroups[i],
        entries: grouped[orderedGroups[i]]!,
      ),
    );
  }
}

// ─── Section ───────────────────────────────────────────────────────────────────

class _GallerySection extends StatelessWidget {
  const _GallerySection({required this.title, required this.entries});

  final String title;
  final List<GlyphEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.82,
          ),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int i) =>
              _GlyphCell(entry: entries[i]),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─── Cell ──────────────────────────────────────────────────────────────────────

class _GlyphCell extends StatelessWidget {
  const _GlyphCell({required this.entry});

  final GlyphEntry entry;

  void _onTap(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GlyphDetailSheet(entry: entry),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme cs = Theme.of(context).colorScheme;
    final bool hasStroke =
        entry.strokeOrder != null && !entry.strokeOrder!.isEmpty;
    return Card(
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: () => _onTap(context),
        child: _GlyphCellContent(entry: entry, hasStroke: hasStroke, cs: cs),
      ),
    );
  }
}

class _GlyphCellContent extends StatelessWidget {
  const _GlyphCellContent({
    required this.entry,
    required this.hasStroke,
    required this.cs,
  });

  final GlyphEntry entry;
  final bool hasStroke;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          entry.glyph,
          style: TextStyle(
            fontFamily: 'Baybayin Simple TAWBID',
            fontSize: 48,
            height: 1,
            color: cs.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          entry.label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        if (hasStroke) ...<Widget>[
          const SizedBox(height: 4),
          Icon(
            Icons.play_circle_outline_rounded,
            size: 12,
            color: cs.onPrimaryContainer.withValues(alpha: 0.5),
          ),
        ],
      ],
    );
  }
}
