import 'package:firebase_database/firebase_database.dart';
import '../models/coursemodules.dart';
import '../models/semester.dart';
import '../models/module.dart';
import '../services/date_helpers.dart';

class ModulesService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Получение данных курса по его названию (kurs)
  Future<CourseModules?> getCourseModules(String kurs) async {
    try {
      final snapshot = await _dbRef.child('courseModules').child(kurs).get();

      if (!snapshot.exists) {
        print('⚠️ Курс "$kurs" не найден в Firebase.');
        return null;
      }

      final rawValue = snapshot.value;

      // Проверка типа верхнего уровня
      if (rawValue is! Map) {
        print('❌ Ошибка типов: ожидался Map, получен ${rawValue.runtimeType}');
        print('Значение snapshot: $rawValue');
        return null;
      }

      final json = Map<String, dynamic>.from(rawValue as Map);

      // Проверка, что semesters — это Map
      if (json['semesters'] is! Map) {
        print('❌ Ошибка: в курсе "$kurs" поле "semesters" не является Map.');
        print('semesters: ${json['semesters']}');
        return null;
      }

      // Проверка каждого семестра
      final semestersJson = Map<String, dynamic>.from(json['semesters']);
      semestersJson.forEach((semId, semValue) {
        if (semValue is! Map) {
          print('⚠️ Семестр "$semId" имеет неверный тип: ${semValue.runtimeType}');
        }
      });

      final course = CourseModules.fromJson(kurs, json);
      print('✅ Успешно загружен курс "$kurs".');
      return course;
    } catch (e, stack) {
      print('🔥 Ошибка при загрузке курса "$kurs": $e');
      print(stack);
      return null;
    }
  }

  /// Сохранение курса в Firebase
  Future<void> saveCourseModules(CourseModules courseModules) async {
    try {
      await _dbRef
          .child('courseModules')
          .child(courseModules.kurs)
          .set(courseModules.toJson());

      print('✅ Курс "${courseModules.kurs}" успешно сохранён.');
    } catch (e, stack) {
      print('🔥 Ошибка при сохранении курса "${courseModules.kurs}": $e');
      print(stack);
    }
  }

  /// Проверка структуры данных всех курсов (для отладки)
  Future<void> debugAllCourses() async {
    try {
      final snapshot = await _dbRef.child('courseModules').get();

      if (!snapshot.exists) {
        print('⚠️ В базе данных нет курсов.');
        return;
      }

      final rawValue = snapshot.value;

      if (rawValue is! Map) {
        print('❌ Ошибка: ожидался Map, получен ${rawValue.runtimeType}');
        print(rawValue);
        return;
      }

      final allCourses = Map<String, dynamic>.from(rawValue);
      print('📚 Найдено курсов: ${allCourses.length}');
      for (final kurs in allCourses.keys) {
        final courseValue = allCourses[kurs];
        print('🔹 $kurs (${courseValue.runtimeType})');
      }
    } catch (e, stack) {
      print('🔥 Ошибка при отладке курсов: $e');
      print(stack);
    }
  }

  /// Обновляет поле participants для конкретного модуля и сохраняет изменения в Firebase
Future<void> updateParticipants(
    String kurs,
    String semesterId,
    String moduleId,
    int newCount,
  ) async {
  try {
    final course = await getCourseModules(kurs);
    if (course == null) {
      print('❌ updateParticipants: курс "$kurs" не найден.');
      return;
    }

    final semester = course.semesters[semesterId];
    if (semester == null) {
      print('❌ updateParticipants: семестр "$semesterId" не найден в курсе "$kurs".');
      return;
    }

    var found = false;
    for (var i = 0; i < semester.modules.length; i++) {
      final m = semester.modules[i];
      if (m.id == moduleId) {
        // создаём новый объект Module с обновлённым participants (immutable-safe)
        semester.modules[i] = Module(
          id: m.id,
          name: m.name,
          description: m.description,
          dozent: m.dozent,
          participants: newCount,
        );
        found = true;
        break;
      }
    }

    if (!found) {
      print('⚠️ updateParticipants: модуль "$moduleId" не найден в "$semesterId" ($kurs).');
      return;
    }

    // Сохраняем весь курс обратно
    await saveCourseModules(course);
    print('✅ updateParticipants: participants для "$moduleId" в "$semesterId" обновлён до $newCount.');
  } catch (e, stack) {
    print('🔥 Ошибка в updateParticipants для $kurs/$semesterId/$moduleId: $e');
    print(stack);
  }
}

}
