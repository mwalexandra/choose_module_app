import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';

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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Verfügbare Module (WPM $selectedWPM):",
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ...modules.map((module) {
            final moduleId = module['id'] ?? '';
            final isSelected = selectedModuleIds.contains(moduleId);

            return GestureDetector(
              onTap: () => onModuleToggle(moduleId),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.secondary.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.secondary : AppColors.borderLight,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module['name'] ?? "Unbekannt",
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Dozent: ${module['dozent'] ?? '-'}",
                      style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${module['id'] ?? '-'}",
                      style: AppTextStyles.body.copyWith(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
