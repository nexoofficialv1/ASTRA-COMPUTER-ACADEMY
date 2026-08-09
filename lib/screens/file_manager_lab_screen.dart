import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class FileManagerLabScreen extends StatefulWidget {
  const FileManagerLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<FileManagerLabScreen> createState() => _FileManagerLabScreenState();
}

class _FileManagerLabScreenState extends State<FileManagerLabScreen> {
  final Set<String> _folders = {'Documents', 'Downloads', 'Desktop'};
  final List<_VirtualFile> _files = [];
  String _currentFolder = 'Documents';

  List<Map<String, dynamic>> get _requirements =>
      (widget.lesson.practicalData['requirements'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  @override
  void initState() {
    super.initState();
    final data = widget.lesson.practicalData;
    _folders.addAll(List<String>.from(data['initialFolders'] as List<dynamic>? ?? const []));
    for (final item in data['initialFiles'] as List<dynamic>? ?? const []) {
      final row = Map<String, dynamic>.from(item as Map);
      _files.add(
        _VirtualFile(
          name: row['name'] as String,
          folder: row['folder'] as String? ?? 'Documents',
        ),
      );
    }
    final start = data['startFolder'] as String?;
    if (start != null && _folders.contains(start)) _currentFolder = start;
  }

  Future<String?> _askText(String title, {String initial = ''}) async {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _createFolder() async {
    final name = await _askText('নতুন Folder-এর নাম');
    if (name == null || name.isEmpty) return;
    setState(() => _folders.add(name));
  }

  Future<void> _renameFile(_VirtualFile file) async {
    final name = await _askText('ফাইল Rename করুন', initial: file.name);
    if (name == null || name.isEmpty) return;
    setState(() => file.name = name);
  }

  Future<void> _moveFile(_VirtualFile file) async {
    final target = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('কোন Folder-এ Move করবেন?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final folder in _folders)
                ListTile(
                  leading: const Icon(Icons.folder_rounded),
                  title: Text(folder),
                  onTap: () => Navigator.pop(context, folder),
                ),
            ],
          ),
        ),
      ),
    );
    if (target == null) return;
    setState(() => file.folder = target);
  }

  void _deleteFile(_VirtualFile file) {
    setState(() => _files.remove(file));
  }

  bool _checkRequirement(Map<String, dynamic> requirement) {
    final type = requirement['type'] as String? ?? '';
    switch (type) {
      case 'create_folder':
        return _folders.contains(requirement['name']);
      case 'move_file':
        return _files.any(
          (file) =>
              file.name == requirement['name'] &&
              file.folder == requirement['folder'],
        );
      case 'rename_file':
        return _files.any(
          (file) =>
              file.name == requirement['to'] &&
              (requirement['folder'] == null || file.folder == requirement['folder']),
        );
      case 'delete_file':
        return !_files.any((file) => file.name == requirement['name']);
      default:
        return false;
    }
  }

  String _requirementLabel(Map<String, dynamic> r) {
    switch (r['type']) {
      case 'create_folder':
        return '"${r['name']}" folder তৈরি';
      case 'move_file':
        return '${r['name']} → ${r['folder']} move';
      case 'rename_file':
        return '${r['from']} → ${r['to']} rename';
      case 'delete_file':
        return '${r['name']} delete';
      default:
        return 'Task';
    }
  }

  Future<void> _submit() async {
    final checks = [for (final r in _requirements) _checkRequirement(r)];
    final passed = checks.where((value) => value).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'windows_file_manager',
      score: score,
      metrics: {
        'requirements': checks.length,
        'passedRequirements': passed,
        'folders': _folders.toList()..sort(),
        'files': [for (final f in _files) {'name': f.name, 'folder': f.folder}],
      },
    );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Score: $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < _requirements.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(
                      checks[i] ? Icons.check_circle_rounded : Icons.cancel_rounded,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_requirementLabel(_requirements[i]))),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final visibleFiles = _files.where((file) => file.folder == _currentFolder).toList();
    final instruction = widget.lesson.practicalData['instruction'] as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.titleBn)),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(instruction, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          SizedBox(
            height: 62,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              children: [
                for (final folder in _folders)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      avatar: const Icon(Icons.folder_rounded, size: 18),
                      label: Text(folder),
                      selected: _currentFolder == folder,
                      onSelected: (_) => setState(() => _currentFolder = folder),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'This PC > $_currentFolder',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                IconButton(
                  tooltip: 'New Folder',
                  onPressed: _createFolder,
                  icon: const Icon(Icons.create_new_folder_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: visibleFiles.isEmpty
                ? const Center(child: Text('এই folder-এ কোনো file নেই।'))
                : ListView.builder(
                    itemCount: visibleFiles.length,
                    itemBuilder: (context, index) {
                      final file = visibleFiles[index];
                      return ListTile(
                        leading: const Icon(Icons.insert_drive_file_rounded),
                        title: Text(file.name),
                        subtitle: Text(file.folder),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'rename') _renameFile(file);
                            if (value == 'move') _moveFile(file);
                            if (value == 'delete') _deleteFile(file);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'rename', child: Text('Rename')),
                            PopupMenuItem(value: 'move', child: Text('Move')),
                            PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Task Check করুন'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VirtualFile {
  _VirtualFile({required this.name, required this.folder});

  String name;
  String folder;
}
