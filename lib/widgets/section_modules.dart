import 'package:flutter/material.dart';

class SectionModules extends StatelessWidget {
  final Map<String, dynamic>? semestersMap;
  final int selectedWPM;
  final Set<String> selectedModuleIds;
  final Function(String) onModuleToggle;

  const SectionModules({
    super.key,
    required this.semestersMap,
    required this.selectedWPM,
    required this.selectedModuleIds,
    required this.onModuleToggle,
  });

  @override
  Widget build(BuildContext context) {
    if (semestersMap == null) {
      return const Center(child: Text("Keine Module verfügbar"));
    }

    final semKey = 'wpm$selectedWPM';
    final semesterData = semestersMap![semKey] as Map<String, dynamic>?;

    if (semesterData == null || semesterData['modules'] == null) {
      return const Center(child: Text("Keine Module für diesen WPM verfügbar"));
    }

    final List<dynamic> modules = semesterData['modules'];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: modules.map((module) {
          final moduleId = module['id'] ?? '';
          final isSelected = selectedModuleIds.contains(moduleId);

          return GestureDetector(
            onTap: () => onModuleToggle(moduleId),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey),
                borderRadius: BorderRadius.circular(8),
                color: isSelected ? Colors.green.withOpacity(0.2) : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(module['name'] ?? ''),
                  Text("Dozent: ${module['dozent'] ?? '-'}"),
                  Text("ID: ${module['id'] ?? '-'}"),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
