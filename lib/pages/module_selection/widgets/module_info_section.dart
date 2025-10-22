import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../constants/app_styles.dart';
import '../../../constants/app_colors.dart';

class ModuleInfoSection extends StatelessWidget {
  final int selectedWpm;
  const ModuleInfoSection({super.key, required this.selectedWpm});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;

    return FutureBuilder<DatabaseEvent>(
      future: FirebaseDatabase.instance.ref('modules/$selectedWpm/info').once(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError || snapshot.data!.snapshot.value == null) {
          return Text('No module info available', style: AppTextStyles.body(isDark: isDark));
        }

        final data = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);
        final startDate = data['startDate'] ?? 'N/A';
        final endDate = data['endDate'] ?? 'N/A';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Module Selection Info', style: AppTextStyles.subheading(isDark: isDark).copyWith(color: textColor)),
              const SizedBox(height: 8),
              Text('Start Date: $startDate', style: AppTextStyles.body(isDark: isDark)),
              Text('End Date: $endDate', style: AppTextStyles.body(isDark: isDark)),
            ],
          ),
        );
      },
    );
  }
}
