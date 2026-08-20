import 'dart:math';
import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class AiDecisionLabScreen extends StatefulWidget {
  const AiDecisionLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<AiDecisionLabScreen> createState() => _AiDecisionLabScreenState();
}

class _AiDecisionLabScreenState extends State<AiDecisionLabScreen> {
  static const _choices = ['Rock', 'Paper', 'Scissors'];
  final _random = Random();
  final List<String> _history = [];
  var _computer = '-';
  var _prediction = 'Not enough data yet';
  var _result = 'Play a round';
  String? _patternAnswer;
  String? _verificationAnswer;
  var _saving = false;

  int get _minimumRounds =>
      (widget.lesson.practicalData['minimumRounds'] as num?)?.toInt() ?? 5;

  String _counterFor(String choice) {
    switch (choice) {
      case 'Rock':
        return 'Paper';
      case 'Paper':
        return 'Scissors';
      default:
        return 'Rock';
    }
  }

  String _mostFrequent() {
    if (_history.isEmpty) {
      return _choices[_random.nextInt(_choices.length)];
    }
    final counts = {for (final choice in _choices) choice: 0};
    for (final choice in _history) {
      counts[choice] = counts[choice]! + 1;
    }
    return _choices.reduce(
      (a, b) => counts[a]! >= counts[b]! ? a : b,
    );
  }

  void _play(String userChoice) {
    final expected = _history.length < 2
        ? _choices[_random.nextInt(_choices.length)]
        : _mostFrequent();
    final computerChoice = _counterFor(expected);
    String result;
    if (computerChoice == userChoice) {
      result = 'Draw';
    } else if ((userChoice == 'Rock' &&
            computerChoice == 'Scissors') ||
        (userChoice == 'Paper' && computerChoice == 'Rock') ||
        (userChoice == 'Scissors' && computerChoice == 'Paper')) {
      result = 'You win';
    } else {
      result = 'Computer wins';
    }
    setState(() {
      _prediction = _history.length < 2
          ? 'Exploring randomly'
          : 'Predicted you may choose $expected from earlier choices';
      _computer = computerChoice;
      _result =
          '$result — You: $userChoice, Computer: $computerChoice';
      _history.add(userChoice);
    });
  }

  int _score() {
    var score = 0;
    if (_history.length >= _minimumRounds) score += 40;
    if (_patternAnswer == 'Past choices and patterns') score += 30;
    if (_verificationAnswer ==
        'AI can be wrong; verify important output') {
      score += 30;
    }
    return score;
  }

  Future<void> _evaluate() async {
    if (_saving) return;
    final score = _score();
    setState(() => _saving = true);
    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'ai_decision',
      score: score,
      metrics: {
        'rounds': _history.length,
        'choices': List<String>.from(_history),
        'patternAnswer': _patternAnswer,
        'verificationAnswer': _verificationAnswer,
      },
    );
    if (!mounted) return;
    setState(() => _saving = false);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          score >= 70
              ? 'AI Activity Completed'
              : 'আরও কিছু পর্যবেক্ষণ করুন',
        ),
        content: Text(
          'Score: $score%\nRounds: ${_history.length}/$_minimumRounds',
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
    return Scaffold(
      appBar: AppBar(title: const Text('AI Learning Activity')),
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
            'এই activity-তে app আপনার আগের choices থেকে একটি simple pattern অনুমান করে। এটি real machine-learning model নয়; AI prediction ধারণা বোঝানোর simulator।',
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Round ${_history.length + 1}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final choice in _choices)
                        FilledButton.tonal(
                          onPressed: () => _play(choice),
                          child: Text(choice),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(_result),
                  const SizedBox(height: 6),
                  Text('Computer choice: $_computer'),
                  const SizedBox(height: 6),
                  Text(_prediction, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Observation Check',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text('1. এই predictor মূলত কোন তথ্য ব্যবহার করছে?'),
          DropdownButton<String>(
            isExpanded: true,
            value: _patternAnswer,
            hint: const Text('Select answer'),
            items: const [
              DropdownMenuItem(
                value: 'Magic',
                child: Text('Magic'),
              ),
              DropdownMenuItem(
                value: 'Past choices and patterns',
                child: Text('Past choices and patterns'),
              ),
              DropdownMenuItem(
                value: 'It always knows the future',
                child: Text('It always knows the future'),
              ),
            ],
            onChanged: (value) =>
                setState(() => _patternAnswer = value),
          ),
          const SizedBox(height: 12),
          const Text(
            '2. গুরুত্বপূর্ণ AI output পেলে কী করা উচিত?',
          ),
          DropdownButton<String>(
            isExpanded: true,
            value: _verificationAnswer,
            hint: const Text('Select answer'),
            items: const [
              DropdownMenuItem(
                value: 'Always trust it',
                child: Text('Always trust it'),
              ),
              DropdownMenuItem(
                value: 'AI can be wrong; verify important output',
                child: Text(
                  'AI can be wrong; verify important output',
                ),
              ),
              DropdownMenuItem(
                value: 'Share private data first',
                child: Text('Share private data first'),
              ),
            ],
            onChanged: (value) =>
                setState(() => _verificationAnswer = value),
          ),
          const SizedBox(height: 12),
          Text(
            'Played ${_history.length}/$_minimumRounds required rounds',
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: _saving ? null : _evaluate,
          icon: const Icon(Icons.psychology_rounded),
          label: Text(
            _saving ? 'Saving...' : 'Evaluate AI Activity',
          ),
        ),
      ),
    );
  }
}
