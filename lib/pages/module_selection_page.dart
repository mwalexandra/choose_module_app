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
    // Загружаем студента
    final student = await DataHelpers.getStudentById(widget.studentId);

    if (student == null) {
      // Если студент не найден, возвращаем на login
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Загружаем специализацию и семестры
    final specialty = await DataHelpers.getSpecialtyByStudent(student.specialty);

    setState(() {
      currentStudent = student;
      semestersMap = specialty?['semesters'] ?? {};
      final sel = student.selectedModules["wpm$selectedWPM"];
      selectedModules = sel != null ? {sel} : {};
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

    // TODO: добавить сохранение изменений в файл или через API
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
            // Левая часть: WPM
            Row(
              children: [
                Text("WPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
                const SizedBox(width: 8),
                Text("$selectedWPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
              ],
            ),
            // Правая часть: имя + фамилия
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
            SectionRules(
              chooseOpenDate: semestersMap!['wpm$selectedWPM']?['chooseOpenDate'] ?? '',
              chooseCloseDate: semestersMap!['wpm$selectedWPM']?['chooseCloseDate'] ?? '',
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
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
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
