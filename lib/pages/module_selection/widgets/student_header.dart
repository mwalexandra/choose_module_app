import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';
import '../../../models/student.dart';

class StudentHeader extends StatelessWidget {
  final Student student;
  final int selectedWpm;
  final Function(int) onSelectWpm;

  const StudentHeader({
    super.key,
    required this.student,
    required this.selectedWpm,
    required this.onSelectWpm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    // Безопасное чтение данных (предотвращает ошибки типов или null)
    final studentName = (student.name.isNotEmpty) ? student.name : 'Unknown';
    final studentSurname = (student.surname.isNotEmpty) ? student.surname : '';
    final studentKurs = (student.kurs.isNotEmpty) ? student.kurs : 'No Course';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 400;

          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$studentName $studentSurname',
                style: AppTextStyles.heading(isDark: isDark).copyWith(color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                studentKurs,
                style: AppTextStyles.subheading(isDark: isDark).copyWith(color: textColor),
              ),
              const SizedBox(height: 8),
              Text(
                'Selected WPM: $selectedWpm',
                style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor),
              ),
            ],
          );

          final buttons = Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final wpm = i + 1;
              final isSelected = selectedWpm == wpm;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ElevatedButton(
                  onPressed: () => onSelectWpm(wpm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? AppColors.primary : AppColors.backgroundSubtle,
                    foregroundColor: isSelected ? Colors.white : AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('WPM $wpm'),
                ),
              );
            }),
          );

          return isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    info,
                    const SizedBox(height: 16),
                    buttons,
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [info, buttons],
                );
        },
      ),
    );
  }
}
