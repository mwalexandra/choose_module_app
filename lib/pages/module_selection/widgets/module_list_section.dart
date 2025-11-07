import 'package:flutter/material.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_styles.dart';
import '../../../models/module.dart';

class ModuleListSection extends StatelessWidget {
  final List<Module> availableModules;
  final List<String> selectedModuleIds;
  final Function(String moduleId, bool isSelected) onToggleSelection;

  const ModuleListSection({
    super.key,
    required this.availableModules,
    required this.selectedModuleIds,
    required this.onToggleSelection,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Список модулей',
          style: AppTextStyles.subheading(isDark: isDark),
        ),
        const SizedBox(height: 10),
        ...availableModules.map((module) {
          final moduleId = module.id;
          final isSelected = selectedModuleIds.contains(moduleId);

          return Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackgroundMain : AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderLight.withAlpha(100),
              ),
              boxShadow: [
                if (!isDark)
                  const BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
              ],
            ),
            child: ExpansionTile(
              title: Row(
                children: [
                  Checkbox(
                    value: isSelected,
                    onChanged: (value) {
                      onToggleSelection(moduleId, value ?? false);
                    },
                    activeColor: AppColors.primary,
                  ),
                  Expanded(
                    child: Text(
                      module.name.isNotEmpty ? module.name : 'Без названия',
                      style: AppTextStyles.body(isDark: isDark),
                    ),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(left: 52),
                child: Text(
                  'Участников: ${module.participants}',
                  style: AppTextStyles.body(isDark: isDark),
                ),
              ),
              childrenPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.description.isNotEmpty
                            ? module.description
                            : 'Нет описания',
                        style: AppTextStyles.body(isDark: isDark),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Доцент: ${module.dozent.isNotEmpty ? module.dozent : '—'}',
                        style: AppTextStyles.body(isDark: isDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
