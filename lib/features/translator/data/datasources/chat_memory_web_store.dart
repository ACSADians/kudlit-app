import 'package:kudlit_ph/features/translator/domain/entities/chat_memory_fact.dart';

/// Pure-Dart in-memory memory-facts store used on web (sqflite unavailable)
/// and in unit tests.
///
/// Deduplication mirrors the SQLite unique index on `normalize(content)`.
/// The Supabase fire-and-forget sync layer wrapping this store is unchanged,
/// so facts survive page refreshes via cloud restore on cold load.
class ChatMemoryWebStore {
  final Map<int, ChatMemoryFact> _facts = <int, ChatMemoryFact>{};
  // normalized content → local id, for O(1) dedupe
  final Map<String, int> _norm = <String, int>{};
  int _nextId = 1;

  List<ChatMemoryFact> loadAll({int? limit}) {
    final List<ChatMemoryFact> sorted = _facts.values.toList()
      ..sort(
        (ChatMemoryFact a, ChatMemoryFact b) =>
            b.createdAt.compareTo(a.createdAt),
      );
    return limit == null
        ? sorted
        : sorted.take(limit).toList(growable: false);
  }

  /// Returns the saved fact with a local id, or null if the content already
  /// exists (case-insensitive, whitespace-normalised dedupe).
  ChatMemoryFact? insertIfNew(ChatMemoryFact fact) {
    final String key = normalize(fact.content);
    if (_norm.containsKey(key)) return null;
    final int id = _nextId++;
    final ChatMemoryFact saved = fact.copyWith(id: id);
    _facts[id] = saved;
    _norm[key] = id;
    return saved;
  }

  void setRemoteId({required int localId, required String remoteId}) {
    final ChatMemoryFact? existing = _facts[localId];
    if (existing != null) {
      _facts[localId] = existing.copyWith(remoteId: remoteId);
    }
  }

  void updateFact({
    required int localId,
    required String factType,
    required String content,
  }) {
    final ChatMemoryFact? existing = _facts[localId];
    if (existing == null) return;
    final String oldKey = normalize(existing.content);
    _norm.remove(oldKey);
    final ChatMemoryFact updated = existing.copyWith(
      factType: factType,
      content: content,
      lastReferencedAt: DateTime.now(),
    );
    _facts[localId] = updated;
    _norm[normalize(content)] = localId;
  }

  ChatMemoryFact? findById(int localId) => _facts[localId];

  void deleteById(int localId) {
    final ChatMemoryFact? existing = _facts.remove(localId);
    if (existing != null) {
      _norm.remove(normalize(existing.content));
    }
  }

  void clear() {
    _facts.clear();
    _norm.clear();
    _nextId = 1;
  }

  static String normalize(String content) =>
      content.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
}
