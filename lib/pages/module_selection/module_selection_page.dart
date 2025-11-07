// lib/screens/module_selection/module_selection_page.dart

import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/student.dart';
import '../../models/module.dart';
import '../../models/semester.dart';
import '../../services/modules_service.dart';
import '../../services/students_service.dart';
import 'widgets/student_header.dart';
import 'widgets/module_info_section.dart';
import 'widgets/selected_modules_section.dart';
import 'widgets/module_list_section.dart';

class ModuleSelectionPage extends StatefulWidget {
  final Student student;

  const ModuleSelectionPage({super.key, required this.student});

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  final ModulesService _modulesService = ModulesService();
  final StudentsService _studentsService = StudentsService();

  int selectedWpm = 1; // ui показывает 1..3
  bool loading = true;
  bool hasChanges = false;

  List<Module> availableModules = [];
  List<String> selectedModuleIds = [];
  List<Module> selectedModulesData = [];

  @override
  void initState() {
    super.initState();
    _loadModulesForCurrentWpm();
  }

  String get _wpmKey => 'wpm$selectedWpm';

  Future<void> _loadModulesForCurrentWpm() async {
    setState(() => loading = true);
    try {
      final kurs = widget.student.kurs;

      // Получаем Semester из курса по ключу
      final courseModules = await _modulesService.getCourse(kurs);
      if (courseModules == null) {
        debugPrint('❌ Не удалось загрузить курс "$kurs"');
        setState(() {
          availableModules = [];
          selectedModuleIds = [];
          selectedModulesData = [];
          hasChanges = false;
        });
        return;
      }

      final Semester? semester = courseModules.semesters[_wpmKey];
      final List<Module> modules = semester?.modules ?? [];

      final List<String> alreadySelected =
          widget.student.selectedModules[_wpmKey] ?? [];

      setState(() {
        availableModules = modules;
        selectedModuleIds = List<String>.from(alreadySelected);
        selectedModulesData =
            availableModules.where((m) => selectedModuleIds.contains(m.id)).toList();
        hasChanges = false;
      });
    } catch (e, st) {
      debugPrint('Error loading modules: $e\n$st');
      setState(() {
        availableModules = [];
        selectedModuleIds = [];
        selectedModulesData = [];
        hasChanges = false;
      });
    } finally {
      setState(() => loading = false);
    }
  }

  void _onSelectWpm(int wpm) {
    if (wpm == selectedWpm) return;
    setState(() => selectedWpm = wpm);
    _loadModulesForCurrentWpm();
  }

  void _onToggleSelection(String moduleId, bool isSelected) {
    setState(() {
      hasChanges = true;
      if (isSelected) {
        if (!selectedModuleIds.contains(moduleId)) selectedModuleIds.add(moduleId);
      } else {
        selectedModuleIds.remove(moduleId);
      }
      selectedModulesData =
          availableModules.where((m) => selectedModuleIds.contains(m.id)).toList();
    });
  }

  Future<void> _onConfirmSelection() async {
    final wpmKey = _wpmKey;
    widget.student.selectedModules[wpmKey] = selectedModuleIds;

    try {
      await _studentsService.updateStudent(widget.student);
      setState(() => hasChanges = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выбор успешно сохранён')),
      );
    } catch (e) {
      debugPrint('Error saving student selection: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final backgroundColor =
        isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth > 800 ? 800 : screenWidth),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StudentHeader(
                      student: widget.student,
                      selectedWpm: selectedWpm,
                      onSelectWpm: _onSelectWpm,
                    ),
                    const SizedBox(height: 24),
                    ModuleInfoSection(
                      kurs: widget.student.kurs,
                      selectedWpm: _wpmKey,
                    ),
                    const SizedBox(height: 24),
                    SelectedModulesSection(
                      selectedModules: selectedModulesData,
                      hasChanges: hasChanges,
                      onConfirmSelection: _onConfirmSelection,
                    ),
                    const SizedBox(height: 24),
                    ModuleListSection(
                      availableModules: availableModules,
                      selectedModuleIds: selectedModuleIds,
                      onToggleSelection: _onToggleSelection,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
