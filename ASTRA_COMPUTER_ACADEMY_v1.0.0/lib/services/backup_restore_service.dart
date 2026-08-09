import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';

class RestoreResult {
  const RestoreResult({
    required this.restoredRecords,
    required this.sourceVersion,
  });

  final int restoredRecords;
  final int sourceVersion;
}

class BackupRestoreService {
  BackupRestoreService(this._appDatabase);

  final AppDatabase _appDatabase;

  static const _schema = 'astra_offline_backup_v1';
  static const _tables = <String>[
    'learner_profile',
    'lesson_progress',
    'practice_attempt',
    'learning_activity',
    'final_exam_attempt',
    'certificate',
  ];

  Future<String> exportBackup() async {
    final db = await _appDatabase.database;
    final data = <String, dynamic>{};
    var count = 0;

    for (final table in _tables) {
      final rows = await db.query(table);
      data[table] = rows;
      count += rows.length;
    }

    final payload = <String, dynamic>{
      'schema': _schema,
      'appVersion': 6,
      'exportedAt': DateTime.now().toIso8601String(),
      'recordCount': count,
      'tables': data,
    };

    await db.insert('backup_restore_log', {
      'action': 'export',
      'record_count': count,
      'created_at': DateTime.now().toIso8601String(),
    });

    return const JsonEncoder.withIndent('  ').convert(payload);
  }

  Future<RestoreResult> restoreBackup(String rawJson) async {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Backup file is not a valid JSON object.');
    }
    if (decoded['schema'] != _schema) {
      throw const FormatException('Unsupported backup schema.');
    }

    final tables = decoded['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException('Backup tables are missing.');
    }

    final db = await _appDatabase.database;
    var restored = 0;

    await db.transaction((txn) async {
      for (final table in _tables.reversed) {
        await txn.delete(table);
      }

      for (final table in _tables) {
        final rows = tables[table];
        if (rows == null) continue;
        if (rows is! List) {
          throw FormatException('Invalid rows for $table.');
        }
        for (final rawRow in rows) {
          if (rawRow is! Map) {
            throw FormatException('Invalid record in $table.');
          }
          final row = <String, Object?>{};
          rawRow.forEach((key, value) {
            row[key.toString()] = value;
          });
          await txn.insert(
            table,
            row,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
          restored += 1;
        }
      }

      await txn.insert('backup_restore_log', {
        'action': 'restore',
        'record_count': restored,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    return RestoreResult(
      restoredRecords: restored,
      sourceVersion: (decoded['appVersion'] as num?)?.round() ?? 0,
    );
  }
}
