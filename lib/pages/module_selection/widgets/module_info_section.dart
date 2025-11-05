import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../models/module.dart';
import '../../../models/semester.dart';
import '../../../services/modules_service.dart';

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

        if (!snapshot.hasData || snapshot.data == null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
              ],
            ),
            child: Text(
              'No module info available',
              style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor),
            ),
          );
        }

        final semester = snapshot.data!;
        final startDate = semester.chooseOpenDate ?? 'N/A';
        final endDate = semester.chooseCloseDate ?? 'N/A';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Module Selection Info',
                style: AppTextStyles.subheading(isDark: isDark).copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Text('Start Date: $startDate', style: AppTextStyles.body(isDark: isDark)),
              Text('End Date: $endDate', style: AppTextStyles.body(isDark: isDark)),
              const SizedBox(height: 12),
              ...semester.modules.map(
                (module) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('• ${module.name}', style: AppTextStyles.body(isDark: isDark)),
                      if (module.dozent != null)
                        Text('  Dozent: ${module.dozent}', style: AppTextStyles.body(isDark: isDark)),
                      if (module.participants != null)
                        Text('  Participants: ${module.participants}', style: AppTextStyles.body(isDark: isDark)),
                      if (module.description != null && module.description!.isNotEmpty)
                        Text('  Description: ${module.description}', style: AppTextStyles.body(isDark: isDark)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
