import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/home/domain/entities/translation_result.dart';

class SqliteTranslationHistoryDatasource {
  SqliteTranslationHistoryDatasource();

  static const String _dbName = 'kudlit_translations.db';
  static const int _dbVersion = 1;
  static const String _table = 'translation_history';

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
            id               INTEGER PRIMARY KEY AUTOINCREMENT,
            input_text       TEXT NOT NULL,
            output_baybayin  TEXT NOT NULL,
            output_latin     TEXT NOT NULL,
            direction        TEXT NOT NULL,
            ai_response      TEXT NOT NULL,
            is_bookmarked    INTEGER NOT NULL DEFAULT 0,
            timestamp        INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<TranslationResult>> loadAll({int? limit}) async {
    try {
      final Database db = await _open();
      final List<Map<String, Object?>> rows = await db.query(
        _table,
        orderBy: 'id DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList(growable: false);
    } catch (e) {
      throw CacheException(message: 'Load translation history failed: $e');
    }
  }

  Future<TranslationResult> insert(TranslationResult result) async {
    try {
      final Database db = await _open();
      final int id = await db.insert(_table, _toRow(result));
      return result.copyWith(id: id);
    } catch (e) {
      throw CacheException(message: 'Save translation result failed: $e');
    }
  }

  Future<void> updateBookmark(int id, bool value) async {
    try {
      final Database db = await _open();
      await db.update(
        _table,
        <String, Object?>{'is_bookmarked': value ? 1 : 0},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    } catch (e) {
      throw CacheException(message: 'Update bookmark failed: $e');
    }
  }

  Future<void> updateAiResponse(int id, String aiResponse) async {
    try {
      final Database db = await _open();
      await db.update(
        _table,
        <String, Object?>{'ai_response': aiResponse},
        where: 'id = ?',
        whereArgs: <Object?>[id],
      );
    } catch (e) {
      throw CacheException(message: 'Update AI response failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      final Database db = await _open();
      await db.delete(_table);
    } catch (e) {
      throw CacheException(message: 'Clear translation history failed: $e');
    }
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  // ─── Mappers ──────────────────────────────────────────────────────────────

  Map<String, Object?> _toRow(TranslationResult r) {
    return <String, Object?>{
      'input_text': r.inputText,
      'output_baybayin': r.baybayinText,
      'output_latin': r.latinText,
      'direction': r.direction,
      'ai_response': r.aiResponse,
      'is_bookmarked': r.isBookmarked ? 1 : 0,
      'timestamp': r.timestamp.millisecondsSinceEpoch,
    };
  }

  TranslationResult _fromRow(Map<String, Object?> row) {
    return TranslationResult(
      id: row['id'] as int?,
      inputText: row['input_text'] as String,
      baybayinText: row['output_baybayin'] as String,
      latinText: row['output_latin'] as String,
      direction: row['direction'] as String,
      aiResponse: row['ai_response'] as String,
      isBookmarked: (row['is_bookmarked'] as int) == 1,
      timestamp: DateTime.fromMillisecondsSinceEpoch(row['timestamp'] as int),
    );
  }
}
