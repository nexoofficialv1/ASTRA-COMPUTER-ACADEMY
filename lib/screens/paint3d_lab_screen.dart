import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class Paint3DLabScreen extends StatefulWidget {
  const Paint3DLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<Paint3DLabScreen> createState() => _Paint3DLabScreenState();
}

class _Paint3DLabScreenState extends State<Paint3DLabScreen> {
  final TextEditingController _titleController = TextEditingController();
  final List<_CanvasObject> _objects = [];
  var _brushStrokes = 0;
  var _saving = false;

  int get _shape2D => _objects.where((item) => item.kind == '2d').length;
  int get _shape3D => _objects.where((item) => item.kind == '3d').length;
  int get _stickers => _objects.where((item) => item.kind == 'sticker').length;

  void _add(String kind, String label, IconData icon) {
    setState(() => _objects.add(_CanvasObject(kind, label, icon)));
  }

  void _reset() {
    setState(() {
      _objects.clear();
      _brushStrokes = 0;
      _titleController.clear();
    });
  }

  int _score() {
    final data = widget.lesson.practicalData;
    final checks = <bool>[
      _shape2D >= ((data['required2D'] as num?)?.toInt() ?? 1),
      _shape3D >= ((data['required3D'] as num?)?.toInt() ?? 1),
      _brushStrokes >= ((data['requiredBrush'] as num?)?.toInt() ?? 1),
      _stickers >= ((data['requiredSticker'] as num?)?.toInt() ?? 1),
    ];
    if (data['requireTitle'] == true) {
      checks.add(_titleController.text.trim().length >= 3);
    }
    return ((checks.where((item) => item).length / checks.length) * 100).round();
  }

  Future<void> _evaluate() async {
    if (_saving) return;
    final score = _score();
    setState(() => _saving = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'paint3d',
      score: score,
      metrics: {
        'shape2D': _shape2D,
        'shape3D': _shape3D,
        'brushStrokes': _brushStrokes,
        'stickers': _stickers,
        'hasTitle': _titleController.text.trim().isNotEmpty,
        'mode': widget.lesson.practicalData['mode'],
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(score >= 70 ? 'Practical Completed' : 'আরও একটু Practice করুন'),
        content: Text(
          'Score: $score%\n২D: $_shape2D • ৩D: $_shape3D • Brush: $_brushStrokes • Sticker: $_stickers',
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

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final posterMode = widget.lesson.practicalData['requireTitle'] == true;
    return Scaffold(
      appBar: AppBar(title: const Text('Paint 3D Lab')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          Text(
            widget.lesson.practicalData['taskTitle'] as String? ??
                widget.lesson.titleBn,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tools ব্যবহার করে canvas-এ object যোগ করুন। এটি একটি learning simulator—বাস্তব Paint 3D নয়।',
          ),
          if (posterMode) ...[
            const SizedBox(height: 14),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Poster Title',
                hintText: 'HEALTHY FOOD',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => _add(
                  '2d',
                  'Circle',
                  Icons.circle_outlined,
                ),
                icon: const Icon(Icons.circle_outlined),
                label: const Text('2D Shape'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _add(
                  '3d',
                  'Cube',
                  Icons.view_in_ar_rounded,
                ),
                icon: const Icon(Icons.view_in_ar_rounded),
                label: const Text('3D Shape'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => setState(() => _brushStrokes += 1),
                icon: const Icon(Icons.brush_rounded),
                label: const Text('Brush'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => _add(
                  'sticker',
                  'Sticker',
                  Icons.emoji_emotions_outlined,
                ),
                icon: const Icon(Icons.emoji_emotions_outlined),
                label: const Text('Sticker'),
              ),
              OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Card(
            child: Container(
              constraints: const BoxConstraints(minHeight: 250),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_titleController.text.trim().isNotEmpty)
                    Text(
                      _titleController.text.trim(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  if (_titleController.text.trim().isNotEmpty)
                    const SizedBox(height: 14),
                  if (_objects.isEmpty && _brushStrokes == 0)
                    const SizedBox(
                      height: 170,
                      child: Center(
                        child: Text(
                          'Canvas খালি — উপরের tools থেকে শুরু করুন',
                        ),
                      ),
                    )
                  else
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        for (final item in _objects)
                          Chip(
                            avatar: Icon(item.icon),
                            label: Text(item.label),
                          ),
                        for (var i = 0; i < _brushStrokes; i++)
                          const Chip(
                            avatar: Icon(Icons.brush_rounded),
                            label: Text('Brush stroke'),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Progress: 2D $_shape2D • 3D $_shape3D • Brush $_brushStrokes • Sticker $_stickers',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _evaluate,
          icon: const Icon(Icons.fact_check_rounded),
          label: Text(_saving ? 'Saving...' : 'Evaluate Practical'),
        ),
      ),
    );
  }
}

class _CanvasObject {
  const _CanvasObject(this.kind, this.label, this.icon);
  final String kind;
  final String label;
  final IconData icon;
}
