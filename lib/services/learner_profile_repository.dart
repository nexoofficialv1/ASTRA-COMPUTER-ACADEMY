import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';
import '../models/learner_profile.dart';

class LearnerProfileRepository {
  LearnerProfileRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<LearnerProfile?> getProfile() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'learner_profile',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final row = rows.first;
    return LearnerProfile(
      name: row['name'] as String? ?? '',
      education: row['education'] as String? ?? '',
      goal: row['goal'] as String? ?? '',
      preferredLanguage: row['preferred_language'] as String? ?? 'bn',
      phone: row['phone'] as String?,
    );
  }

  Future<void> saveProfile(LearnerProfile profile) async {
    final db = await _appDatabase.database;
    final current = await db.query(
      'learner_profile',
      columns: ['created_at'],
      where: 'id = 1',
      limit: 1,
    );
    final now = DateTime.now().toIso8601String();
    final createdAt = current.isNotEmpty
        ? current.first['created_at'] as String? ?? now
        : now;

    await db.insert(
      'learner_profile',
      {
        'id': 1,
        'name': profile.name.trim(),
        'education': profile.education.trim(),
        'goal': profile.goal.trim(),
        'preferred_language': profile.preferredLanguage,
        'phone': profile.phone?.trim(),
        'created_at': createdAt,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
