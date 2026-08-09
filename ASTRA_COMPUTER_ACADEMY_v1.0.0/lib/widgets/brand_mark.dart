import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false, this.inverse = false});

  final bool compact;
  final bool inverse;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final titleColor = inverse ? Colors.white : scheme.onSurface;
    final subtitleColor = inverse ? Colors.white70 : scheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 42,
          height: compact ? 34 : 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.skyBlue, AppTheme.royalBlue],
            ),
            borderRadius: BorderRadius.circular(compact ? 10 : 12),
          ),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: compact ? 21 : 26,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ASTRA',
              style: TextStyle(
                color: titleColor,
                fontSize: compact ? 16 : 20,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: .7,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'COMPUTER ACADEMY',
              style: TextStyle(
                color: subtitleColor,
                fontSize: compact ? 7.5 : 9,
                fontWeight: FontWeight.w800,
                letterSpacing: .55,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
