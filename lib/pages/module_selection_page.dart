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
  int selectedWPM = 1;
  Map<String, dynamic>? semestersMap;
  Set<String> selectedModules = {};
  bool confirmed = false;

  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  Future<void> _loadStudentData() async {
    final studentSnap = await dbRef.child('students/${widget.studentId}').get();
    if (!studentSnap.exists) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    final studentData = Map<String, dynamic>.from(studentSnap.value as Map);

    // Загружаем модули по specialty
    final modulesSnap = await dbRef
        .child('modules')
        .orderByChild('specialty')
        .equalTo(widget.specialty)
        .get();

    if (!modulesSnap.exists) return;
    final specialtyData = Map<String, dynamic>.from(modulesSnap.children.first.value as Map);
    final sems = specialtyData['semesters'] as Map<dynamic, dynamic>;
    final loadedSemesters = sems.map((k, v) => MapEntry(k.toString(), Map<String, dynamic>.from(v)));

    setState(() {
      semestersMap = loadedSemesters;
      final sel = studentData['modules']?['wpm$selectedWPM'] ?? [];
      selectedModules = Set<String>.from(List<String>.from(sel));
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
    if (semestersMap == null) return;

    await dbRef.child('students/${widget.studentId}/modules/wpm$selectedWPM')
        .set(selectedModules.toList());

    setState(() {
      confirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Ihre Auswahl wurde gespeichert."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (semestersMap == null) {
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
              children: List.generate(3, (index) {
                final wpm = index + 1;
                final isSelected = selectedWPM == wpm;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
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
                        selectedModules = Set<String>.from(
                          semestersMap!['wpm$wpm']['selectedModules'] ?? []
                        );
                        confirmed = false;
                      });
                    },
                    child: Text("WPM $wpm"),
                  ),
                );
              }),
            ),
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
