import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../widgets/section_modules.dart';
import '../widgets/section_rules.dart';

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
  Map<String, dynamic>? modulesData; // Модули по специальности
  Set<String> selectedModules = {};
  bool loading = true;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final snapshot = await FirebaseDatabase.instance
        .ref('modules/${widget.specialty}')
        .get();

    if (!snapshot.exists) {
      setState(() => loading = false);
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    // Загружаем выбранные модули студента
    final studentSnap = await FirebaseDatabase.instance
        .ref('students/${widget.studentId}/modules')
        .get();

    Set<String> initialSelection = {};
    if (studentSnap.exists) {
      final wpmMap =
          Map<String, dynamic>.from(studentSnap.value as Map)['wpm$selectedWPM'] ?? <String>[];
      if (wpmMap is List) {
        initialSelection = wpmMap.whereType<String>().where((s) => s.isNotEmpty).toSet();
      }
    }

    setState(() {
      modulesData = data;
      selectedModules = initialSelection;
      loading = false;
    });
  }

  void _toggleModule(String moduleId) {
    setState(() {
      if (selectedModules.contains(moduleId)) {
        selectedModules.remove(moduleId);
      } else if (selectedModules.length < 2) {
        selectedModules.add(moduleId);
      }
    });
  }

  Future<void> _confirmSelection() async {
    final toSave = selectedModules.toList();
    while (toSave.length < 2) toSave.add("");

    await FirebaseDatabase.instance
        .ref('students/${widget.studentId}/modules/wpm$selectedWPM')
        .set(toSave);

    setState(() {
      confirmed = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Auswahl gespeichert")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading || modulesData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.name} ${widget.surname}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SectionRules(
              chooseOpenDate: modulesData!['wpm$selectedWPM']?['chooseOpenDate'] ?? '',
              chooseCloseDate: modulesData!['wpm$selectedWPM']?['chooseCloseDate'] ?? '',
              onCompleted: () {},
            ),
            const SizedBox(height: 20),
            SectionModules(
              semestersMap: modulesData,
              selectedWPM: selectedWPM,
              selectedModuleIds: selectedModules,
              onModuleToggle: _toggleModule,
            ),
            const SizedBox(height: 20),
            if (selectedModules.length == 2 && !confirmed)
              ElevatedButton(
                onPressed: _confirmSelection,
                child: const Text("Wahl bestätigen"),
              ),
            const SizedBox(height: 20),
            // WPM переключение
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) {
                final wpm = i + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () async {
                      // сохраняем текущие выбранные перед сменой WPM
                      await _confirmSelection();
                      // переключаем WPM
                      final studentSnap = await FirebaseDatabase.instance
                          .ref('students/${widget.studentId}/modules/wpm$wpm')
                          .get();
                      Set<String> newSelection = {};
                      if (studentSnap.exists) {
                        final list = studentSnap.value as List<dynamic>;
                        newSelection = list
                            .whereType<String>()
                            .where((s) => s.isNotEmpty)
                            .toSet();
                      }
                      setState(() {
                        selectedWPM = wpm;
                        selectedModules = newSelection;
                        confirmed = false;
                      });
                    },
                    child: Text('WPM $wpm'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
