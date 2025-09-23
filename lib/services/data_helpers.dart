import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Возвращает список объектов модулей для студента
Future<List<Map<String, dynamic>>> getSelectedModules(String studentId) async {
  final String studentsJson = await rootBundle.loadString('assets/data/students.json');
  final String modulesJson = await rootBundle.loadString('assets/data/modules.json');

  final List<dynamic> studentsData = json.decode(studentsJson);
  final List<dynamic> modulesData = json.decode(modulesJson);

  final student = studentsData.firstWhere(
    (s) => s['id'] == studentId,
    orElse: () => null,
  );

  if (student == null) return [];

  final selectedModulesMap = Map<String, dynamic>.from(student['selectedModules'] ?? {});

  final allModules = <Map<String, dynamic>>[];

  // собираем все модули из semesters
  for (var specialty in modulesData) {
    final semesters = Map<String, dynamic>.from(specialty['semesters'] ?? {});
    semesters.forEach((key, semesterData) {
      final modules = List<Map<String, dynamic>>.from(semesterData['modules'] ?? []);
      allModules.addAll(modules);
    });
  }

  // фильтруем только выбранные по WPM
  final selectedIds = selectedModulesMap.values.where((v) => v != null).map((v) => v.toString()).toList();

  return allModules.where((m) => selectedIds.contains(m['id'])).toList();
}
