import 'students_service.dart';
import 'modules_service.dart';
import '../models/student.dart';
import '../models/module.dart';

class StudentModulesService {
  final StudentsService _studentsService = StudentsService();
  final ModulesService _modulesService = ModulesService();

  /// Получает все выбранные модули студента как объекты [Module].
  Future<List<Module>> getSelectedModules(Student student) async {
    final List<Module> selectedModules = [];

    if (student.kurs.isEmpty) {
      print('⚠️ У студента "${student.name}" не указан курс.');
      return selectedModules;
    }

    if (student.selectedModules.isEmpty) {
      print('ℹ️ У студента "${student.name}" пока нет выбранных модулей.');
      return selectedModules;
    }

    for (final entry in student.selectedModules.entries) {
      final semesterId = entry.key;
      final moduleIds = entry.value;

      if (semesterId.isEmpty) {
        print('⚠️ Пропущен семестр без ID у студента ${student.id}');
        continue;
      }

      final course = await _modulesService.getCourse(student.kurs);
      if (course == null) {
        print('❌ Не удалось загрузить курс "${student.kurs}" для студента ${student.id}');
        continue;
      }

      final semester = course.semesters[semesterId];
      if (semester == null) {
        print('⚠️ Семестр "$semesterId" не найден в курсе "${student.kurs}".');
        continue;
      }

      for (final moduleId in moduleIds) {
        if (moduleId.isEmpty) continue;

        try {
          final module = semester.modules.firstWhere(
            (m) => m.id == moduleId,
            orElse: () => Module(
              id: '',
              name: '',
              description: '',
              dozent: '',
              participants: 0,
            ),
          );

          if (module.id.isNotEmpty) {
            selectedModules.add(module);
          } else {
            print('⚠️ Модуль "$moduleId" не найден в "$semesterId" (${student.kurs})');
          }
        } catch (e) {
          print('🔥 Ошибка при поиске модуля "$moduleId" в "$semesterId": $e');
        }
      }
    }

    print('✅ Успешно получены выбранные модули студента "${student.name}".');
    return selectedModules;
  }

  /// Добавляет модуль в выбранные модули студента
  Future<void> addModule(Student student, String semesterId, Module module) async {
    if (student.kurs.isEmpty) {
      print('❌ Ошибка: у студента "${student.name}" не указан курс.');
      return;
    }

    final moduleIds = student.selectedModules[semesterId] ?? ["", ""];
    bool added = false;

    for (int i = 0; i < moduleIds.length; i++) {
      if (moduleIds[i].isEmpty) {
        moduleIds[i] = module.id;
        added = true;
        break;
      }
    }

    if (!added) {
      print('⚠️ Нельзя добавить больше 2 модулей для "$semesterId" (${student.kurs}).');
      return;
    }

    student.selectedModules[semesterId] = moduleIds;

    await _studentsService.updateStudent(student);

    // Увеличиваем счётчик участников
    final course = await _modulesService.getCourse(student.kurs);
    if (course == null) {
      print('❌ Ошибка: курс "${student.kurs}" не найден при добавлении модуля.');
      return;
    }

    final semester = course.semesters[semesterId];
    if (semester == null) {
      print('⚠️ Семестр "$semesterId" не найден в курсе "${student.kurs}".');
      return;
    }

    final currentModule = semester.modules.firstWhere(
      (m) => m.id == module.id,
      orElse: () => Module(id: '', name: '', description: '', dozent: '', participants: 0),
    );

    if (currentModule.id.isNotEmpty) {
      await _modulesService.updateParticipants(
        student.kurs,
        semesterId,
        module.id,
        currentModule.participants + 1,
      );
      print('✅ Добавлен модуль "${module.name}" студенту "${student.name}".');
    } else {
      print('⚠️ Модуль "${module.id}" не найден для обновления участников.');
    }
  }

  /// Удаляет модуль из выбранных модулей студента
  Future<void> removeModule(Student student, String semesterId, Module module) async {
    if (student.kurs.isEmpty) {
      print('❌ Ошибка: у студента "${student.name}" не указан курс.');
      return;
    }

    final moduleIds = student.selectedModules[semesterId] ?? [];
    bool removed = false;

    for (int i = 0; i < moduleIds.length; i++) {
      if (moduleIds[i] == module.id) {
        moduleIds[i] = "";
        removed = true;
        break;
      }
    }

    if (!removed) {
      print('⚠️ Модуль "${module.id}" не найден у студента "${student.name}".');
      return;
    }

    student.selectedModules[semesterId] = moduleIds;
    await _studentsService.updateStudent(student);

    // Уменьшаем счётчик участников
    final course = await _modulesService.getCourse(student.kurs);
    if (course == null) {
      print('❌ Ошибка: курс "${student.kurs}" не найден при удалении модуля.');
      return;
    }

    final semester = course.semesters[semesterId];
    if (semester == null) {
      print('⚠️ Семестр "$semesterId" не найден в курсе "${student.kurs}".');
      return;
    }

    final currentModule = semester.modules.firstWhere(
      (m) => m.id == module.id,
      orElse: () => Module(id: '', name: '', description: '', dozent: '', participants: 0),
    );

    if (currentModule.id.isNotEmpty && currentModule.participants > 0) {
      await _modulesService.updateParticipants(
        student.kurs,
        semesterId,
        module.id,
        currentModule.participants - 1,
      );
      print('✅ Модуль "${module.name}" удалён у студента "${student.name}".');
    }
  }
}
