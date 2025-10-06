import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ModuleRepository {
  static List<dynamic> _modulesCache = [];

  // Загрузить модули по специальности
  static Future<List<dynamic>> loadModules(String specialty) async {
    if (_modulesCache.isEmpty) {
      final data = await rootBundle.loadString('assets/data/modules.json');
      _modulesCache = jsonDecode(data);
    }

    final specialtyData = _modulesCache.firstWhere(
      (m) => m['specialty'] == specialty,
      orElse: () => null,
    );

    return specialtyData?['modules'] ?? [];
  }

  // Обновить выбор модуля
  static Future<void> toggleModule(String specialty, String moduleName) async {
    final specialtyData = _modulesCache.firstWhere(
      (m) => m['specialty'] == specialty,
      orElse: () => null,
    );

    if (specialtyData == null) return;

    for (var mod in specialtyData['modules']) {
      if (mod['name'] == moduleName) {
        mod['selected'] = !(mod['selected'] ?? false);
        break;
      }
    }
  }
}
