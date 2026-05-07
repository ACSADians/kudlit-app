import 'package:meta/meta.dart';

/// A distilled fact that Butty has learned about the user from chat history.
///
/// Persisted both in SQLite (for offline access) and Supabase (for cross-
/// device continuity). Injected into the system prompt before each Gemma
/// inference so the model has long-term context without needing the full
/// transcript.
@immutable
class ChatMemoryFact {
  const ChatMemoryFact({
    this.id,
    this.remoteId,
    required this.factType,
    required this.content,
    required this.createdAt,
    required this.lastReferencedAt,
  });

  /// Local SQLite primary key. Null when not yet persisted.
  final int? id;

  /// Supabase row UUID. Null until cloud sync succeeds.
  final String? remoteId;

  /// Free-form tag — `preference`, `topic`, `personal`, `skill`, `general`.
  final String factType;

  /// One-sentence fact. Example: "Prefers Tagalog explanations over English."
  final String content;

  final DateTime createdAt;

  /// Bumped when the fact is reused in a prompt — lets us evict stale facts.
  final DateTime lastReferencedAt;

  ChatMemoryFact copyWith({
    int? id,
    String? remoteId,
    String? factType,
    String? content,
    DateTime? createdAt,
    DateTime? lastReferencedAt,
  }) {
    return ChatMemoryFact(
      id: id ?? this.id,
      remoteId: remoteId ?? this.remoteId,
      factType: factType ?? this.factType,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      lastReferencedAt: lastReferencedAt ?? this.lastReferencedAt,
    );
  }
}
