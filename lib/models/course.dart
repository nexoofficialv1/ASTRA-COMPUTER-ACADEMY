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
    this.track = 'skill',
    this.grade,
    this.curriculumLabel,
  });

  final String id;
  final String title;
  final String titleBn;
  final String subtitleBn;
  final String icon;
  final String level;
  final List<Lesson> lessons;
  final String track;
  final int? grade;
  final String? curriculumLabel;

  bool get isSchoolCourse => track == 'school';

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
      track: json['track'] as String? ?? 'skill',
      grade: (json['grade'] as num?)?.toInt(),
      curriculumLabel: json['curriculumLabel'] as String?,
    );
  }
}
