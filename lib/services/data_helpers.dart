import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// --------- MODELS ----------

class Student {
  final String id;
  final String password;
  final String name;
  final String surname;
  final int startYear;
  final String specialty;
  final Map<String, String?> selectedModules;

  Student({
    required this.id,
    required this.password,
    required this.selectedModules,
    required this.name,
    required this.surname,
    required this.startYear,
    required this.specialty,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      password: json['password'],
      selectedModules: Map<String, String?>.from(json['selectedModules'] ?? {}),
      name: json['name'],
      surname: json['surname'],
      startYear: json['startYear'],
      specialty: json['specialty'],
    );
  }
}

class Module {
  final String id;
  final String name;
  final String dozent;

  Module({
    required this.id,
    required this.name,
    required this.dozent,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'],
      name: json['name'],
      dozent: json['dozent'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "dozent": dozent,
      };
}

class Semester {
  final String chooseOpenDate;
  final String chooseCloseDate;
  final List<Module> modules;

  Semester({
    required this.chooseOpenDate,
    required this.chooseCloseDate,
    required this.modules,
  });

  factory Semester.fromJson(Map<String, dynamic> json) {
    return Semester(
      chooseOpenDate: json['chooseOpenDate'],
      chooseCloseDate: json['chooseCloseDate'],
      modules: (json['modules'] as List<dynamic>)
          .map((m) => Module.fromJson(m))
          .toList(),
    );
  }
}

class Specialty {
  final String specialty;
  final String lastUpdate;
  final Map<String, Semester> semesters;

  Specialty({
    required this.specialty,
    required this.lastUpdate,
    required this.semesters,
  });

  factory Specialty.fromJson(Map<String, dynamic> json) {
    final rawSemesters = Map<String, dynamic>.from(json['semesters'] ?? {});
    final parsedSemesters = rawSemesters.map((key, value) =>
        MapEntry(key, Semester.fromJson(Map<String, dynamic>.from(value))));

    return Specialty(
      specialty: json['specialty'],
      lastUpdate: json['lastUpdate'],
      semesters: parsedSemesters,
    );
  }
}

/// --------- HELPERS ----------

class DataHelpers {
  /// Загружает JSON как список объектов
  static Future<List<dynamic>> _loadJson(String path) async {
    final String response = await rootBundle.loadString(path);
    return json.decode(response) as List<dynamic>;
  }

  /// Загружаем студентов
  static Future<List<Student>> loadStudents() async {
    final data = await _loadJson('assets/data/students.json');
    return data.map((s) => Student.fromJson(s)).toList();
  }

  /// Загружаем все специальности с семестрами и модулями
  static Future<List<Specialty>> loadSpecialties() async {
    final data = await _loadJson('assets/data/modules.json');
    return data.map((s) => Specialty.fromJson(s)).toList();
  }

  /// Найти студента по ID
  static Future<Student?> getStudentById(String id) async {
    final students = await loadStudents();
    return students.firstWhere(
      (s) => s.id == id,
      orElse: () => Student(id: "", password: "", selectedModules: {}, name: '', surname: '', startYear: 0, specialty: ''),
    );
  }

  // Получение данных о специальности студента (specialty)
  static Future<Map<String, dynamic>?> getSpecialtyByStudent(String specialty) async {
    final String modulesJson =
        await rootBundle.loadString('assets/data/modules.json');
    final List<dynamic> modulesData = json.decode(modulesJson);

    final specialtyData = modulesData.firstWhere(
      (m) => m['specialty'] == specialty,
      orElse: () => null,
    );

    return specialtyData != null ? Map<String, dynamic>.from(specialtyData) : null;
  }

  /// Получить все модули (без фильтрации)
  static Future<List<Module>> getAllModules() async {
    final specialties = await loadSpecialties();
    final modules = <Module>[];
    for (var spec in specialties) {
      for (var semester in spec.semesters.values) {
        modules.addAll(semester.modules);
      }
    }
    return modules;
  }

  /// Получить выбранные модули конкретного студента
  static Future<List<Module>> getSelectedModules(String studentId) async {
    final student = await getStudentById(studentId);
    if (student == null || student.id.isEmpty) return [];

    final selectedIds = student.selectedModules.values
        .where((id) => id != null)
        .map((id) => id.toString())
        .toList();

    final allModules = await getAllModules();
    return allModules.where((m) => selectedIds.contains(m.id)).toList();
  }

  /// Получить модули по WPM (например "wpm1")
  static Future<List<Module>> getModulesByWPM(String wpm) async {
    final specialties = await loadSpecialties();
    final modules = <Module>[];
    for (var spec in specialties) {
      if (spec.semesters.containsKey(wpm)) {
        modules.addAll(spec.semesters[wpm]!.modules);
      }
    }
    return modules;
  }
}
