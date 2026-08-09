import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';

class LessonProgress {
  const LessonProgress({
    required this.completed,
    required this.bestScore,
  });

  final bool completed;
  final int bestScore;
}

class LearningActivityStats {
  const LearningActivityStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
  });

  final int currentStreak;
  final int longestStreak;
  final int activeDays;
}

class ProgressRepository {
  ProgressRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<Map<String, LessonProgress>> getAllProgress() async {
    final db = await _appDatabase.database;
    final rows = await db.query('lesson_progress');

    return {
      for (final row in rows)
        row['lesson_id'] as String: LessonProgress(
          completed: (row['completed'] as int) == 1,
          bestScore: row['best_score'] as int,
        ),
    };
  }

  Future<Map<String, int>> getBestPracticeScores() async {
    final db = await _appDatabase.database;
    final rows = await db.rawQuery('''
      SELECT lesson_id, MAX(score) AS best_score
      FROM practice_attempt
      GROUP BY lesson_id
    ''');
    return {
      for (final row in rows)
        row['lesson_id'] as String: (row['best_score'] as num).round(),
    };
  }

  Future<void> markCompleted(String lessonId, {int score = 0}) async {
    final db = await _appDatabase.database;
    final current = await db.query(
      'lesson_progress',
      where: 'lesson_id = ?',
      whereArgs: [lessonId],
      limit: 1,
    );

    final oldScore = current.isEmpty ? 0 : current.first['best_score'] as int;
    final bestScore = score > oldScore ? score : oldScore;

    await db.insert(
      'lesson_progress',
      {
        'lesson_id': lessonId,
        'completed': 1,
        'best_score': bestScore,
        'updated_at': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    await _recordActivity('lesson', lessonId);
  }

  Future<void> recordPracticeAttempt({
    required String lessonId,
    required String practicalKind,
    required int score,
    required Map<String, dynamic> metrics,
  }) async {
    final db = await _appDatabase.database;
    await db.insert('practice_attempt', {
      'lesson_id': lessonId,
      'practical_kind': practicalKind,
      'score': score,
      'metric_json': jsonEncode(metrics),
      'created_at': DateTime.now().toIso8601String(),
    });
    await markCompleted(lessonId, score: score);
    await _recordActivity('practice', lessonId);
  }

  Future<LearningActivityStats> getActivityStats() async {
    final db = await _appDatabase.database;
    final rows = await db.rawQuery('''
      SELECT DISTINCT activity_date
      FROM learning_activity
      ORDER BY activity_date ASC
    ''');
    final dates = rows
        .map((row) => DateTime.tryParse(row['activity_date'] as String))
        .whereType<DateTime>()
        .map((date) => DateTime(date.year, date.month, date.day))
        .toList();

    if (dates.isEmpty) {
      return const LearningActivityStats(
        currentStreak: 0,
        longestStreak: 0,
        activeDays: 0,
      );
    }

    var longest = 1;
    var running = 1;
    for (var i = 1; i < dates.length; i++) {
      if (dates[i].difference(dates[i - 1]).inDays == 1) {
        running += 1;
        if (running > longest) longest = running;
      } else {
        running = 1;
      }
    }

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    final last = dates.last;
    var current = 0;
    if (todayOnly.difference(last).inDays <= 1) {
      current = 1;
      for (var i = dates.length - 1; i > 0; i--) {
        if (dates[i].difference(dates[i - 1]).inDays == 1) {
          current += 1;
        } else {
          break;
        }
      }
    }

    return LearningActivityStats(
      currentStreak: current,
      longestStreak: longest,
      activeDays: dates.length,
    );
  }

  Future<void> _recordActivity(String type, String referenceId) async {
    final db = await _appDatabase.database;
    final now = DateTime.now();
    final day = '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    await db.insert('learning_activity', {
      'activity_type': type,
      'reference_id': referenceId,
      'activity_date': day,
      'created_at': now.toIso8601String(),
    });
  }
}
