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
  final String specialty;

  const ModuleSelectionPage({
    super.key,
    required this.studentId,
    required this.name,
    required this.surname,
    required this.specialty,
  });

  @override
  State<ModuleSelectionPage> createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWpm = 1;
  Map<int, dynamic> wpmData = {};
  bool loading = true;
  //List<String> selectedModules = [];
  bool hasChanges = false;
  // 🔹 Все доступные модули из Firebase
  List<Map<String, dynamic>> availableModules = [];
   // 🔹 Список ID выбранных модулей (для чекбоксов)
  List<String> selectedModuleIds = [];
  // 🔹 Подробные данные о выбранных модулях (для секции "Выбранные модули")
  List<Map<String, dynamic>> selectedModulesData = [];

  @override
  void initState() {
    super.initState();
    _loadWpmData();
    _loadModules();
  }

  Future<void> _loadWpmData() async {
    final ref = FirebaseDatabase.instance.ref('students/${widget.studentId}/wpm');
    final snapshot = await ref.get();

    if (snapshot.exists) {
      final Map<String, dynamic> rawMap =
          Map<String, dynamic>.from(snapshot.value as Map);

      setState(() {
        wpmData = rawMap.map((key, value) => MapEntry(int.parse(key), value));
        loading = false;
      });
    } else {
      setState(() {
        wpmData = {};
        loading = false;
      });
    }
  }
  void _selectWpm(int wpm) => setState(() => selectedWpm = wpm);

  Future<void> _loadModules() async {
    setState(() => loading = true);

    final snapshot = await FirebaseDatabase.instance.ref('modules').get();
    if (snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.value as Map);
      availableModules = data.entries.map((entry) {
        final module = Map<String, dynamic>.from(entry.value);
        module['id'] = entry.key; // добавим ID для удобства
        return module;
      }).toList();
    }

    setState(() => loading = false);
  }

  // Вызывается при переключении чекбокса
  void _toggleModuleSelection(String moduleId, bool isSelected) {
    setState(() {
      hasChanges = true;

      if (isSelected) {
        selectedModuleIds.add(moduleId);
      } else {
        selectedModuleIds.remove(moduleId);
      }

      // Обновляем подробные данные выбранных модулей
      selectedModulesData = availableModules
          .where((module) => selectedModuleIds.contains(module['id'].toString()))
          .toList();
    });
  }

  // Нажатие кнопки "Подтвердить выбор"
  Future<void> _confirmSelection() async {
    // здесь запись выбранных модулей в Firebase
    final studentId = widget.studentId; // или как у тебя передаётся ID студента
    final ref = FirebaseDatabase.instance.ref('students/$studentId/selectedModules');

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
                      specialty: widget.specialty,
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
                      modules: availableModules,
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
