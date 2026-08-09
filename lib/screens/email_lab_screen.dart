import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class EmailLabScreen extends StatefulWidget {
  const EmailLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<EmailLabScreen> createState() => _EmailLabScreenState();
}

class _EmailLabScreenState extends State<EmailLabScreen> {
  final _toController = TextEditingController();
  final _ccController = TextEditingController();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  String? _attachment;
  bool _sent = false;
  bool _submitting = false;

  Map<String, dynamic> get _task => Map<String, dynamic>.from(
        widget.lesson.practicalData['task'] as Map<String, dynamic>? ?? const {},
      );

  List<String> get _mockFiles =>
      (widget.lesson.practicalData['mockFiles'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList();

  @override
  void dispose() {
    _toController.dispose();
    _ccController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool _equals(String value, Object? expected) =>
      value.trim().toLowerCase() == expected?.toString().trim().toLowerCase();

  bool _containsAll(String value, List<dynamic> expected) {
    final source = value.toLowerCase();
    return expected.every((item) => source.contains(item.toString().toLowerCase()));
  }

  List<(String, bool)> _checks() {
    final checks = <(String, bool)>[];
    if (_task['to'] != null) {
      checks.add(('To: ${_task['to']}', _equals(_toController.text, _task['to'])));
    }
    if (_task['cc'] != null) {
      checks.add(('CC: ${_task['cc']}', _equals(_ccController.text, _task['cc'])));
    }
    if (_task['subject'] != null) {
      checks.add(('Subject ঠিক', _equals(_subjectController.text, _task['subject'])));
    }
    final subjectKeywords = _task['subjectKeywords'] as List<dynamic>?;
    if (subjectKeywords != null && subjectKeywords.isNotEmpty) {
      checks.add(('Subject keyword', _containsAll(_subjectController.text, subjectKeywords)));
    }
    final bodyKeywords = _task['bodyKeywords'] as List<dynamic>?;
    if (bodyKeywords != null && bodyKeywords.isNotEmpty) {
      checks.add(('Body-তে প্রয়োজনীয় তথ্য', _containsAll(_bodyController.text, bodyKeywords)));
    }
    if (_task['attachment'] != null) {
      checks.add(('Attachment: ${_task['attachment']}', _attachment == _task['attachment']));
    }
    if (_task['requireSend'] == true) checks.add(('Send করা হয়েছে', _sent));
    return checks;
  }

  Future<void> _chooseAttachment() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            const ListTile(
              leading: Icon(Icons.attach_file_rounded),
              title: Text('Mock Files'),
              subtitle: Text('এগুলো training file; device-এর real file নয়।'),
            ),
            for (final file in _mockFiles)
              ListTile(
                leading: const Icon(Icons.insert_drive_file_rounded),
                title: Text(file),
                onTap: () => Navigator.of(context).pop(file),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _attachment = selected);
  }

  void _send() {
    setState(() => _sent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Training email sent — কোনো real email পাঠানো হয়নি।')),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final checks = _checks();
    final passed = checks.where((item) => item.$2).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();
    setState(() => _submitting = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'email_compose',
      score: score,
      metrics: {
        'to': _toController.text.trim(),
        'cc': _ccController.text.trim(),
        'subject': _subjectController.text.trim(),
        'bodyLength': _bodyController.text.trim().length,
        'attachment': _attachment,
        'sent': _sent,
        'passedChecks': passed,
        'totalChecks': checks.length,
      },
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Email Practical — $score%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final item in checks)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(item.$2 ? Icons.check_circle_rounded : Icons.cancel_rounded),
                  title: Text(item.$1),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Edit'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('শেষ করুন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.lesson.practicalData['instruction'] as String? ??
        'নির্দেশ অনুযায়ী email compose করুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Offline Email Simulator')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(instruction, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _toController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'To', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ccController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: 'CC (optional)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyController,
            minLines: 7,
            maxLines: 12,
            decoration: const InputDecoration(labelText: 'Message', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.attach_file_rounded),
              title: Text(_attachment ?? 'No attachment'),
              subtitle: const Text('Mock file picker'),
              trailing: OutlinedButton(
                onPressed: _chooseAttachment,
                child: const Text('Attach'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _send,
            icon: Icon(_sent ? Icons.check_circle_rounded : Icons.send_rounded),
            label: Text(_sent ? 'Training Email Sent' : 'Send'),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Email task যাচাই করুন'),
        ),
      ),
    );
  }
}
