import 'package:flutter/material.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';

class StudentHeader extends StatelessWidget {
  final String name;
  final String surname;
  final String specialty;
  final int selectedWpm;
  final Function(int) onSelectWpm;

  const StudentHeader({
    super.key,
    required this.name,
    required this.surname,
    required this.specialty,
    required this.selectedWpm,
    required this.onSelectWpm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 400;
          final info = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$name $surname', style: AppTextStyles.heading(isDark: isDark).copyWith(color: textColor)),
              const SizedBox(height: 4),
              Text(specialty, style: AppTextStyles.subheading(isDark: isDark).copyWith(color: textColor)),
              const SizedBox(height: 8),
              Text('Selected WPM: $selectedWpm', style: AppTextStyles.body(isDark: isDark).copyWith(color: textColor)),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('WPM $wpm'),
                ),
              );
            }),
          );

          return isMobile
              ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [info, const SizedBox(height: 16), buttons])
              : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [info, buttons]);
        },
      ),
    );
  }
}
