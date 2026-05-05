import 'package:kudlit_ph/features/translator/domain/entities/chat_memory_fact.dart';

/// Long-term semantic memory of the Butty chat.
abstract class ChatMemoryRepository {
  /// All known facts, most recent first.
  Future<List<ChatMemoryFact>> getFacts({int? limit});

  /// Adds new facts and dedupes against existing entries (case-insensitive
  /// content match). Returns the resulting persisted list.
  Future<List<ChatMemoryFact>> addFacts(List<ChatMemoryFact> facts);

  /// Replaces the content/type of an existing fact (matched by local id).
  /// Returns the updated list.
  Future<List<ChatMemoryFact>> updateFact(ChatMemoryFact fact);

  /// Removes a single fact (matched by local id) from local cache and
  /// Supabase. Returns the updated list.
  Future<List<ChatMemoryFact>> removeFact(int id);

  /// Wipes all memory facts for the active user. The "Start fresh" UX in the
  /// chat does NOT call this — it preserves memory by design.
  Future<void> clearAll();
}
