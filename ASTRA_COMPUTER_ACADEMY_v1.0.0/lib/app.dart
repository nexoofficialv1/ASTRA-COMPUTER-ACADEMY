import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'services/backup_restore_service.dart';
import 'services/certification_repository.dart';
import 'services/content_repository.dart';
import 'services/learner_profile_repository.dart';
import 'services/progress_repository.dart';

class AstraComputerAcademyApp extends StatelessWidget {
  const AstraComputerAcademyApp({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
    required this.profileRepository,
    required this.certificationRepository,
    required this.backupRestoreService,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final LearnerProfileRepository profileRepository;
  final CertificationRepository certificationRepository;
  final BackupRestoreService backupRestoreService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Astra Computer Academy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: _SplashGate(
        destination: HomeScreen(
          contentRepository: contentRepository,
          progressRepository: progressRepository,
          profileRepository: profileRepository,
          certificationRepository: certificationRepository,
          backupRestoreService: backupRestoreService,
        ),
      ),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate({required this.destination});

  final Widget destination;

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      child: _ready ? widget.destination : const SplashScreen(),
    );
  }
}
