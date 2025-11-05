import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/student.dart';
import '../../services/modules_service.dart';
import '../../services/students_service.dart';
import 'widgets/student_header.dart';
import 'widgets/module_info_section.dart';
import 'widgets/selected_modules_section.dart';
import 'widgets/module_list_section.dart';

class ModuleSelectionPage extends StatefulWidget {
  final Student student;

  const ModuleSelectionPage({
    super.key,
    required this.student,
  });

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  final ModulesService _modulesService = ModulesService();
  final StudentsService _studentsService = StudentsService();

  int selectedWpm = 1;
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

  Future<void> _loadModules() async {
    setState(() => loading = true);

    try {
      final kurs = widget.student.kurs;
      final semesters = await _modulesService.getSemesters(kurs);
      final wpmKey = 'wpm$selectedWpm';

      // Находим семестр с нужным WPM
      final semesterList = semesters.where((s) => s.id == wpmKey).toList();
      final semester = semesterList.isNotEmpty ? semesterList.first : null;

      final modules = semester?.modules ?? [];

      final studentModules = widget.student.selectedModules[wpmKey]?.where((id) => id.isNotEmpty).toList() ?? [];

      setState(() {
        availableModules = modules.map((m) => m.toJson()).toList();
        selectedModuleIds = studentModules;
        selectedModulesData = modules
            .where((m) => selectedModuleIds.contains(m.id))
            .map((m) => m.toJson())
            .toList();
        hasChanges = false;
      });
    } catch (e) {
      debugPrint('Ошибка при загрузке модулей: $e');
      setState(() {
        availableModules = [];
        selectedModuleIds = [];
        selectedModulesData = [];
        hasChanges = false;
      });
    }

    setState(() => loading = false);
  }

  void _filterModulesByWpm() {
    final wpmKey = 'wpm$selectedWpm';

    final modules = availableModules;
    final alreadySelected = widget.student.selectedModules[wpmKey]?.where((id) => id.isNotEmpty).toList() ?? [];

    setState(() {
      selectedModuleIds = alreadySelected;
      selectedModulesData = modules.where((m) => selectedModuleIds.contains(m['id'])).toList();
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
      selectedModulesData = availableModules.where((m) => selectedModuleIds.contains(m['id'])).toList();
    });
  }

  Future<void> _confirmSelection() async {
    final wpmKey = 'wpm$selectedWpm';
    widget.student.selectedModules[wpmKey] = selectedModuleIds;
    await _studentsService.updateStudent(widget.student);

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
                      student: widget.student,
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
