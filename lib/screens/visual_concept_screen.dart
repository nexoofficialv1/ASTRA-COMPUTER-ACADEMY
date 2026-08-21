import 'package:flutter/material.dart';

class VisualConceptScreen extends StatefulWidget {
  const VisualConceptScreen({
    super.key,
    required this.card,
  });

  final Map<String, dynamic> card;

  @override
  State<VisualConceptScreen> createState() => _VisualConceptScreenState();
}

class _VisualConceptScreenState extends State<VisualConceptScreen> {
  final TransformationController _controller = TransformationController();

  double get _scale => _controller.value.getMaxScaleOnAxis();

  void _setScale(double value) {
    final next = value.clamp(0.8, 4.5);
    _controller.value = Matrix4.diagonal3Values(next, next, 1);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _guided(
    BuildContext context, {
    required String emoji,
    required String title,
    required String text,
  }) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 25)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.card;
    final titleBn = card['titleBn']?.toString() ?? 'Visual Concept';
    final titleEn = card['titleEn']?.toString() ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleBn),
        actions: [
          IconButton(
            tooltip: 'Reset zoom',
            onPressed: () {
              _controller.value = Matrix4.identity();
              setState(() {});
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 0.8,
              maxScale: 4.5,
              boundaryMargin: const EdgeInsets.all(240),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(18),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: Text(
                                card['icon']?.toString() ?? '🧩',
                                style: const TextStyle(fontSize: 58),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              titleBn,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (titleEn.trim().isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                titleEn,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                            const SizedBox(height: 14),
                            Text(
                              card['descriptionBn']?.toString() ?? '',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.55,
                              ),
                            ),
                            _guided(
                              context,
                              emoji: '👀',
                              title: 'কী দেখছ?',
                              text: card['observeBn']?.toString() ?? '',
                            ),
                            _guided(
                              context,
                              emoji: '💡',
                              title: 'কী বুঝবে?',
                              text: card['understandBn']?.toString() ?? '',
                            ),
                            _guided(
                              context,
                              emoji: '⭐',
                              title: 'মনে রাখো',
                              text: card['rememberBn']?.toString() ?? '',
                            ),
                            const Divider(height: 32),
                            _guided(
                              context,
                              emoji: '👀',
                              title: 'What do you see?',
                              text: card['observeEn']?.toString() ?? '',
                            ),
                            _guided(
                              context,
                              emoji: '💡',
                              title: 'What should you understand?',
                              text: card['understandEn']?.toString() ?? '',
                            ),
                            _guided(
                              context,
                              emoji: '⭐',
                              title: 'Remember',
                              text: card['rememberEn']?.toString() ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Pinch করে text/card zoom করতে পারবেন',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Zoom out',
                    onPressed: () => _setScale(_scale / 1.25),
                    icon: const Icon(Icons.zoom_out_rounded),
                  ),
                  IconButton(
                    tooltip: 'Zoom in',
                    onPressed: () => _setScale(_scale * 1.25),
                    icon: const Icon(Icons.zoom_in_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
