import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class ScratchLabScreen extends StatefulWidget {
  const ScratchLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<ScratchLabScreen> createState() => _ScratchLabScreenState();
}

class _ScratchLabScreenState extends State<ScratchLabScreen> {
  static const _labels = <String, String>{
    'when_tapped': 'when sprite tapped',
    'move10': 'move 10 steps',
    'turn15': 'turn 15°',
    'say_hello': 'say Hello!',
    'say_question': 'say a question',
    'wait_answer': 'wait for answer',
    'say_result': 'say Correct / Try again',
    'repeat4': 'repeat 4',
    'play_sound': 'play sound',
    'pen_down': 'pen down',
  };

  static const _actionLabels = <String, String>{
    'duplicate_sprite': 'Duplicate Sprite',
    'save_project': 'Save Project',
    'open_project': 'Open Project',
    'exit_project': 'Exit / Finish Project',
    'select_sprite': 'Choose Sprite from Library',
    'choose_costume': 'Choose Costume',
    'choose_backdrop': 'Choose Backdrop',
  };

  final List<String> _script = [];
  final Set<String> _actions = {};
  var _x = 0.0;
  var _rotation = 0.0;
  var _message = 'Ready';
  var _ran = false;
  var _saving = false;

  List<String> get _required => List<String>.from(
        widget.lesson.practicalData['requiredBlocks'] as List<dynamic>? ??
            const [],
      );

  List<String> get _requiredActions => List<String>.from(
        widget.lesson.practicalData['requiredActions'] as List<dynamic>? ??
            const [],
      );

  void _add(String block) => setState(() => _script.add(block));

  void _doAction(String action) {
    if (action == 'open_project' && !_actions.contains('save_project')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আগে project Save করুন।')),
      );
      return;
    }
    setState(() => _actions.add(action));
  }

  void _run() {
    var x = 0.0;
    var rotation = 0.0;
    var message = 'Running...';
    for (final block in _script) {
      switch (block) {
        case 'move10':
          x += 10;
          break;
        case 'turn15':
          rotation += 15;
          break;
        case 'say_hello':
          message = 'Hello!';
          break;
        case 'say_question':
          message = 'What is 2 + 2?';
          break;
        case 'wait_answer':
          message = 'Waiting for answer...';
          break;
        case 'say_result':
          message = 'Correct / Try again';
          break;
        case 'play_sound':
          message = '♪ Sound played';
          break;
        case 'repeat4':
          rotation += 60;
          break;
        case 'pen_down':
          message = 'Pen is drawing';
          break;
      }
    }
    setState(() {
      _x = x.clamp(-100, 100).toDouble();
      _rotation = rotation;
      _message = message;
      _ran = true;
    });
  }

  int _score() {
    final checks = <bool>[
      for (final block in _required) _script.contains(block),
      for (final action in _requiredActions) _actions.contains(action),
      if (_required.isNotEmpty) _ran,
    ];
    if (checks.isEmpty) return 0;
    return ((checks.where((item) => item).length / checks.length) * 100)
        .round();
  }

  Future<void> _evaluate() async {
    if (_saving) return;
    final score = _score();
    setState(() => _saving = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'scratch',
      score: score,
      metrics: {
        'mode': widget.lesson.practicalData['mode'],
        'blocks': List<String>.from(_script),
        'requiredBlocks': _required,
        'actions': _actions.toList(),
        'requiredActions': _requiredActions,
        'ranProgram': _ran,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);

    final missingBlocks = _required
        .where((item) => !_script.contains(item))
        .map((item) => _labels[item] ?? item)
        .toList();
    final missingActions = _requiredActions
        .where((item) => !_actions.contains(item))
        .map((item) => _actionLabels[item] ?? item)
        .toList();
    final missing = [...missingBlocks, ...missingActions];
    if (_required.isNotEmpty && !_ran) missing.add('Run Program');

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          score >= 70 ? 'Scratch Task Completed' : 'Task অসম্পূর্ণ',
        ),
        content: Text(
          missing.isEmpty
              ? 'Score: $score%\nসব প্রয়োজনীয় কাজ সম্পন্ন হয়েছে।'
              : 'Score: $score%\nMissing: ${missing.join(', ')}',
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
  Widget build(BuildContext context) {
    final palette = _labels.keys.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Scratch 3 Lab')),
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
          Text(
            _required.isNotEmpty
                ? 'Block tap/drag করে Script Area-তে যোগ করুন, তারপর Run চাপুন।'
                : 'Project tools ব্যবহার করে required workflow সম্পন্ন করুন।',
          ),
          if (_required.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Required blocks: '
              '${_required.map((item) => _labels[item] ?? item).join(' • ')}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final block in palette)
                  Draggable<String>(
                    data: block,
                    feedback: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(_labels[block]!),
                      ),
                    ),
                    child: ActionChip(
                      label: Text(_labels[block]!),
                      onPressed: () => _add(block),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            DragTarget<String>(
              onAcceptWithDetails: (details) => _add(details.data),
              builder: (context, candidateData, rejectedData) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Script Area',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      if (_script.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text('এখানে block drop করুন'),
                          ),
                        )
                      else
                        SizedBox(
                          height: 220,
                          child: ReorderableListView.builder(
                            itemCount: _script.length,
                            onReorder: (oldIndex, newIndex) {
                              setState(() {
                                if (newIndex > oldIndex) newIndex -= 1;
                                final item = _script.removeAt(oldIndex);
                                _script.insert(newIndex, item);
                              });
                            },
                            itemBuilder: (context, index) {
                              final block = _script[index];
                              return ListTile(
                                key: ValueKey('$index-$block'),
                                dense: true,
                                leading: const Icon(
                                  Icons.drag_indicator_rounded,
                                ),
                                title: Text(_labels[block] ?? block),
                                trailing: IconButton(
                                  onPressed: () => setState(
                                    () => _script.removeAt(index),
                                  ),
                                  icon: const Icon(Icons.close_rounded),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SizedBox(
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Positioned(
                      top: 12,
                      left: 14,
                      child: Text(
                        'Stage',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(_x, 10),
                      child: Transform.rotate(
                        angle: _rotation * 0.0174533,
                        child: const Icon(Icons.pets_rounded, size: 60),
                      ),
                    ),
                    Positioned(bottom: 12, child: Text(_message)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _script.isEmpty ? null : _run,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('Run'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => setState(() {
                    _script.clear();
                    _ran = false;
                    _message = 'Ready';
                    _x = 0;
                    _rotation = 0;
                  }),
                  icon: const Icon(Icons.restart_alt_rounded),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
          if (_requiredActions.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Project / Scene Actions',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final action in _requiredActions)
                  FilterChip(
                    selected: _actions.contains(action),
                    label: Text(_actionLabels[action] ?? action),
                    avatar: Icon(
                      _actions.contains(action)
                          ? Icons.check_rounded
                          : Icons.touch_app_rounded,
                    ),
                    onSelected: (_) => _doAction(action),
                  ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _evaluate,
          icon: const Icon(Icons.fact_check_rounded),
          label: Text(_saving ? 'Saving...' : 'Evaluate Scratch Task'),
        ),
      ),
    );
  }
}
