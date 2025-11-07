import 'package:firebase_database/firebase_database.dart';
import '../models/coursemodules.dart';
import '../models/semester.dart';
import '../services/date_helpers.dart';

class ModulesService {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('modules');

  // Получение всех курсов
  Future<List<CourseModules>> getAllCourses() async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists) return [];

    final data = snapshot.value as Map<dynamic, dynamic>;
    return data.entries.map((entry) {
      final kurs = entry.key.toString();
      final json = Map<String, dynamic>.from(entry.value);
      return CourseModules.fromJson(kurs, json);
    }).toList();
  }

  // Получение одного курса по ключу (например, "pi23")
  Future<CourseModules?> getCourse(String kurs) async {
    final snapshot = await _dbRef.child(kurs).get();
    if (!snapshot.exists) return null;

    final json = Map<String, dynamic>.from(snapshot.value as Map);
    return CourseModules.fromJson(kurs, json);
  }

  // 🔹 Новый метод — получение конкретного семестра
  Future<Semester?> getSemester(String kurs, String wpmKey) async {
    try {
      final course = await getCourse(kurs);
      if (course == null) {
        print("⚠️ [ModulesService] Курс '$kurs' не найден.");
        return null;
      }

      final semester = course.semesters[wpmKey];
      if (semester == null) {
        print("⚠️ [ModulesService] Семестр '$wpmKey' не найден в курсе '$kurs'.");
        return null;
      }

      return semester;
    } catch (e) {
      print("❌ [ModulesService] Ошибка при получении семестра '$wpmKey' для курса '$kurs': $e");
      return null;
    }
  }

  // Обновление количества участников модуля (если понадобится)
  Future<void> updateParticipants(
      String kurs, String semesterId, String moduleId, int newCount) async {
    try {
      await _dbRef
          .child(kurs)
          .child('semesters')
          .child(semesterId)
          .child('modules')
          .child(moduleId)
          .update({'participants': newCount});
    } catch (e) {
      print("❌ [ModulesService] Ошибка при обновлении участников: $e");
    }
  }
}
