import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';

class SelectedModulesSection extends StatelessWidget {
  final List<Map<String, dynamic>> selectedModules;
  final bool hasChanges;
  final VoidCallback onConfirmSelection;

  const SelectedModulesSection({
    super.key,
    required this.selectedModules,
    required this.hasChanges,
    required this.onConfirmSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      color: isDark ? AppColors.darkBackgroundMain : AppColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: AppColors.borderLight.withOpacity(0.3),
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выбранные модули',
              style: AppTextStyles.subheading(isDark: isDark),
            ),
            const SizedBox(height: 10),
            if (selectedModules.isEmpty)
              Text(
                'Пока ничего не выбрано',
                style: AppTextStyles.body(isDark: isDark),
              )
            else
              Column(
                children: selectedModules.map((module) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      module['name'] ?? '',
                      style: AppTextStyles.body(isDark: isDark),
                    ),
                    subtitle: Text(
                      module['lecturer'] ?? '',
                      style: AppTextStyles.body(isDark: isDark),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: hasChanges ? onConfirmSelection : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasChanges
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 50),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Подтвердить выбор',
                  style: AppTextStyles.button(isDark: isDark),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
