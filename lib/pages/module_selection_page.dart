import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/widgets/section_rules.dart';
import 'package:choose_module_app/widgets/section_confirm.dart';
import 'package:choose_module_app/widgets/section_modules.dart';
import 'package:choose_module_app/services/data_helpers.dart';
import 'package:flutter/services.dart' show rootBundle;

class ModuleSelectionPage extends StatefulWidget {
  final String userSurname;

  const ModuleSelectionPage({Key? key, required this.userSurname}) : super(key: key);

  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1;

  Map<String, dynamic>? currentStudent;
  Map<String, dynamic>? semestersMap;
  Set<String> selectedModules = {};
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final String studentsJson = await rootBundle.loadString('assets/data/students.json');
    final List<dynamic> studentsData = json.decode(studentsJson);

    final student = studentsData.firstWhere(
      (s) => s['surname'] == widget.userSurname,
      orElse: () => null,
    );

    if (student != null) {
      setState(() {
        currentStudent = student;
        selectedModules = student['selectedModules']['wpm$selectedWPM'] != null
            ? {student['selectedModules']['wpm$selectedWPM']}
            : {};
      });
    }

    final String modulesJson = await rootBundle.loadString('assets/data/modules.json');
    final List<dynamic> modulesData = json.decode(modulesJson);

    final specialty = modulesData.firstWhere(
      (m) => m['specialty'] == currentStudent?['specialty'],
      orElse: () => null,
    );

    if (specialty != null) {
      setState(() {
        semestersMap = Map<String, dynamic>.from(specialty['semesters']);
      });
    }
  }

  void _toggleModule(String moduleId) {
  setState(() {
    if (selectedModules.contains(moduleId)) {
      // снимаем выбор
      selectedModules.remove(moduleId);
    } else if (selectedModules.length < 2) {
      // можно выбрать только если меньше 2 модулей
      selectedModules.add(moduleId);
    } else {
      // показываем подсказку пользователю (необязательно)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Sie können maximal 2 Module auswählen."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  });
}

  Future<void> _confirmSelection() async {
    if (currentStudent == null) return;

    // Обновляем локальный объект
    setState(() {
      currentStudent!['selectedModules']['wpm$selectedWPM'] = selectedModules.isNotEmpty
          ? selectedModules.first
          : null;
      confirmed = true;
    });

    // TODO: тут можно реализовать запись обратно в JSON на сервере / локально
    // Например, через API или local storage
  }

  @override
  Widget build(BuildContext context) {
    if (currentStudent == null || semestersMap == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("WPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
                const SizedBox(width: 8),
                Text("$selectedWPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
              ],
            ),
            Row(
              children: List.generate(3, (index) {
                int wpm = index + 1;
                bool isSelected = selectedWPM == wpm;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppColors.secondary
                          : AppColors.borderLight,
                      foregroundColor: AppColors.textPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.body,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm;
                        // обновляем выбранные модули при смене WPM
                        final sel = currentStudent!['selectedModules']['wpm$selectedWPM'];
                        selectedModules = sel != null ? {sel} : {};
                        confirmed = false;
                      });
                    },
                    child: Text("$wpm"),
                  ),
                );
              }),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Секция с правилами
            SectionRules(
              chooseOpenDate: semestersMap!['wpm$selectedWPM']?['chooseOpenDate'] ?? '',
              chooseCloseDate: semestersMap!['wpm$selectedWPM']?['chooseCloseDate'] ?? '',
              onCompleted: () {
                print("Als erledigt gekennzeichnet!");
              },
            ),
            const SizedBox(height: 20),

            // Секция с модулями
            SectionModules(
              semestersMap: semestersMap,
              selectedWPM: selectedWPM,
              selectedModuleIds: selectedModules,
              onModuleToggle: _toggleModule,
            ),
            const SizedBox(height: 20),

            // Секция подтверждения выбора (только если выбраны 2 модуля)
            if (selectedModules.length == 2 && !confirmed)
              ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text("Wahl bestätigen"),
              ),


            const SizedBox(height: 20),

            // Секция отображения выбранных модулей после подтверждения
            if (confirmed)
              SectionConfirm(
                studentId: currentStudent!['id'],
                onConfirm: () {
                  Navigator.pushNamed(context, '/confirmation');
                },
              ),
          ],
        ),
      ),
    );
  }
}
