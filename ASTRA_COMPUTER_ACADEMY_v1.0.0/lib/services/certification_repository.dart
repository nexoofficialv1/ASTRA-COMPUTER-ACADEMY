import 'dart:convert';
import 'dart:math';
import 'package:sqflite/sqflite.dart';
import '../data/app_database.dart';

class CertificateRecord {
  const CertificateRecord({
    required this.verificationId,
    required this.learnerName,
    required this.certificateTitle,
    required this.finalScore,
    required this.issuedAt,
  });

  final String verificationId;
  final String learnerName;
  final String certificateTitle;
  final int finalScore;
  final DateTime issuedAt;
}

class CertificationRepository {
  CertificationRepository(this._appDatabase);

  final AppDatabase _appDatabase;

  Future<void> recordFinalExam({
    required int score,
    required bool passed,
    required Map<String, int> componentScores,
  }) async {
    final db = await _appDatabase.database;
    await db.insert('final_exam_attempt', {
      'score': score,
      'passed': passed ? 1 : 0,
      'component_json': jsonEncode(componentScores),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> getBestFinalExamScore() async {
    final db = await _appDatabase.database;
    final rows = await db.rawQuery(
      'SELECT MAX(score) AS best_score FROM final_exam_attempt WHERE passed = 1',
    );
    if (rows.isEmpty || rows.first['best_score'] == null) return 0;
    return (rows.first['best_score'] as num).round();
  }

  Future<CertificateRecord?> getLatestCertificate() async {
    final db = await _appDatabase.database;
    final rows = await db.query(
      'certificate',
      orderBy: 'issued_at DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  Future<CertificateRecord> issueCertificate({
    required String learnerName,
    required int finalScore,
    required Map<String, dynamic> snapshot,
  }) async {
    final existing = await getLatestCertificate();
    if (existing != null && existing.learnerName == learnerName) {
      return existing;
    }

    final db = await _appDatabase.database;
    final now = DateTime.now();
    final verificationId = _generateVerificationId(now);
    const title = 'Basic Computer & Office Skills - Foundation';

    await db.insert(
      'certificate',
      {
        'verification_id': verificationId,
        'learner_name': learnerName,
        'certificate_title': title,
        'final_score': finalScore,
        'snapshot_json': jsonEncode(snapshot),
        'issued_at': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );

    return CertificateRecord(
      verificationId: verificationId,
      learnerName: learnerName,
      certificateTitle: title,
      finalScore: finalScore,
      issuedAt: now,
    );
  }

  String _generateVerificationId(DateTime now) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    final suffix = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    final date = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return 'ASTRA-BCC-$date-$suffix';
  }

  CertificateRecord _fromRow(Map<String, Object?> row) {
    return CertificateRecord(
      verificationId: row['verification_id'] as String,
      learnerName: row['learner_name'] as String,
      certificateTitle: row['certificate_title'] as String,
      finalScore: row['final_score'] as int,
      issuedAt: DateTime.parse(row['issued_at'] as String),
    );
  }
}
