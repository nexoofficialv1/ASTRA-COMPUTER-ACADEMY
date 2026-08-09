import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/backup_restore_service.dart';

class DataToolsScreen extends StatefulWidget {
  const DataToolsScreen({super.key, required this.backupRestoreService});

  final BackupRestoreService backupRestoreService;

  @override
  State<DataToolsScreen> createState() => _DataToolsScreenState();
}

class _DataToolsScreenState extends State<DataToolsScreen> {
  final _restoreController = TextEditingController();
  String _exportedBackup = '';
  bool _busy = false;

  @override
  void dispose() {
    _restoreController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final data = await widget.backupRestoreService.exportBackup();
      await Clipboard.setData(ClipboardData(text: data));
      if (!mounted) return;
      setState(() => _exportedBackup = data);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Backup JSON clipboard-এ কপি হয়েছে।')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup তৈরি করা যায়নি: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData('text/plain');
    if (!mounted) return;
    _restoreController.text = data?.text ?? '';
  }

  Future<void> _restore() async {
    final text = _restoreController.text.trim();
    if (text.isEmpty) return;

    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Backup restore করবেন?'),
            content: const Text(
              'বর্তমান local profile, progress, practical history, exam এবং certificate data backup-এর data দিয়ে প্রতিস্থাপিত হবে।',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Restore'),
              ),
            ],
          ),
        ) ??
        false;
    if (!confirmed) return;

    setState(() => _busy = true);
    try {
      final result = await widget.backupRestoreService.restoreBackup(text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.restoredRecords}টি record restore হয়েছে (source v${result.sourceVersion}).',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline Backup',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Student profile, lesson progress, practical attempts, streak activity, final exam এবং certificate record একটি JSON backup-এ রাখা হবে।',
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _busy ? null : _export,
                    icon: const Icon(Icons.backup_rounded),
                    label: const Text('Backup তৈরি ও Copy করুন'),
                  ),
                  if (_exportedBackup.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Backup ready • ${_exportedBackup.length} characters',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Restore Backup',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text('আগে export করা ASTRA backup JSON paste করুন।'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _restoreController,
                    minLines: 5,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '{ "schema": "astra_offline_backup_v1", ... }',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _paste,
                    icon: const Icon(Icons.content_paste_rounded),
                    label: const Text('Clipboard থেকে Paste'),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: const Icon(Icons.restore_rounded),
                    label: const Text('Restore করুন'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'এই v0.6 foundation সম্পূর্ণ offline। File picker/cloud sync পরে যোগ করা যাবে; বর্তমানে backup text clipboard দিয়ে অন্য device বা safe note-এ সংরক্ষণ করা যায়।',
          ),
        ],
      ),
    );
  }
}
