import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../models/module.dart';
import '../../../models/semester.dart';
import '../../../services/modules_service.dart';
import '../../../services/date_helpers.dart';

class ModuleInfoSection extends StatelessWidget {
  final String kurs;
  final String selectedWpm; // ключ семестра: "wpm1", "wpm2", "wpm3"

  const ModuleInfoSection({
    super.key,
    required this.kurs,
    required this.selectedWpm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;

    return FutureBuilder<Semester?>(
      future: ModulesService().getSemester(kurs, selectedWpm),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          debugPrint("⚠️ ModuleInfoSection error: ${snapshot.error}");
          return _buildInfoCard(
            context,
            isDark,
            cardColor,
            textColor,
            'Error loading module info',
          );
        }

        final semester = snapshot.data;
        if (semester == null) {
          debugPrint("⚠️ No semester found for kurs=$kurs, wpm=$selectedWpm");
          return _buildInfoCard(
            context,
            isDark,
            cardColor,
            textColor,
            'No module info available',
          );
        }

        // Безопасное форматирование дат
        final startDate = DateHelpers.formatDate(semester.chooseOpenDate);
        final endDate = DateHelpers.formatDate(semester.chooseCloseDate);

        // Проверка списка модулей
        final modules = semester.modules.isNotEmpty ? semester.modules : <Module>[];

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Selection Info',
                style: AppTextStyles.subheading(isDark: isDark)
                    .copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Text('Start Date: $startDate',
                  style: AppTextStyles.body(isDark: isDark)
                      .copyWith(color: textColor)),
              Text('End Date: $endDate',
                  style: AppTextStyles.body(isDark: isDark)
                      .copyWith(color: textColor)),
              const SizedBox(height: 12),
              if (modules.isEmpty)
                Text(
                  'No modules available for this semester',
                  style: AppTextStyles.body(isDark: isDark)
                      .copyWith(color: textColor),
                )
              else
                ...modules.map(
                  (module) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: _buildModuleInfo(module, isDark, textColor),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    bool isDark,
    Color cardColor,
    Color textColor,
    String message,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Text(
        message,
        style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor),
      ),
    );
  }

  Widget _buildModuleInfo(Module module, bool isDark, Color textColor) {
    final description = module.description?.trim().isNotEmpty == true
        ? module.description
        : 'No description';
    final dozent = module.dozent?.trim().isNotEmpty == true
        ? module.dozent
        : 'N/A';
    final participants = module.participants ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ${module.name}',
            style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor)),
        Text('  Dozent: $dozent',
            style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor)),
        Text('  Participants: $participants',
            style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor)),
        Text('  Description: $description',
            style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor)),
      ],
    );
  }
}
