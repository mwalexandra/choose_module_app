import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

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
  Set<String> selectedModules = {};
  Map<String, dynamic>? semestersData;
  bool confirmed = false;

  @override
  void initState() {
    super.initState();
    _loadSemesters();
    _loadSelectedModules();
  }

  Future<void> _loadSemesters() async {
    final snapshot = await _db.child('modules').get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    final specialtyData = (data['modules'] as List)
        .firstWhere((m) => m['specialty'] == widget.specialty, orElse: () => null);
    if (specialtyData != null) {
      setState(() {
        semestersData = Map<String, dynamic>.from(specialtyData['semesters']);
      });
    }
  }

  Future<void> _loadSelectedModules() async {
    final snapshot =
        await _db.child('students/${widget.studentId}/modules/wpm$selectedWPM').get();
    if (!snapshot.exists) return;

    final data = snapshot.value as Map<dynamic, dynamic>;
    setState(() {
      selectedModules = {};
      if ((data['module1'] ?? '').isNotEmpty) selectedModules.add(data['module1']);
      if ((data['module2'] ?? '').isNotEmpty) selectedModules.add(data['module2']);
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
              content: Text("Maximal 2 Module auswählen"), duration: Duration(seconds: 2)),
        );
      }
    });
  }

  Future<void> _confirmSelection() async {
    final updated = {
      'module1': selectedModules.isNotEmpty ? selectedModules.elementAt(0) : '',
      'module2': selectedModules.length > 1 ? selectedModules.elementAt(1) : '',
    };
    await _db
        .child('students/${widget.studentId}/modules/wpm$selectedWPM')
        .set(updated);

    setState(() => confirmed = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Auswahl gespeichert"), duration: Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (semestersData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final modules =
        (semestersData!['wpm$selectedWPM']?['modules'] as List<dynamic>? ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.name} ${widget.surname}"),
      ),
      body: Column(
        children: [
          // WPM Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final wpm = index + 1;
              final selected = selectedWPM == wpm;
              return Padding(
                padding: const EdgeInsets.all(4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: selected ? Colors.green : Colors.grey),
                  onPressed: () async {
                    setState(() {
                      selectedWPM = wpm;
                      confirmed = false;
                    });
                    await _loadSelectedModules();
                  },
                  child: Text('WPM $wpm'),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                final moduleId = module['id'] as String;
                final selected = selectedModules.contains(moduleId);
                return ListTile(
                  title: Text(module['name'] ?? ''),
                  subtitle: Text(module['dozent'] ?? ''),
                  trailing: Checkbox(
                    value: selected,
                    onChanged: (_) => _toggleModule(moduleId),
                  ),
                );
              },
            ),
          ),

          ElevatedButton(
            onPressed: selectedModules.isNotEmpty ? _confirmSelection : null,
            child: const Text("Wahl bestätigen"),
          ),
        ],
      ),
    );
  }
}
