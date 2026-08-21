import 'package:flutter/material.dart';

class VisualZoomScreen extends StatefulWidget {
  const VisualZoomScreen({
    super.key,
    required this.assetPath,
    required this.title,
    required this.captionBn,
    required this.captionEn,
  });

  final String assetPath;
  final String title;
  final String captionBn;
  final String captionEn;

  @override
  State<VisualZoomScreen> createState() => _VisualZoomScreenState();
}

class _VisualZoomScreenState extends State<VisualZoomScreen> {
  final TransformationController _controller = TransformationController();

  double get _scale => _controller.value.getMaxScaleOnAxis();

  void _setScale(double value) {
    final next = value.clamp(0.8, 8.0);
    _controller.value = Matrix4.diagonal3Values(next, next, 1);
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
              maxScale: 8,
              boundaryMargin: const EdgeInsets.all(300),
              clipBehavior: Clip.none,
              child: Center(
                child: Image.asset(
                  widget.assetPath,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black87,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.captionBn.trim().isNotEmpty)
                    Text(
                      widget.captionBn,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  if (widget.captionEn.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.captionEn,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Pinch করে zoom করুন • drag করে সরান',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Zoom out',
                        color: Colors.white,
                        onPressed: () => _setScale(_scale / 1.35),
                        icon: const Icon(Icons.zoom_out_rounded),
                      ),
                      IconButton(
                        tooltip: 'Zoom in',
                        color: Colors.white,
                        onPressed: () => _setScale(_scale * 1.35),
                        icon: const Icon(Icons.zoom_in_rounded),
                      ),
                    ],
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
