import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class WindowsPersonalizationLabScreen extends StatefulWidget {
  const WindowsPersonalizationLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<WindowsPersonalizationLabScreen> createState() =>
      _WindowsPersonalizationLabScreenState();
}

class _WindowsPersonalizationLabScreenState
    extends State<WindowsPersonalizationLabScreen> {
  bool _settingsOpened = false;
  bool _controlPanelOpened = false;
  bool _browserOpened = false;
  String _wallpaper = 'Default';
  String _theme = 'Light';
  bool _saving = false;

  List<String> get _requiredActions => List<String>.from(
        widget.lesson.practicalData['requiredActions'] as List<dynamic>? ??
            const [],
      );

  bool _done(String action) {
    switch (action) {
      case 'open_settings':
        return _settingsOpened;
      case 'open_control_panel':
        return _controlPanelOpened;
      case 'open_browser':
        return _browserOpened;
      case 'change_wallpaper':
        return _wallpaper != 'Default';
      case 'change_theme':
        return _theme != 'Light';
      default:
        return false;
    }
  }

  String _label(String action) {
    switch (action) {
      case 'open_settings':
        return 'Windows Settings খুলুন';
      case 'open_control_panel':
        return 'Control Panel খুলুন';
      case 'open_browser':
        return 'Browser খুলুন';
      case 'change_wallpaper':
        return 'Wallpaper পরিবর্তন করুন';
      case 'change_theme':
        return 'Theme পরিবর্তন করুন';
      default:
        return action;
    }
  }

  Future<void> _evaluate() async {
    if (_saving) return;
    final checks = [for (final action in _requiredActions) _done(action)];
    final passed = checks.where((value) => value).length;
    final score =
        checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();

    setState(() => _saving = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind:
          widget.lesson.practicalKind ?? 'windows_personalization',
      score: score,
      metrics: {
        'settingsOpened': _settingsOpened,
        'controlPanelOpened': _controlPanelOpened,
        'browserOpened': _browserOpened,
        'wallpaper': _wallpaper,
        'theme': _theme,
        'passedRequirements': passed,
        'totalRequirements': checks.length,
      },
    );

    if (!mounted) return;
    setState(() => _saving = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Windows Personalization — $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _requiredActions.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  checks[i]
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                ),
                title: Text(_label(_requiredActions[i])),
              ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ঠিক আছে'),
          ),
        ],
      ),
    );
  }

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool done,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: done
            ? const Icon(Icons.check_circle_rounded)
            : const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final instruction =
        widget.lesson.practicalData['instruction'] as String? ??
            'Settings, Control Panel, Wallpaper, Theme ও Browser ব্যবহার করুন।';

    return Scaffold(
      appBar: AppBar(title: const Text('Windows 10 Personalization Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Text(
            instruction,
            style: const TextStyle(fontWeight: FontWeight.w700, height: 1.5),
          ),
          const SizedBox(height: 12),
          _actionCard(
            icon: Icons.settings_rounded,
            title: 'Windows Settings',
            subtitle: 'System ও personalization settings দেখুন',
            done: _settingsOpened,
            onTap: () => setState(() => _settingsOpened = true),
          ),
          _actionCard(
            icon: Icons.tune_rounded,
            title: 'Control Panel',
            subtitle: 'Traditional settings panel খুলুন',
            done: _controlPanelOpened,
            onTap: () => setState(() => _controlPanelOpened = true),
          ),
          const SizedBox(height: 10),
          const Text(
            'Wallpaper',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in ['Default', 'Mountains', 'Ocean', 'School'])
                ChoiceChip(
                  label: Text(item),
                  selected: _wallpaper == item,
                  onSelected: (_) => setState(() => _wallpaper = item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Theme',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final item in ['Light', 'Dark', 'Blue'])
                ChoiceChip(
                  label: Text(item),
                  selected: _theme == item,
                  onSelected: (_) => setState(() => _theme = item),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _actionCard(
            icon: Icons.language_rounded,
            title: 'Web Browser',
            subtitle: 'Browser application launch করার ধারণা',
            done: _browserOpened,
            onTap: () => setState(() => _browserOpened = true),
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Task checklist',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  for (final action in _requiredActions)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            _done(action)
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 19,
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_label(action))),
                        ],
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
          onPressed: _saving ? null : _evaluate,
          icon: const Icon(Icons.fact_check_rounded),
          label: Text(_saving ? 'Saving...' : 'Personalization Task Check'),
        ),
      ),
    );
  }
}
