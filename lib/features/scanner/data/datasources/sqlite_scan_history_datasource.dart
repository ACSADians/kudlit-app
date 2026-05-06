import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'package:kudlit_ph/core/error/exceptions.dart';
import 'package:kudlit_ph/features/scanner/domain/entities/scan_result.dart';

/// SQLite-backed scan result history store.
///
/// Schema:
/// ```sql
/// CREATE TABLE scan_history (
///   id INTEGER PRIMARY KEY AUTOINCREMENT,
///   tokens TEXT NOT NULL,       -- JSON array of YOLO label strings
///   translation TEXT NOT NULL,  -- Butty's full response
///   timestamp INTEGER NOT NULL  -- epoch millis
/// );
/// ```
class SqliteScanHistoryDatasource {
  SqliteScanHistoryDatasource();

  static const String _dbName = 'kudlit_scan.db';
  static const int _dbVersion = 1;
  static const String _table = 'scan_history';

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
            tokens TEXT NOT NULL,
            translation TEXT NOT NULL,
            timestamp INTEGER NOT NULL
          )
        ''');
      },
    );
    return _db!;
  }

  Future<List<ScanResult>> loadAll({int? limit}) async {
    try {
      final Database db = await _open();
      final List<Map<String, Object?>> rows = await db.query(
        _table,
        orderBy: 'id DESC',
        limit: limit,
      );
      return rows.map(_fromRow).toList(growable: false);
    } catch (e) {
      throw CacheException(message: 'Load scan history failed: $e');
    }
  }

  Future<ScanResult> insert(ScanResult result) async {
    try {
      final Database db = await _open();
      final int id = await db.insert(_table, _toRow(result));
      return result.copyWith(id: id);
    } catch (e) {
      throw CacheException(message: 'Save scan result failed: $e');
    }
  }

  Future<void> clear() async {
    try {
      final Database db = await _open();
      await db.delete(_table);
    } catch (e) {
      throw CacheException(message: 'Clear scan history failed: $e');
    }
  }

  Future<void> dispose() async {
    await _db?.close();
    _db = null;
  }

  // ─── Mappers ──────────────────────────────────────────────────────────────

  Map<String, Object?> _toRow(ScanResult r) {
    return <String, Object?>{
      'tokens': jsonEncode(r.tokens),
      'translation': r.translation,
      'timestamp': r.timestamp.millisecondsSinceEpoch,
    };
  }

  ScanResult _fromRow(Map<String, Object?> row) {
    final List<dynamic> decoded =
        jsonDecode(row['tokens'] as String) as List<dynamic>;
    return ScanResult(
      id: row['id'] as int?,
      tokens: decoded.cast<String>(),
      translation: row['translation'] as String,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        row['timestamp'] as int,
      ),
    );
  }
}
