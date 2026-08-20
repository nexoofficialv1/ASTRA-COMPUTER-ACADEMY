import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/course.dart';

class ContentRepository {
  List<Course>? _coreCache;
  List<Course>? _schoolCache;
  List<Course>? _allCache;

  Future<List<Course>> loadCourses() async {
    if (_coreCache != null) return _coreCache!;

    _coreCache = await _loadAsset('assets/content/curriculum.json');
    return _coreCache!;
  }

  Future<List<Course>> loadSchoolCourses() async {
    if (_schoolCache != null) return _schoolCache!;

    _schoolCache = await _loadAsset('assets/content/class5_cursor_pro.json');
    return _schoolCache!;
  }

  Future<List<Course>> loadAllCourses() async {
    if (_allCache != null) return _allCache!;

    final results = await Future.wait([
      loadCourses(),
      loadSchoolCourses(),
    ]);
    _allCache = <Course>[
      ...results[0],
      ...results[1],
    ];
    return _allCache!;
  }

  Future<List<Course>> _loadAsset(String assetPath) async {
    final raw = await rootBundle.loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return (decoded['courses'] as List<dynamic>)
        .map((item) => Course.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
