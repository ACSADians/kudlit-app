import 'package:test/test.dart';

import 'package:kudlit_ph/features/translator/data/datasources/chat_history_web_store.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

// Tests for ChatHistoryWebStore — the pure-Dart in-memory store used by
// SqliteChatDatasource when running on web (kIsWeb) or in unit tests
// (SqliteChatDatasource.inMemory()). These tests verify the same contract
// that ChatHistoryNotifier relies on: empty-on-cold-start → Supabase restore
// → write-through of new messages.

ChatMessage _msg(String text, {bool isUser = true}) => ChatMessage(
  text: text,
  isUser: isUser,
  timestamp: DateTime(2026),
);

void main() {
  group('ChatHistoryWebStore', () {
    late ChatHistoryWebStore store;

    setUp(() => store = ChatHistoryWebStore());

    // ── loadAll ───────────────────────────────────────────────────────────────

    test('loadAll returns empty list on cold start', () {
      expect(store.loadAll(), isEmpty);
    });

    test('loadAll returns inserted messages in insertion order', () {
      store.insert(_msg('first'));
      store.insert(_msg('second'));
      store.insert(_msg('third'));

      expect(
        store.loadAll().map((ChatMessage m) => m.text),
        <String>['first', 'second', 'third'],
      );
    });

    test('loadAll respects limit parameter', () {
      for (int i = 0; i < 5; i++) {
        store.insert(_msg('msg$i'));
      }
      final List<ChatMessage> result = store.loadAll(limit: 3);
      expect(result, hasLength(3));
      expect(result.first.text, 'msg0');
    });

    // ── insert ────────────────────────────────────────────────────────────────

    test('insert returns message with a non-null id', () {
      final ChatMessage saved = store.insert(_msg('hello'));
      expect(saved.id, isNotNull);
      expect(saved.text, 'hello');
    });

    test('insert assigns incrementing ids', () {
      final ChatMessage a = store.insert(_msg('a'));
      final ChatMessage b = store.insert(_msg('b'));
      expect(b.id, greaterThan(a.id!));
    });

    test('insert preserves isUser flag', () {
      final ChatMessage user = store.insert(_msg('user', isUser: true));
      final ChatMessage bot = store.insert(_msg('bot', isUser: false));
      expect(user.isUser, isTrue);
      expect(bot.isUser, isFalse);
    });

    // ── loadRecent ────────────────────────────────────────────────────────────

    test('loadRecent returns last N messages in chronological order', () {
      for (int i = 0; i < 5; i++) {
        store.insert(_msg('msg$i'));
      }
      final List<ChatMessage> recent = store.loadRecent(limit: 3);
      expect(recent, hasLength(3));
      expect(
        recent.map((ChatMessage m) => m.text),
        <String>['msg2', 'msg3', 'msg4'],
      );
    });

    test('loadRecent returns all messages when fewer than limit exist', () {
      store.insert(_msg('only'));
      expect(store.loadRecent(limit: 10), hasLength(1));
    });

    // ── setRemoteId ───────────────────────────────────────────────────────────

    test('setRemoteId updates remoteId for a matching message', () {
      final ChatMessage saved = store.insert(_msg('sync me'));
      store.setRemoteId(localId: saved.id!, remoteId: 'uuid-abc');

      expect(store.loadAll().first.remoteId, 'uuid-abc');
    });

    test('setRemoteId is no-op when localId does not exist', () {
      store.insert(_msg('message'));
      store.setRemoteId(localId: 9999, remoteId: 'orphan-uuid');

      expect(store.loadAll().first.remoteId, isNull);
    });

    // ── clear ─────────────────────────────────────────────────────────────────

    test('clear removes all messages', () {
      store.insert(_msg('a'));
      store.insert(_msg('b'));
      store.clear();

      expect(store.loadAll(), isEmpty);
    });

    test('insert after clear restarts from id 1', () {
      store.insert(_msg('before'));
      store.clear();
      final ChatMessage after = store.insert(_msg('after'));
      expect(after.id, 1);
    });

    // ── Supabase cold-restore simulation ──────────────────────────────────────

    test('cold-start restore: empty → insert remote messages → loadAll works',
        () {
      // Simulate ChatHistoryNotifier.build() on web.
      expect(store.loadAll(), isEmpty); // empty → triggers Supabase fetch

      // Simulate rehydration from Supabase.
      final List<ChatMessage> remote = <ChatMessage>[
        _msg('restored 1', isUser: true),
        _msg('restored 2', isUser: false),
      ];
      final List<ChatMessage> rehydrated = remote
          .map((ChatMessage m) => store.insert(m))
          .toList();

      expect(rehydrated.every((ChatMessage m) => m.id != null), isTrue);

      // All messages visible after restore.
      expect(
        store.loadAll().map((ChatMessage m) => m.text),
        <String>['restored 1', 'restored 2'],
      );
    });

    test('new messages after restore get sequential ids', () {
      store.insert(_msg('restored'));
      final ChatMessage newMsg = store.insert(_msg('new'));
      expect(newMsg.id, 2);
    });
  });
}
