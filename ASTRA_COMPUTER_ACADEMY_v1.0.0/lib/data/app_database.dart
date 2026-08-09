import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'astra_computer_academy.db');

    _database = await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await _createV1(db);
        await _createPracticeAttempts(db);
        await _upgradeToV3(db, freshDatabase: true);
        await _upgradeToV4(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createPracticeAttempts(db);
        }
        if (oldVersion < 3) {
          await _upgradeToV3(db, freshDatabase: false);
        }
        if (oldVersion < 4) {
          await _upgradeToV4(db);
        }
      },
    );

    return _database!;
  }

  Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE lesson_progress (
        lesson_id TEXT PRIMARY KEY,
        completed INTEGER NOT NULL DEFAULT 0,
        best_score INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE learner_profile (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        name TEXT NOT NULL,
        education TEXT,
        goal TEXT,
        preferred_language TEXT NOT NULL DEFAULT 'bn'
      )
    ''');
  }

  Future<void> _createPracticeAttempts(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS practice_attempt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lesson_id TEXT NOT NULL,
        practical_kind TEXT NOT NULL,
        score INTEGER NOT NULL,
        metric_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_practice_attempt_lesson ON practice_attempt(lesson_id)',
    );
  }

  Future<void> _upgradeToV3(
    Database db, {
    required bool freshDatabase,
  }) async {
    if (!freshDatabase) {
      final columns = await db.rawQuery('PRAGMA table_info(learner_profile)');
      final names = columns.map((row) => row['name'] as String).toSet();
      if (!names.contains('phone')) {
        await db.execute('ALTER TABLE learner_profile ADD COLUMN phone TEXT');
      }
      if (!names.contains('created_at')) {
        await db.execute('ALTER TABLE learner_profile ADD COLUMN created_at TEXT');
      }
      if (!names.contains('updated_at')) {
        await db.execute('ALTER TABLE learner_profile ADD COLUMN updated_at TEXT');
      }
    } else {
      await db.execute('ALTER TABLE learner_profile ADD COLUMN phone TEXT');
      await db.execute('ALTER TABLE learner_profile ADD COLUMN created_at TEXT');
      await db.execute('ALTER TABLE learner_profile ADD COLUMN updated_at TEXT');
    }

    await db.execute('''
      CREATE TABLE IF NOT EXISTS learning_activity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        activity_type TEXT NOT NULL,
        reference_id TEXT,
        activity_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_learning_activity_date ON learning_activity(activity_date)',
    );

    await db.execute('''
      CREATE TABLE IF NOT EXISTS final_exam_attempt (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        score INTEGER NOT NULL,
        passed INTEGER NOT NULL,
        component_json TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS certificate (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        verification_id TEXT NOT NULL UNIQUE,
        learner_name TEXT NOT NULL,
        certificate_title TEXT NOT NULL,
        final_score INTEGER NOT NULL,
        snapshot_json TEXT NOT NULL,
        issued_at TEXT NOT NULL
      )
    ''');
  }
  Future<void> _upgradeToV4(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS backup_restore_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action TEXT NOT NULL,
        record_count INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

}
