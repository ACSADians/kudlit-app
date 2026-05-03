import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/translator/domain/entities/chat_message.dart';

/// SQLite-backed chat history store.
///
/// Schema:
/// ```sql
/// CREATE TABLE chat_messages (
///   id INTEGER PRIMARY KEY AUTOINCREMENT,
///   text TEXT NOT NULL,
///   is_user INTEGER NOT NULL,
///   timestamp INTEGER NOT NULL  -- epoch millis
/// );
/// ```
class SqliteChatDatasource {
  SqliteChatDatasource();

  static const String _dbName = 'kudlit_chat.db';
  static const int _dbVersion = 1;
  static const String _table = 'chat_messages';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final String dbPath = p.join(await getDatabasesPath(), _dbName);
    _db = await openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            text TEXT NOT NULL,
            is_user INTEGER NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<ChatMessage>> loadAll({int? limit}) async {
    try {
      final Database db = await _open();
      final List<Map<String, Object?>> rows = await db.query(
        _table,
        orderBy: 'id ASC',
        limit: limit,
      );
      return rows.map(_fromRow).toList(growable: false);
    } catch (e) {
      throw CacheException(message: 'Load chat history failed: $e');
    }
  }

  Future<ChatMessage> insert(ChatMessage message) async {
    try {
      final Database db = await _open();
      final int id = await db.insert(_table, _toRow(message));
      return message.copyWith(id: id);
    } catch (e) {
      throw CacheException(message: 'Save message failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      final Database db = await _open();
      await db.delete(_table);
    } catch (e) {
      throw CacheException(message: 'Clear chat history failed: $e');
    }
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  // ─── Mappers ──────────────────────────────────────────────────────────────

  Map<String, Object?> _toRow(ChatMessage m) {
    return <String, Object?>{
      'text': m.text,
      'is_user': m.isUser ? 1 : 0,
      'timestamp': m.timestamp.millisecondsSinceEpoch,
    };
  }

  ChatMessage _fromRow(Map<String, Object?> row) {
    return ChatMessage(
      id: row['id'] as int?,
      text: row['text'] as String,
      isUser: (row['is_user'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    );
  }
}
