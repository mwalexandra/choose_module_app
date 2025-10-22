import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../constants/app_colors.dart';
import 'widgets/student_header.dart';
import 'widgets/module_info_section.dart';
import 'widgets/selected_modules_section.dart';
import 'widgets/module_list_section.dart';

class ModuleSelectionPage extends StatefulWidget {
  final String studentId;
  final String name;
  final String surname;
  final String kurs;

  const ModuleSelectionPage({
    super.key,
    required this.studentId,
    required this.name,
    required this.surname,
    required this.kurs,
  });

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWpm = 1;
  Map<String, dynamic> semestersData = {};
  bool loading = true;
  bool hasChanges = false;

  List<Map<String, dynamic>> availableModules = [];
  List<String> selectedModuleIds = [];
  List<Map<String, dynamic>> selectedModulesData = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  void _selectWpm(int wpm) {
    setState(() {
      selectedWpm = wpm;
      _filterModulesByWpm();
    });
  }

  /// Загружает все модули курса студента
  Future<void> _loadModules() async {
    setState(() => loading = true);

    try {
      final kurs = widget.kurs;
      final semestersRef = FirebaseDatabase.instance.ref('modules/$kurs/semesters');
      final studentModulesRef = FirebaseDatabase.instance
          .ref('students/${widget.studentId}/selectedModules');

      // Получаем все семестры курса
      final semestersSnapshot = await semestersRef.get();
      Map<String, dynamic> semestersMap = {};
      if (semestersSnapshot.exists && semestersSnapshot.value != null) {
        semestersMap = Map<String, dynamic>.from(semestersSnapshot.value as Map);
      }

      // Получаем выбранные модули студента
      final studentModulesSnapshot = await studentModulesRef.get();
      Map<String, dynamic> studentModulesMap = {};
      if (studentModulesSnapshot.exists && studentModulesSnapshot.value != null) {
        studentModulesMap = Map<String, dynamic>.from(studentModulesSnapshot.value as Map);
      }

      setState(() {
        semestersData = semestersMap;
      });

      // После загрузки данных фильтруем модули по WPM и отмечаем выбранные
      _filterModulesByWpm(studentModulesMap);
    } catch (e) {
      debugPrint('Ошибка при загрузке модулей: $e');
      setState(() {
        semestersData = {};
        availableModules = [];
        selectedModuleIds = [];
        selectedModulesData = [];
      });
    }

    setState(() => loading = false);
  }

  /// Фильтрует модули по выбранному WPM и отмечает уже выбранные
  void _filterModulesByWpm([Map<String, dynamic>? studentModulesMap]) {
    final wpmKey = 'wpm$selectedWpm';
    final modulesList = (semestersData[wpmKey]?['modules'] as List?)
            ?.map((m) => Map<String, dynamic>.from(m as Map))
            .toList() ??
        [];

    // Подгружаем уже выбранные модули студента, если есть
    final alreadySelected = List<String>.from(
        studentModulesMap?[wpmKey] ?? []
    );

    setState(() {
      availableModules = modulesList;
      selectedModuleIds = alreadySelected;
      selectedModulesData = availableModules
          .where((module) => selectedModuleIds.contains(module['id'].toString()))
          .toList();
      hasChanges = false;
    });
  }

  void _toggleModuleSelection(String moduleId, bool isSelected) {
    setState(() {
      hasChanges = true;
      if (isSelected) {
        selectedModuleIds.add(moduleId);
      } else {
        selectedModuleIds.remove(moduleId);
      }
      selectedModulesData = availableModules
          .where((module) => selectedModuleIds.contains(module['id'].toString()))
          .toList();
    });
  }

  Future<void> _confirmSelection() async {
    final studentId = widget.studentId;
    final ref = FirebaseDatabase.instance
        .ref('students/$studentId/selectedModules/wpm$selectedWpm');

    await ref.set(selectedModuleIds);

    setState(() {
      hasChanges = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Выбор успешно сохранён')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundColor = isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth > 600 ? 600 : screenWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StudentHeader(
                      name: widget.name,
                      surname: widget.surname,
                      kurs: widget.kurs,
                      selectedWpm: selectedWpm,
                      onSelectWpm: _selectWpm,
                    ),
                    const SizedBox(height: 24),
                    ModuleInfoSection(selectedWpm: selectedWpm),
                    const SizedBox(height: 24),
                    SelectedModulesSection(
                      selectedModules: selectedModulesData,
                      hasChanges: hasChanges,
                      onConfirmSelection: _confirmSelection,
                    ),
                    const SizedBox(height: 24),
                    ModuleListSection(
                      availableModules: availableModules,
                      selectedModuleIds: selectedModuleIds,
                      onToggleSelection: _toggleModuleSelection,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
