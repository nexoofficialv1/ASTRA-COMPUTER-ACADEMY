import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class ContentRepository {
  List<Course>? _cache;

  Future<List<Course>> loadCourses() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString('assets/content/curriculum.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final courses = (decoded['courses'] as List<dynamic>)
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();

    _cache = courses;
    return courses;
  }
}
