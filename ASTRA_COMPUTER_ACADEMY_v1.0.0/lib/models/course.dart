import 'lesson.dart';

class Course {
  const Course({
    required this.id,
    required this.title,
    required this.titleBn,
    required this.subtitleBn,
    required this.icon,
    required this.level,
    required this.lessons,
  });

  final String id;
  final String title;
  final String titleBn;
  final String subtitleBn;
  final String icon;
  final String level;
  final List<Lesson> lessons;

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      titleBn: json['titleBn'] as String,
      subtitleBn: json['subtitleBn'] as String,
      icon: json['icon'] as String,
      level: json['level'] as String,
      lessons: (json['lessons'] as List<dynamic>)
          .map((item) => Lesson.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
