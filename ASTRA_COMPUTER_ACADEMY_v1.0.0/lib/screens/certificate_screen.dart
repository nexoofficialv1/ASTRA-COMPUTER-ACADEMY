import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import '../models/course.dart';
import '../models/learner_profile.dart';
import '../services/certificate_export_service.dart';
import '../services/certificate_pdf_service.dart';
import '../services/certification_repository.dart';
import '../services/content_repository.dart';
import '../services/learner_profile_repository.dart';
import '../services/progress_repository.dart';

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({
    super.key,
    required this.contentRepository,
    required this.progressRepository,
    required this.profileRepository,
    required this.certificationRepository,
  });

  final ContentRepository contentRepository;
  final ProgressRepository progressRepository;
  final LearnerProfileRepository profileRepository;
  final CertificationRepository certificationRepository;

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen> {
  final GlobalKey _certificateBoundaryKey = GlobalKey();
  bool _loading = true;
  bool _issuing = false;
  bool _exportingPdf = false;
  LearnerProfile? _profile;
  CertificateRecord? _certificate;
  int _totalLessons = 0;
  int _completedLessons = 0;
  int _finalExamScore = 0;

  bool get _eligible =>
      _profile?.isComplete == true &&
      _totalLessons > 0 &&
      _completedLessons == _totalLessons &&
      _finalExamScore >= 70;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final results = await Future.wait<dynamic>([
      widget.contentRepository.loadCourses(),
      widget.progressRepository.getAllProgress(),
      widget.profileRepository.getProfile(),
      widget.certificationRepository.getBestFinalExamScore(),
      widget.certificationRepository.getLatestCertificate(),
    ]);
    final courses = results[0] as List<Course>;
    final progress = results[1] as Map<String, LessonProgress>;
    final lessons = courses.expand((course) => course.lessons).toList();
    if (!mounted) return;
    setState(() {
      _totalLessons = lessons.length;
      _completedLessons = lessons
          .where((lesson) => progress[lesson.id]?.completed == true)
          .length;
      _profile = results[2] as LearnerProfile?;
      _finalExamScore = results[3] as int;
      _certificate = results[4] as CertificateRecord?;
      _loading = false;
    });
  }

  Future<void> _issue() async {
    if (!_eligible || _profile == null) return;
    setState(() => _issuing = true);
    final certificate = await widget.certificationRepository.issueCertificate(
      learnerName: _profile!.name,
      finalScore: _finalExamScore,
      snapshot: {
        'completedLessons': _completedLessons,
        'totalLessons': _totalLessons,
        'finalExamScore': _finalExamScore,
        'offlineIssued': true,
      },
    );
    if (!mounted) return;
    setState(() {
      _certificate = certificate;
      _issuing = false;
    });
  }

  Future<void> _copyCertificate({required bool html}) async {
    final certificate = _certificate;
    if (certificate == null) return;
    const exporter = CertificateExportService();
    final text = html ? exporter.toHtml(certificate) : exporter.toPlainText(certificate);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(html ? 'Certificate HTML copied.' : 'Certificate text copied.')),
    );
  }

  Future<void> _exportPdf() async {
    final certificate = _certificate;
    if (certificate == null || _exportingPdf) return;
    setState(() => _exportingPdf = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final renderObject = _certificateBoundaryKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        throw StateError('Certificate preview is not ready.');
      }
      final image = await renderObject.toImage(pixelRatio: 2.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('Could not render certificate image.');

      const service = CertificatePdfService();
      final path = await service.exportFromPng(
        pngBytes: data.buffer.asUint8List(),
        verificationId: certificate.verificationId,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('PDF Certificate তৈরি হয়েছে'),
          content: SelectableText('Saved at:\n$path'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ঠিক আছে'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF export failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _exportingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Certificate')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_certificate != null) ...[
            RepaintBoundary(
              key: _certificateBoundaryKey,
              child: _CertificateCard(certificate: _certificate!),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _copyCertificate(html: false),
                  icon: const Icon(Icons.copy_rounded),
                  label: const Text('Copy Certificate'),
                ),
                OutlinedButton.icon(
                  onPressed: () => _copyCertificate(html: true),
                  icon: const Icon(Icons.code_rounded),
                  label: const Text('Copy HTML'),
                ),
                FilledButton.icon(
                  onPressed: _exportingPdf ? null : _exportPdf,
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label: Text(_exportingPdf ? 'PDF তৈরি হচ্ছে...' : 'Export PDF'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Verification ID local certificate record-এর সঙ্গে সংরক্ষিত। Certificate এখন text, HTML এবং printable PDF হিসেবে export করা যায়। PDF-টি certificate preview-এর image থেকে তৈরি হয়, তাই বাংলা নামও visual form-এ ঠিক থাকে।',
            ),
          ] else ...[
            Text(
              'Certificate Eligibility',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            _RequirementTile(
              ok: _profile?.isComplete == true,
              title: 'Student Profile',
              value: _profile?.isComplete == true ? _profile!.name : 'Profile incomplete',
            ),
            const SizedBox(height: 10),
            _RequirementTile(
              ok: _completedLessons == _totalLessons && _totalLessons > 0,
              title: 'All Lessons Complete',
              value: '$_completedLessons / $_totalLessons',
            ),
            const SizedBox(height: 10),
            _RequirementTile(
              ok: _finalExamScore >= 70,
              title: 'Final Practical Exam',
              value: _finalExamScore == 0 ? 'Not passed' : '$_finalExamScore%',
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _eligible && !_issuing ? _issue : null,
              icon: const Icon(Icons.workspace_premium_rounded),
              label: Text(_issuing ? 'Certificate তৈরি হচ্ছে...' : 'Offline Certificate Issue করুন'),
            ),
          ],
        ],
      ),
    );
  }
}

class _RequirementTile extends StatelessWidget {
  const _RequirementTile({
    required this.ok,
    required this.title,
    required this.value,
  });

  final bool ok;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(ok ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
      ),
    );
  }
}

class _CertificateCard extends StatelessWidget {
  const _CertificateCard({required this.certificate});

  final CertificateRecord certificate;

  @override
  Widget build(BuildContext context) {
    final date = certificate.issuedAt;
    final dateText = '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
      child: Column(
        children: [
          const Icon(Icons.workspace_premium_rounded, size: 54),
          const SizedBox(height: 12),
          Text(
            'CERTIFICATE OF COMPLETION',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 18),
          const Text('This certifies that'),
          const SizedBox(height: 8),
          Text(
            certificate.learnerName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 8),
          const Text('has successfully completed'),
          const SizedBox(height: 8),
          Text(
            certificate.certificateTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          Text('Final Score: ${certificate.finalScore}%'),
          Text('Issued: $dateText'),
          const SizedBox(height: 12),
          SelectableText(
            'Verification ID: ${certificate.verificationId}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
