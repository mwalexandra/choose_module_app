import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/widgets/section_rules.dart';
import 'package:choose_module_app/widgets/section_confirm.dart';
import 'package:choose_module_app/widgets/section_modules.dart';
import '../services/data_helpers.dart';

class ModuleSelectionPage extends StatefulWidget {
  final String studentId;
  final String name;
  final String surname;

  const ModuleSelectionPage({
    Key? key,
    required this.studentId,
    required this.name,
    required this.surname,
  }) : super(key: key);

  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1;
  Student? currentStudent;
  Map<String, dynamic>? semestersMap;
  Set<String> selectedModules = {};
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1) загрузим студента
    final Student? student = await DataHelpers.getStudentById(widget.studentId);

    if (student == null) {
      // если студент не найден — вернём на логин
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // 2) загрузим specialty по имени специальности (строке)
    final Map<String, dynamic>? specialtyData =
        await DataHelpers.getSpecialtyByStudent(student.specialty);

    // 3) извлечём semesters безопасно
    Map<String, dynamic>? loadedSemesters;
    if (specialtyData != null) {
      final sems = specialtyData['semesters'];
      if (sems is Map) {
        loadedSemesters = Map<String, dynamic>.from(sems);
      }
    }

    // 4) установим состояние
    setState(() {
      currentStudent = student;
      semestersMap = loadedSemesters;
      final sel = student.selectedModules["wpm$selectedWPM"];
      selectedModules = (sel != null) ? {sel} : <String>{};
      confirmed = false;
    });
  }

  void _toggleModule(String moduleId) {
    setState(() {
      if (selectedModules.contains(moduleId)) {
        selectedModules.remove(moduleId);
      } else if (selectedModules.length < 2) {
        selectedModules.add(moduleId);
      } else {
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

    setState(() {
      currentStudent!.selectedModules["wpm$selectedWPM"] =
          selectedModules.isNotEmpty ? selectedModules.first : null;
      confirmed = true;
    });

    // TODO: сохранить изменения в файл или через API
    // например: await DataHelpers.updateSelectedModule(currentStudent!, selectedWPM, ...);
  }

  @override
  Widget build(BuildContext context) {
    // показываем лоадер, пока нет данных о студенте или семестрах
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
            // WPM-кнопки
            Row(
              children: List.generate(3, (index) {
                final int wpm = index + 1;
                final bool isSelected = selectedWPM == wpm;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? AppColors.secondary : AppColors.borderLight,
                      foregroundColor: AppColors.textPrimary,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.body,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm;
                        final sel = currentStudent?.selectedModules["wpm$selectedWPM"];
                        selectedModules = (sel != null) ? {sel} : <String>{};
                        confirmed = false;
                      });
                    },
                    child: Text("WPM $wpm"),
                  ),
                );
              }),
            ),

            // имя студента
            Text(
              "${widget.name} ${widget.surname}",
              style: AppTextStyles.body.copyWith(fontSize: 18),
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
            // Получаем данные семестра безопасно: semestersMap может иметь ключ 'wpm1' и т.д.
            SectionRules(
              chooseOpenDate: semestersMap!['wpm$selectedWPM']?['chooseOpenDate'] ?? '',
              chooseCloseDate:
                  semestersMap!['wpm$selectedWPM']?['chooseCloseDate'] ?? '',
              onCompleted: () => print("Als erledigt gekennzeichnet!"),
            ),
            const SizedBox(height: 20),

            SectionConfirm(
              studentId: currentStudent!.id,
              onConfirm: () {
                Navigator.pushNamed(context, '/confirmation');
              },
            ),
            const SizedBox(height: 20),

            SectionModules(
              semestersMap: semestersMap,
              selectedWPM: selectedWPM,
              selectedModuleIds: selectedModules,
              onModuleToggle: _toggleModule,
            ),
            const SizedBox(height: 20),

            if (selectedModules.length == 2 && !confirmed)
              ElevatedButton(
                onPressed: _confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  textStyle: AppTextStyles.button.copyWith(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                child: const Text("Wahl bestätigen"),
              ),
          ],
        ),
      ),
    );
  }
}
