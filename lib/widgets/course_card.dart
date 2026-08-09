import 'package:flutter/material.dart';
import '../models/course.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    super.key,
    required this.course,
    required this.completedLessons,
    required this.onTap,
    this.compact = false,
  });

  final Course course;
  final int completedLessons;
  final VoidCallback onTap;
  final bool compact;

  static const _palette = <Color>[
    Color(0xFF1A73E8),
    Color(0xFF6C4CE3),
    Color(0xFF17A56B),
    Color(0xFFF4511E),
    Color(0xFF7E57C2),
    Color(0xFFF2A900),
    Color(0xFF2196F3),
    Color(0xFF5C6BC0),
    Color(0xFF8E44AD),
  ];

  @override
  Widget build(BuildContext context) {
    final total = course.lessons.length;
    final progress = total == 0 ? 0.0 : completedLessons / total;
    final index = course.id.codeUnits.fold<int>(0, (a, b) => a + b);
    final accent = _palette[index % _palette.length];
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(compact ? 14 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: compact ? 44 : 50,
                height: compact ? 44 : 50,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(course.icon, style: TextStyle(fontSize: compact ? 21 : 24)),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.titleBn,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              color: accent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          '${(progress * 100).round()}%',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedLessons/$total lessons',
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
