import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';

class InternetLabScreen extends StatefulWidget {
  const InternetLabScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  @override
  State<InternetLabScreen> createState() => _InternetLabScreenState();
}

class _InternetLabScreenState extends State<InternetLabScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _results = const [];
  Map<String, dynamic>? _openedPage;
  bool? _secureAnswer;
  bool _downloaded = false;
  bool _uploaded = false;
  String _lastQuery = '';

  List<Map<String, dynamic>> get _pages =>
      (widget.lesson.practicalData['pages'] as List<dynamic>? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim().toLowerCase();
    final matches = _pages.where((page) {
      final haystack = [
        page['title'],
        page['url'],
        page['body'],
        ...(page['keywords'] as List<dynamic>? ?? const []),
      ].join(' ').toLowerCase();
      return query.isNotEmpty && haystack.contains(query);
    }).toList();
    setState(() {
      _lastQuery = query;
      _results = matches;
      _openedPage = null;
      _secureAnswer = null;
    });
  }

  bool _check(Map<String, dynamic> requirement) {
    switch (requirement['type']) {
      case 'search_contains':
        return _lastQuery.contains((requirement['value'] as String).toLowerCase());
      case 'open_page':
        return _openedPage?['id'] == requirement['pageId'];
      case 'secure_answer':
        return _secureAnswer == requirement['value'];
      case 'download':
        return _downloaded;
      case 'upload':
        return _uploaded;
      default:
        return false;
    }
  }

  String _label(Map<String, dynamic> r) {
    switch (r['type']) {
      case 'search_contains':
        return 'সঠিক search ব্যবহার';
      case 'open_page':
        return 'নির্দিষ্ট result open';
      case 'secure_answer':
        return 'HTTPS নিরাপত্তা শনাক্ত';
      case 'download':
        return 'Sample file download';
      case 'upload':
        return 'Sample file upload';
      default:
        return 'Internet task';
    }
  }

  Future<void> _submit() async {
    final requirements =
        (widget.lesson.practicalData['requirements'] as List<dynamic>? ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
    final checks = [for (final r in requirements) _check(r)];
    final passed = checks.where((x) => x).length;
    final score = checks.isEmpty ? 100 : ((passed / checks.length) * 100).round();

    await widget.progressRepository.recordPracticeAttempt(
      lessonId: widget.lesson.id,
      practicalKind: widget.lesson.practicalKind ?? 'internet_browser',
      score: score,
      metrics: {
        'query': _lastQuery,
        'openedPage': _openedPage?['id'],
        'secureAnswer': _secureAnswer,
        'downloaded': _downloaded,
        'uploaded': _uploaded,
      },
    );
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Score: $score%'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < requirements.length; i++)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(checks[i] ? Icons.check_circle : Icons.cancel),
                title: Text(_label(requirements[i])),
              ),
          ],
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('ঠিক আছে')),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final instruction = widget.lesson.practicalData['instruction'] as String? ?? '';
    final opened = _openedPage;

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
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Search the web (offline simulator)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _search, child: const Text('Search')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: opened != null
                ? ListView(
                    padding: const EdgeInsets.all(18),
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => setState(() => _openedPage = null),
                            icon: const Icon(Icons.arrow_back_rounded),
                          ),
                          Expanded(
                            child: Text(
                              opened['url'] as String? ?? '',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        opened['title'] as String? ?? '',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(opened['body'] as String? ?? ''),
                      const SizedBox(height: 22),
                      const Text('এই page-টি HTTPS secure কি?', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(value: true, label: Text('হ্যাঁ')),
                          ButtonSegment(value: false, label: Text('না')),
                        ],
                        selected: _secureAnswer == null ? <bool>{} : <bool>{_secureAnswer!},
                        emptySelectionAllowed: true,
                        onSelectionChanged: (values) {
                          setState(() => _secureAnswer = values.isEmpty ? null : values.first);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (opened['allowDownload'] == true)
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _downloaded = true),
                          icon: Icon(_downloaded ? Icons.check_circle : Icons.download_rounded),
                          label: Text(_downloaded ? 'Sample file downloaded' : 'Download sample file'),
                        ),
                      if (opened['allowUpload'] == true) ...[
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () => setState(() => _uploaded = true),
                          icon: Icon(_uploaded ? Icons.check_circle : Icons.upload_file_rounded),
                          label: Text(_uploaded ? 'Sample file uploaded' : 'Upload sample file'),
                        ),
                      ],
                    ],
                  )
                : _results.isEmpty
                    ? const Center(child: Text('Search করলে offline practice results এখানে দেখাবে।'))
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _results.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final page = _results[index];
                          return ListTile(
                            leading: const Icon(Icons.language_rounded),
                            title: Text(page['title'] as String? ?? ''),
                            subtitle: Text(page['url'] as String? ?? ''),
                            onTap: () => setState(() => _openedPage = page),
                          );
                        },
                      ),
          ),
          SafeArea(
            minimum: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.fact_check_rounded),
              label: const Text('Internet Task Check করুন'),
            ),
          ),
        ],
      ),
    );
  }
}
