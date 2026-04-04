import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'focus_stats.dart';

class StatsRepository {
  static const String _dbName = 'focusguard.db';
  static const String _statsTable = 'focus_stats';
  static const int _statsRowId = 1;

  Database? _database;

  Future<Database> _getDatabase() async {
    if (_database != null) {
      return _database!;
    }

    final String databasesPath = await getDatabasesPath();
    final String dbPath = p.join(databasesPath, _dbName);

    _database = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $_statsTable (
            id INTEGER PRIMARY KEY,
            total_sessions INTEGER NOT NULL,
            total_focus_seconds INTEGER NOT NULL,
            current_combo INTEGER NOT NULL,
            best_combo INTEGER NOT NULL
          )
        ''');

        await db.insert(_statsTable, {
          'id': _statsRowId,
          'total_sessions': 0,
          'total_focus_seconds': 0,
          'current_combo': 0,
          'best_combo': 0,
        });
      },
    );

    return _database!;
  }

  Future<FocusStats> loadStats() async {
    final Database db = await _getDatabase();
    final List<Map<String, Object?>> rows = await db.query(
      _statsTable,
      where: 'id = ?',
      whereArgs: [_statsRowId],
      limit: 1,
    );

    if (rows.isEmpty) {
      await db.insert(_statsTable, {
        'id': _statsRowId,
        'total_sessions': 0,
        'total_focus_seconds': 0,
        'current_combo': 0,
        'best_combo': 0,
      });

      return FocusStats.initial();
    }

    return FocusStats(
      totalSessions: rows.first['total_sessions'] as int? ?? 0,
      totalFocusSeconds: rows.first['total_focus_seconds'] as int? ?? 0,
      currentCombo: rows.first['current_combo'] as int? ?? 0,
      bestCombo: rows.first['best_combo'] as int? ?? 0,
    );
  }

  Future<void> saveStats(FocusStats stats) async {
    final Database db = await _getDatabase();

    await db.update(
      _statsTable,
      {
        'total_sessions': stats.totalSessions,
        'total_focus_seconds': stats.totalFocusSeconds,
        'current_combo': stats.currentCombo,
        'best_combo': stats.bestCombo,
      },
      where: 'id = ?',
      whereArgs: [_statsRowId],
    );
  }
}
