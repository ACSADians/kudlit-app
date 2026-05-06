import 'package:test/test.dart';

import 'package:kudlit_ph/features/translator/data/datasources/chat_memory_web_store.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_memory_fact.dart';

// Tests for ChatMemoryWebStore — the pure-Dart in-memory store used by
// SqliteChatMemoryDatasource when running on web (kIsWeb) or in unit tests
// (SqliteChatMemoryDatasource.inMemory()). These tests verify the contract
// that ChatMemoryRepositoryImpl relies on: empty-on-cold-start → Supabase
// restore → deduplicated write-through of new facts.

final DateTime _t0 = DateTime(2026, 5, 1);
final DateTime _t1 = DateTime(2026, 5, 2);
final DateTime _t2 = DateTime(2026, 5, 3);

ChatMemoryFact _fact(String content, {String type = 'general', DateTime? at}) {
  final DateTime ts = at ?? _t0;
  return ChatMemoryFact(
    factType: type,
    content: content,
    createdAt: ts,
    lastReferencedAt: ts,
  );
}

void main() {
  group('ChatMemoryWebStore', () {
    late ChatMemoryWebStore store;

    setUp(() => store = ChatMemoryWebStore());

    // ── loadAll ───────────────────────────────────────────────────────────────

    test('loadAll returns empty list on cold start', () {
      expect(store.loadAll(), isEmpty);
    });

    test('loadAll returns facts sorted newest-first', () {
      store.insertIfNew(_fact('oldest', at: _t0));
      store.insertIfNew(_fact('middle', at: _t1));
      store.insertIfNew(_fact('newest', at: _t2));

      expect(
        store.loadAll().map((ChatMemoryFact f) => f.content),
        <String>['newest', 'middle', 'oldest'],
      );
    });

    test('loadAll respects limit', () {
      store.insertIfNew(_fact('a', at: _t0));
      store.insertIfNew(_fact('b', at: _t1));
      store.insertIfNew(_fact('c', at: _t2));

      final List<ChatMemoryFact> limited = store.loadAll(limit: 2);
      expect(limited, hasLength(2));
      expect(
        limited.map((ChatMemoryFact f) => f.content),
        <String>['c', 'b'],
      );
    });

    // ── insertIfNew ───────────────────────────────────────────────────────────

    test('insertIfNew returns saved fact with non-null id', () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('learn Baybayin'));
      expect(saved, isNotNull);
      expect(saved!.id, isNotNull);
      expect(saved.content, 'learn Baybayin');
    });

    test('insertIfNew returns null for exact duplicate content', () {
      store.insertIfNew(_fact('likes Tagalog'));
      expect(store.insertIfNew(_fact('likes Tagalog')), isNull);
    });

    test('dedupe is case-insensitive and trims whitespace', () {
      store.insertIfNew(_fact('  Likes Tagalog  '));
      expect(store.insertIfNew(_fact('likes tagalog')), isNull);
    });

    test('different content inserts successfully', () {
      store.insertIfNew(_fact('fact one'));
      store.insertIfNew(_fact('fact two'));
      expect(store.loadAll(), hasLength(2));
    });

    test('insertIfNew assigns incrementing ids', () {
      final ChatMemoryFact? a = store.insertIfNew(_fact('a'));
      final ChatMemoryFact? b = store.insertIfNew(_fact('b'));
      expect(b!.id, greaterThan(a!.id!));
    });

    // ── setRemoteId ───────────────────────────────────────────────────────────

    test('setRemoteId attaches cloud UUID to a saved fact', () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('writes daily'));
      store.setRemoteId(localId: saved!.id!, remoteId: 'remote-xyz');

      expect(store.loadAll().first.remoteId, 'remote-xyz');
    });

    test('setRemoteId is no-op for unknown localId', () {
      store.insertIfNew(_fact('something'));
      store.setRemoteId(localId: 9999, remoteId: 'orphan');

      expect(store.loadAll().first.remoteId, isNull);
    });

    // ── findById ──────────────────────────────────────────────────────────────

    test('findById returns correct fact', () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('detail fact'));
      final ChatMemoryFact? found = store.findById(saved!.id!);
      expect(found?.content, 'detail fact');
    });

    test('findById returns null for unknown id', () {
      expect(store.findById(9999), isNull);
    });

    // ── updateFact ────────────────────────────────────────────────────────────

    test('updateFact changes content and factType', () {
      final ChatMemoryFact? saved = store.insertIfNew(
        _fact('old content', type: 'topic'),
      );
      store.updateFact(
        localId: saved!.id!,
        factType: 'preference',
        content: 'new content',
      );

      final ChatMemoryFact? updated = store.findById(saved.id!);
      expect(updated!.factType, 'preference');
      expect(updated.content, 'new content');
    });

    test('updateFact releases old normalized key so same old content can be '
        're-inserted as a new fact', () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('old'));
      store.updateFact(
        localId: saved!.id!,
        factType: 'general',
        content: 'updated',
      );
      // 'old' key is released — a new fact with that content should succeed.
      expect(store.insertIfNew(_fact('old')), isNotNull);
    });

    // ── deleteById ────────────────────────────────────────────────────────────

    test('deleteById removes the fact', () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('to delete'));
      store.deleteById(saved!.id!);

      expect(store.loadAll(), isEmpty);
    });

    test('deleteById releases normalized key so same content can be re-inserted',
        () {
      final ChatMemoryFact? saved = store.insertIfNew(_fact('unique'));
      store.deleteById(saved!.id!);

      expect(store.insertIfNew(_fact('unique')), isNotNull);
    });

    test('deleteById is no-op for unknown id', () {
      store.insertIfNew(_fact('keep me'));
      store.deleteById(9999);
      expect(store.loadAll(), hasLength(1));
    });

    // ── clear ─────────────────────────────────────────────────────────────────

    test('clear removes all facts', () {
      store.insertIfNew(_fact('a'));
      store.insertIfNew(_fact('b'));
      store.clear();

      expect(store.loadAll(), isEmpty);
    });

    test('insert after clear resets the id counter and dedupe index', () {
      store.insertIfNew(_fact('original'));
      store.clear();

      final ChatMemoryFact? after = store.insertIfNew(_fact('original'));
      expect(after, isNotNull); // not treated as duplicate after clear
      expect(after!.id, 1);
    });

    // ── Supabase cold-restore simulation ──────────────────────────────────────

    test('cold-start restore: empty → restore from remote → dedupe prevents '
        'double-insert', () {
      // Simulate ChatMemoryRepositoryImpl.getFacts() on web.
      expect(store.loadAll(), isEmpty); // triggers Supabase fetch

      // Simulate restoring 3 facts from Supabase.
      final List<ChatMemoryFact> remote = <ChatMemoryFact>[
        _fact('fact A', at: _t0).copyWith(remoteId: 'remote-a'),
        _fact('fact B', at: _t1).copyWith(remoteId: 'remote-b'),
        _fact('fact C', at: _t2).copyWith(remoteId: 'remote-c'),
      ];

      final List<ChatMemoryFact?> rehydrated =
          remote.map((ChatMemoryFact f) => store.insertIfNew(f)).toList();

      expect(rehydrated.every((ChatMemoryFact? f) => f != null), isTrue);
      expect(store.loadAll(), hasLength(3));

      // A second restore attempt (e.g. provider rebuild) dedupes everything.
      for (final ChatMemoryFact f in remote) {
        expect(
          store.insertIfNew(f),
          isNull,
          reason: '${f.content} should be deduped on second restore',
        );
      }

      expect(store.loadAll(), hasLength(3));
    });

    test('normalize is consistent with SqliteChatMemoryDatasource.normalize',
        () {
      // Both stores must normalize the same way or dedupe breaks cross-device.
      expect(ChatMemoryWebStore.normalize('  Hello World  '), 'hello world');
      expect(ChatMemoryWebStore.normalize('BAYBAYIN'), 'baybayin');
      expect(ChatMemoryWebStore.normalize('multiple   spaces'), 'multiple spaces');
    });
  });
}
