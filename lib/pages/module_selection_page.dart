import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/widgets/section_rules.dart';
import 'package:choose_module_app/widgets/section_confirm.dart';
import 'package:choose_module_app/widgets/section_modules.dart';

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
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  int selectedWPM = 1;
  Map<String, dynamic>? semestersMap;
  Set<String> selectedModules = {};
  bool confirmed = false;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    try {
      // Данные студента
      final studentSnap =
          await _db.child('students/${widget.studentId}').get();

      if (!studentSnap.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student is not found.')),
        );
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      final studentData =
          Map<String, dynamic>.from(studentSnap.value as Map<dynamic, dynamic>);

      // Данные специальности
      final specialtySnap =
          await _db.child('specialties/${widget.specialty}').get();

      Map<String, dynamic>? specialtyData;
      if (specialtySnap.exists) {
        specialtyData =
            Map<String, dynamic>.from(specialtySnap.value as Map<dynamic, dynamic>);
      }

      Map<String, dynamic>? loadedSemesters;
      if (specialtyData != null && specialtyData['semesters'] != null) {
        loadedSemesters =
            Map<String, dynamic>.from(specialtyData['semesters'] as Map);
      }

      // Получаем выбранные модули
      final sel = studentData['selectedModules']?['wpm$selectedWPM'];
      final selected = (sel is List)
          ? Set<String>.from(sel.map((e) => e.toString()))
          : <String>{};

      setState(() {
        semestersMap = loadedSemesters;
        selectedModules = selected;
        confirmed = false;
        loading = false;
      });
    } catch (e) {
      debugPrint("Error loading data: $e");
      setState(() => loading = false);
    }
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
            content: Text("You can select a maximum of 2 modules."),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  Future<void> _confirmSelection() async {
    try {
      await _db
          .child('students/${widget.studentId}/selectedModules/wpm$selectedWPM')
          .set(selectedModules.toList());

      setState(() {
        confirmed = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your selection has been saved."),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint("Error saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error saving."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (semestersMap == null) {
      return const Scaffold(
        body: Center(child: Text('No data found')),
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
                    onPressed: () async {
                      setState(() {
                        selectedWPM = wpm;
                        confirmed = false;
                        loading = true;
                      });
                      await _loadStudentData();
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
            SectionRules(
              chooseOpenDate:
                  semestersMap!['wpm$selectedWPM']?['chooseOpenDate'] ?? '',
              chooseCloseDate:
                  semestersMap!['wpm$selectedWPM']?['chooseCloseDate'] ?? '',
              onCompleted: () => print("Marked as completed!"),
            ),
            const SizedBox(height: 20),

            SectionConfirm(
              studentId: widget.studentId,
              onConfirm: () => _confirmSelection(),
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
                child: const Text("Confirm selection"),
              ),
          ],
        ),
      ),
    );
  }
}
