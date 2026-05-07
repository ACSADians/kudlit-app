import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:kudlit_ph/features/translator/data/datasources/sqlite_chat_memory_datasource.dart';
import 'package:kudlit_ph/features/translator/data/datasources/supabase_chat_memory_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_memory_fact.dart';
import 'package:kudlit_ph/features/translator/domain/repositories/chat_memory_repository.dart';

/// Cache-first chat memory repository.
///
/// Mirrors the read-cache + write-through pattern of
/// [ProfileManagementRepositoryImpl]. SQLite is the source of truth for
/// reads; Supabase is fire-and-forget on writes and used as a fallback when
/// the local store is empty (cold install).
class ChatMemoryRepositoryImpl implements ChatMemoryRepository {
  ChatMemoryRepositoryImpl({
    required SqliteChatMemoryDatasource local,
    required SupabaseChatMemoryDatasource remote,
  }) : _local = local,
       _remote = remote;

  final SqliteChatMemoryDatasource _local;
  final SupabaseChatMemoryDatasource _remote;

  @override
  Future<List<ChatMemoryFact>> getFacts({int? limit}) async {
    final List<ChatMemoryFact> local = await _local.loadAll(limit: limit);
    if (local.isNotEmpty) return local;

    // Cold-start restore from Supabase.
    final List<ChatMemoryFact> remote = await _remote.fetchAll();
    if (remote.isEmpty) return local;
    final List<ChatMemoryFact> rehydrated = <ChatMemoryFact>[];
    for (final ChatMemoryFact f in remote) {
      try {
        final ChatMemoryFact? saved = await _local.insertIfNew(f);
        if (saved != null) rehydrated.add(saved);
      } catch (e) {
        debugPrint('[ChatMemory] cloud→local rehydrate failed: $e');
      }
    }
    return _local.loadAll(limit: limit);
  }

  @override
  Future<List<ChatMemoryFact>> addFacts(List<ChatMemoryFact> facts) async {
    for (final ChatMemoryFact f in facts) {
      try {
        final ChatMemoryFact? saved = await _local.insertIfNew(f);
        if (saved == null) continue; // duplicate — skip cloud sync too
        unawaited(_syncFact(saved));
      } catch (e) {
        debugPrint('[ChatMemory] insert failed (non-fatal): $e');
      }
    }
    return _local.loadAll();
  }

  @override
  Future<List<ChatMemoryFact>> updateFact(ChatMemoryFact fact) async {
    if (fact.id == null) return _local.loadAll();
    await _local.updateFact(
      localId: fact.id!,
      factType: fact.factType,
      content: fact.content,
    );
    if (fact.remoteId != null) {
      unawaited(
        _remote.updateByRemoteId(
          remoteId: fact.remoteId!,
          factType: fact.factType,
          content: fact.content,
        ),
      );
    }
    return _local.loadAll();
  }

  @override
  Future<List<ChatMemoryFact>> removeFact(int id) async {
    final ChatMemoryFact? existing = await _local.findById(id);
    await _local.deleteById(id);
    if (existing?.remoteId != null) {
      unawaited(_remote.deleteByRemoteId(existing!.remoteId!));
    }
    return _local.loadAll();
  }

  @override
  Future<void> clearAll() async {
    await _local.clear();
    unawaited(_remote.deleteAllForCurrentUser());
  }

  Future<void> _syncFact(ChatMemoryFact saved) async {
    final String? remoteId = await _remote.insert(saved);
    if (remoteId == null || saved.id == null) return;
    try {
      await _local.setRemoteId(localId: saved.id!, remoteId: remoteId);
    } catch (e) {
      debugPrint('[ChatMemory] remote_id back-fill failed (non-fatal): $e');
    }
  }
}
