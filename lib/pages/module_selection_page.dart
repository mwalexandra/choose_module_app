import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/widgets/section_rules.dart';

class ModuleSelectionPage extends StatefulWidget {
  final String userSurname;

  const ModuleSelectionPage({Key? key, required this.userSurname}) : super(key: key);

  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1;
  List<dynamic> students = [];
  List<dynamic> modules = [];
  Map<String, dynamic>? currentStudent;
  Map<String, dynamic>? semestersMap;
  List<Map<String, dynamic>> availableModules = [];
  Set<String> selectedModules = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final studentsJson = await rootBundle.loadString('assets/data/students.json');
    final modulesJson = await rootBundle.loadString('assets/data/modules.json');

    final studentsData = json.decode(studentsJson);
    final modulesData = json.decode(modulesJson);

    setState(() {
      students = studentsData;
      modules = modulesData;

      currentStudent = students.firstWhere(
        (s) => s['surname'].toLowerCase() == widget.userSurname.toLowerCase(),
        orElse: () => null,
      );
    });

    // Найдём объект специальности в modules (в вашем JSON это элемент с "specialty")
    if (currentStudent != null) {
      final specialtyName = currentStudent!['specialty'];
      final specialtyData = modules.firstWhere(
        (m) => m['specialty'] == specialtyName,
        orElse: () => null,
      );

      if (specialtyData != null && specialtyData['semesters'] != null) {
        // Преобразуем в Map<String, dynamic> для удобного доступа
        semestersMap = Map<String, dynamic>.from(specialtyData['semesters']);
      }
    }

    _filterModules();
  }

  void _filterModules() {
    if (currentStudent == null) return;

    final specialty = currentStudent!['specialty'];

    setState(() {
      availableModules = modules
          .where((m) =>
              m['specialty'] == specialty && m['semester'] == selectedWPM)
          .map<Map<String, dynamic>>((m) => {
                'id': m['id'],
                'name': m['name'],
              })
          .toList();
    });
  }

  void _toggleModule(String moduleId) {
    setState(() {
      if (selectedModules.contains(moduleId)) {
        selectedModules.remove(moduleId);
      } else {
        selectedModules.add(moduleId);
      }
    });
  }

  void _confirmSelection() {
    Navigator.pushNamed(
      context,
      '/confirmation',
      arguments: {
        'surname': currentStudent?['surname'],
        'modules': selectedModules.toList(),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final semKey = 'wpm$selectedWPM';
    final chooseOpenDate = (semestersMap != null && semestersMap!.containsKey(semKey))
        ? (semestersMap![semKey] as Map<String, dynamic>)['chooseOpenDate']?.toString() ?? '—'
        : '—';
    final chooseCloseDate = (semestersMap != null && semestersMap!.containsKey(semKey))
        ? (semestersMap![semKey] as Map<String, dynamic>)['chooseCloseDate']?.toString() ?? '—'
        : '—';


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
                SizedBox(width: 8),
                Text("$selectedWPM",
                    style: AppTextStyles.body.copyWith(fontSize: 20)),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.body,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm;
                        _filterModules();
                      });
                    },
                    child: Text("$wpm"),
                  ),
                );
              }),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            // Секция правил
            SectionRules(
              chooseOpenDate: chooseOpenDate,
              chooseCloseDate: chooseCloseDate,
              onCompleted: () {
                print("Als erledigt kenngezeichnet!");
              },
            ),
            SizedBox(height: 20),

            // Список модулей
            availableModules.isEmpty
                ? Text("Нет доступных модулей для WPM $selectedWPM")
                : Column(
                    children: availableModules.map((module) {
                      final isSelected = selectedModules.contains(module['id']);
                      return ListTile(
                        title: Text(module['name'],
                            style: AppTextStyles.body),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: isSelected
                              ? AppColors.secondary
                              : AppColors.borderLight,
                        ),
                        onTap: () => _toggleModule(module['id']),
                      );
                    }).toList(),
                  ),

            SizedBox(height: 30),

            // Кнопка подтверждения выбора
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: AppTextStyles.button,
              ),
              onPressed: selectedModules.isEmpty ? null : _confirmSelection,
              child: Text("Wahl bestätigen"),
            ),
          ],
        ),
      ),
    );
  }
}
