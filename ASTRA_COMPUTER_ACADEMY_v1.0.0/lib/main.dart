import 'package:flutter/material.dart';
import 'app.dart';
import 'data/app_database.dart';
import 'services/backup_restore_service.dart';
import 'services/certification_repository.dart';
import 'services/content_repository.dart';
import 'services/learner_profile_repository.dart';
import 'services/progress_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  await database.database;

  final contentRepository = ContentRepository();
  final progressRepository = ProgressRepository(database);
  final profileRepository = LearnerProfileRepository(database);
  final certificationRepository = CertificationRepository(database);
  final backupRestoreService = BackupRestoreService(database);

  runApp(
    AstraComputerAcademyApp(
      contentRepository: contentRepository,
      progressRepository: progressRepository,
      profileRepository: profileRepository,
      certificationRepository: certificationRepository,
      backupRestoreService: backupRestoreService,
    ),
  );
}
