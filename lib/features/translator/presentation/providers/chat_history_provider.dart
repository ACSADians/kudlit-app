// ignore: unnecessary_import — flutter_riverpod is needed for AsyncNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:kudlit_ph/features/translator/data/datasources/sqlite_chat_datasource.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';
import 'package:kudlit_ph/features/translator/presentation/providers/translator_providers.dart';

part 'chat_history_provider.g.dart';

/// Persisted Butty chat history backed by sqflite.
@Riverpod(keepAlive: true)
class ChatHistoryNotifier extends _$ChatHistoryNotifier {
  late final SqliteChatDatasource _datasource;

  @override
  Future<List<ChatMessage>> build() async {
    _datasource = ref.watch(sqliteChatDatasourceProvider);
    return _datasource.loadAll();
  }

  Future<void> addMessage(ChatMessage message) async {
    final ChatMessage saved = await _datasource.insert(message);
    final List<ChatMessage> current = state.value ?? <ChatMessage>[];
    state = AsyncData(<ChatMessage>[...current, saved]);
  }

  Future<void> clearHistory() async {
    await _datasource.clear();
    state = const AsyncData(<ChatMessage>[]);
  }
}
