import 'package:firebase_database/firebase_database.dart';
import '../models/coursemodules.dart';
import '../models/semester.dart';
import '../models/module.dart';
import '../services/date_helpers.dart';

class ModulesService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules');

  // Helper: безопасное преобразование LinkedMap в Map<String, dynamic>
  Map<String, dynamic> _mapFromFirebase(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _mapFromFirebase(val)));
    }
    return value;
  }

  // Получение всех курсов
  Future<List<String>> getAllCourses() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map?;
      return data?.keys.map((k) => k.toString()).toList() ?? [];
    }
    return [];
  }

  // Получение полного объекта CourseModules по курсу
  Future<CourseModules?> getCourseModules(String kurs) async {
    final snapshot = await _dbRef.child(kurs).get();
    if (!snapshot.exists) return null;

    final json = _mapFromFirebase(snapshot.value);
    return CourseModules.fromJson(kurs, json);
  }

  // Получение всех семестров курса
  Future<List<Semester>> getSemesters(String kurs) async {
    final course = await getCourseModules(kurs);
    if (course == null) return [];
    return course.semesters.values.toList();
  }

  // Получение конкретного семестра
  Future<Semester?> getSemester(String kurs, String semesterId) async {
    final course = await getCourseModules(kurs);
    return course?.semesters[semesterId];
  }

  // Получение всех модулей семестра
  Future<List<Module>> getModules(String kurs, String semesterId) async {
    final semester = await getSemester(kurs, semesterId);
    return semester?.modules ?? [];
  }

  // Поиск модуля по id
  Future<Module?> getModuleById(String kurs, String semesterId, String moduleId) async {
    final modules = await getModules(kurs, semesterId);
    try {
      return modules.firstWhere((m) => m.id == moduleId);
    } catch (_) {
      return null;
    }
  }

  // Обновление участников модуля
  Future<void> updateParticipants(String kurs, String semesterId, String moduleId, int count) async {
    final course = await getCourseModules(kurs);
    if (course == null) return;

    final semester = course.semesters[semesterId];
    if (semester == null) return;

    for (var i = 0; i < semester.modules.length; i++) {
      if (semester.modules[i].id == moduleId) {
        semester.modules[i] = Module(
          id: semester.modules[i].id,
          name: semester.modules[i].name,
          description: semester.modules[i].description,
          dozent: semester.modules[i].dozent,
          participants: count,
        );
        break;
      }
    }

    // Сохраняем обратно в Firebase
    await _dbRef
        .child(kurs)
        .child('semesters')
        .child(semesterId)
        .child('modules')
        .set(semester.modules.map((m) => m.toJson()).toList());
  }
}
