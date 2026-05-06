import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// Pure-Dart in-memory chat history store used on web (sqflite unavailable)
/// and in unit tests.
///
/// Mirrors the SQLite schema contract: insert gives each message a local
/// integer id, setRemoteId back-fills the Supabase UUID, clear resets
/// everything. The Supabase fire-and-forget sync layer wrapping this store
/// is unchanged, so cross-session history restores from Supabase on cold load.
class ChatHistoryWebStore {
  final List<ChatMessage> _messages = <ChatMessage>[];
  int _nextId = 1;

  List<ChatMessage> loadAll({int? limit}) {
    final List<ChatMessage> all = List<ChatMessage>.from(_messages);
    return limit == null ? all : all.take(limit).toList(growable: false);
  }

  List<ChatMessage> loadRecent({required int limit}) {
    return _messages.length <= limit
        ? List<ChatMessage>.from(_messages)
        : List<ChatMessage>.from(
            _messages.sublist(_messages.length - limit),
          );
  }

  ChatMessage insert(ChatMessage message) {
    final ChatMessage saved = message.copyWith(id: _nextId++);
    _messages.add(saved);
    return saved;
  }

  void setRemoteId({required int localId, required String remoteId}) {
    final int idx = _messages.indexWhere((ChatMessage m) => m.id == localId);
    if (idx >= 0) {
      _messages[idx] = _messages[idx].copyWith(remoteId: remoteId);
    }
  }

  void clear() {
    _messages.clear();
    _nextId = 1;
  }
}
