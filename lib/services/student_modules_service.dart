import 'students_service.dart';
import 'modules_service.dart';
import '../models/student.dart';
import '../models/module.dart';

class StudentModulesService {
  final StudentsService _studentsService = StudentsService();
  final ModulesService _modulesService = ModulesService();

  /// Получает все выбранные модули студента как объекты Module
  Future<List<Module>> getSelectedModules(Student student) async {
    List<Module> selected = [];

    for (final entry in student.selectedModules.entries) {
      final semesterId = entry.key; // "wpm1", "wpm2"...
      final moduleIds = entry.value;

      final modulesInSemester = await _modulesService.getModules(student.kurs, semesterId);

      for (var moduleId in moduleIds) {
        if (moduleId.isNotEmpty) {
          final module = modulesInSemester.firstWhere(
            (m) => m.id == moduleId,
            orElse: () => Module(id: '', name: '', description: '', dozent: '', participants: 0),
          );
          if (module.id.isNotEmpty) selected.add(module);
        }
      }
    }

    return selected;
  }

  /// Добавляет модуль в выбранные модули студента
  Future<void> addModule(Student student, String semesterId, Module module) async {
    final moduleIds = student.selectedModules[semesterId] ?? ["", ""];

    // Находим первый пустой слот
    for (int i = 0; i < moduleIds.length; i++) {
      if (moduleIds[i].isEmpty) {
        moduleIds[i] = module.id;
        break;
      }
    }

    student.selectedModules[semesterId] = moduleIds;
    await _studentsService.updateStudent(student);

    // Можно также увеличить счетчик участников
    final currentModule = await _modulesService.getModuleById(student.kurs, semesterId, module.id);
    if (currentModule != null) {
      await _modulesService.updateParticipants(
        student.kurs,
        semesterId,
        module.id,
        currentModule.participants + 1,
      );
    }
  }

  /// Удаляет модуль из выбранных модулей студента
  Future<void> removeModule(Student student, String semesterId, Module module) async {
    final moduleIds = student.selectedModules[semesterId] ?? [];

    for (int i = 0; i < moduleIds.length; i++) {
      if (moduleIds[i] == module.id) {
        moduleIds[i] = "";
        break;
      }
    }

    student.selectedModules[semesterId] = moduleIds;
    await _studentsService.updateStudent(student);

    // Можно также уменьшить счетчик участников
    final currentModule = await _modulesService.getModuleById(student.kurs, semesterId, module.id);
    if (currentModule != null && currentModule.participants > 0) {
      await _modulesService.updateParticipants(
        student.kurs,
        semesterId,
        module.id,
        currentModule.participants - 1,
      );
    }
  }
}
