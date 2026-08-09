import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class WindowsDesktopLabScreen extends StatefulWidget {
  const WindowsDesktopLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WindowsDesktopLabScreen> createState() => _WindowsDesktopLabScreenState();
}

class _WindowsDesktopLabScreenState extends State<WindowsDesktopLabScreen> {
  final List<String> _actionLog = [];
  final Set<String> _openWindows = {};
  final Set<String> _minimizedWindows = {};
  bool _startOpen = false;
  String? _activeWindow;
  bool _submitting = false;

  List<Map<String, dynamic>> get _requirements =>
      (widget.lesson.practicalData['requirements'] as List<dynamic>? ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  void _record(String action) {
    if (!_actionLog.contains(action)) _actionLog.add(action);
  }

  void _toggleStart() {
    setState(() {
      _startOpen = !_startOpen;
      if (_startOpen) _record('open_start');
    });
  }

  void _launch(String app) {
    setState(() {
      _startOpen = false;
      _openWindows.add(app);
      _minimizedWindows.remove(app);
      _activeWindow = app;
      _record(app == 'explorer' ? 'launch_explorer' : 'launch_settings');
    });
  }

  void _minimize() {
    final active = _activeWindow;
    if (active == null) return;
    setState(() {
      _minimizedWindows.add(active);
      _activeWindow = null;
      _record('minimize_window');
    });
  }

  void _close() {
    final active = _activeWindow;
    if (active == null) return;
    setState(() {
      _openWindows.remove(active);
      _minimizedWindows.remove(active);
      _activeWindow = null;
      _record('close_window');
    });
  }

  void _taskbarActivate(String app) {
    if (!_openWindows.contains(app)) {
      _launch(app);
      return;
    }
    setState(() {
      final previous = _activeWindow;
      _minimizedWindows.remove(app);
      _activeWindow = app;
      if (previous != null && previous != app) {
        _record('switch_window');
      } else if (previous == null) {
        _record('restore_window');
      }
    });
  }

  bool _requirementPassed(Map<String, dynamic> requirement) {
    final action = requirement['action'] as String? ?? '';
    return _actionLog.contains(action);
  }

  Future<void> _submit() async {
    if (_submitting) return;
    final checks = [for (final item in _requirements) _requirementPassed(item)];
    final passed = checks.where((value) => value).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();
    setState(() => _submitting = true);

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'windows_desktop',
      score: score,
      metrics: {
        'actions': List<String>.from(_actionLog),
        'passedRequirements': passed,
        'totalRequirements': checks.length,
      },
    );

    if (!mounted) return;
    setState(() => _submitting = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Windows Desktop Practical — $score%'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < _requirements.length; i++)
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    checks[i] ? Icons.check_circle_rounded : Icons.cancel_rounded,
                  ),
                  title: Text(
                    _requirements[i]['label'] as String? ??
                        (_requirements[i]['action'] as String? ?? 'Task'),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('আবার চেষ্টা'),
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

  Widget _desktopIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 86,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 38),
              const SizedBox(height: 5),
              Text(label, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _windowCard(String app) {
    final isExplorer = app == 'explorer';
    return Positioned(
      left: isExplorer ? 18 : 48,
      right: isExplorer ? 48 : 18,
      top: isExplorer ? 72 : 100,
      bottom: isExplorer ? 86 : 72,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.only(left: 12),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Icon(isExplorer ? Icons.folder_rounded : Icons.settings_rounded, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isExplorer ? 'File Explorer' : 'Settings',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _minimize,
                    icon: const Icon(Icons.minimize_rounded),
                    tooltip: 'Minimize',
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    onPressed: _close,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.surface,
                child: isExplorer
                    ? const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Home > Documents', style: TextStyle(fontWeight: FontWeight.w700)),
                          SizedBox(height: 18),
                          ListTile(leading: Icon(Icons.folder), title: Text('Practice')),
                          ListTile(leading: Icon(Icons.description), title: Text('Report.docx')),
                        ],
                      )
                    : const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Windows Settings', style: TextStyle(fontWeight: FontWeight.w800)),
                          SizedBox(height: 18),
                          ListTile(leading: Icon(Icons.wifi), title: Text('Network & Internet')),
                          ListTile(leading: Icon(Icons.devices), title: Text('System')),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.lesson.practicalData['instruction'] as String? ??
        'Desktop, Start menu, Taskbar ও window controls ব্যবহার করুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Windows Desktop Simulator')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          Text(instruction, style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5)),
          const SizedBox(height: 12),
          if (_requirements.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task checklist', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 6),
                    for (final item in _requirements)
                      Row(
                        children: [
                          Icon(
                            _requirementPassed(item)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(item['label'] as String? ?? 'Task')),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 0.72,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primaryContainer,
                    Theme.of(context).colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    top: 14,
                    child: Column(
                      children: [
                        _desktopIcon(
                          icon: Icons.folder_rounded,
                          label: 'File Explorer',
                          onTap: () => _launch('explorer'),
                        ),
                        _desktopIcon(
                          icon: Icons.settings_rounded,
                          label: 'Settings',
                          onTap: () => _launch('settings'),
                        ),
                      ],
                    ),
                  ),
                  if (_activeWindow != null && !_minimizedWindows.contains(_activeWindow))
                    _windowCard(_activeWindow!),
                  if (_startOpen)
                    Positioned(
                      left: 12,
                      bottom: 58,
                      width: 230,
                      child: Material(
                        elevation: 14,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.folder_rounded),
                                title: const Text('File Explorer'),
                                onTap: () => _launch('explorer'),
                              ),
                              ListTile(
                                leading: const Icon(Icons.settings_rounded),
                                title: const Text('Settings'),
                                onTap: () => _launch('settings'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 52,
                    child: Container(
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.94),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _toggleStart,
                            icon: const Icon(Icons.window_rounded),
                            tooltip: 'Start',
                          ),
                          IconButton(
                            onPressed: () => _taskbarActivate('explorer'),
                            icon: Icon(
                              Icons.folder_rounded,
                              color: _activeWindow == 'explorer'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            tooltip: 'File Explorer',
                          ),
                          IconButton(
                            onPressed: () => _taskbarActivate('settings'),
                            icon: Icon(
                              Icons.settings_rounded,
                              color: _activeWindow == 'settings'
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                            tooltip: 'Settings',
                          ),
                          const Spacer(),
                          const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text('10:30'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: const Icon(Icons.fact_check_rounded),
          label: const Text('Desktop task যাচাই করুন'),
        ),
      ),
    );
  }
}
