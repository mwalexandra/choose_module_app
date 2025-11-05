import 'package:firebase_database/firebase_database.dart';
import '../models/coursemodules.dart';
import '../models/semester.dart';
import '../models/module.dart';
import '../services/date_helpers.dart';

class ModulesService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('modules');

  // Получение всех курсов
  Future<List<String>> getAllCourses() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.keys.map((k) => k.toString()).toList();
    }
    return [];
  }

  // Получение полного объекта CourseModules по курсу
  Future<CourseModules?> getCourseModules(String kurs) async {
    final snapshot = await _dbRef.child(kurs).get();
    if (!snapshot.exists) return null;

    final json = Map<String, dynamic>.from(snapshot.value as Map);
    return CourseModules.fromJson(kurs, json);
  }

  // Получение всех семестров курса как объектов Semester
  Future<List<Semester>> getSemesters(String kurs) async {
    final course = await getCourseModules(kurs);
    if (course == null) return [];
    return course.semesters.values.toList();
  }

  // Получение конкретного семестра
  Future<Semester?> getSemester(String kurs, String semesterId) async {
    final course = await getCourseModules(kurs);
    if (course == null) return null;
    return course.semesters[semesterId];
  }

  // Получение всех модулей семестра
  Future<List<Module>> getModules(String kurs, String semesterId) async {
    final semester = await getSemester(kurs, semesterId);
    if (semester == null) return [];
    return semester.modules;
  }

  // Поиск модуля по id
  Future<Module?> getModuleById(String kurs, String semesterId, String moduleId) async {
    final modules = await getModules(kurs, semesterId);
    try {
      return modules.firstWhere((m) => m.id == moduleId);
    } catch (e) {
      return null;
    }
  }

  // Обновление участников модуля
  Future<void> updateParticipants(String kurs, String semesterId, String moduleId, int count) async {
    final course = await getCourseModules(kurs);
    if (course == null) return;

    final semester = course.semesters[semesterId];
    if (semester == null) return;

    for (var module in semester.modules) {
      if (module.id == moduleId) {
        final updatedModule = Module(
          id: module.id,
          name: module.name,
          description: module.description,
          dozent: module.dozent,
          participants: count,
        );
        final index = semester.modules.indexOf(module);
        semester.modules[index] = updatedModule;
        break;
      }
    }

    // Сохраняем обратно в Firebase
    await _dbRef.child(kurs).child('semesters').child(semesterId).child('modules')
        .set(semester.modules.map((m) => m.toJson()).toList());
  }
}
