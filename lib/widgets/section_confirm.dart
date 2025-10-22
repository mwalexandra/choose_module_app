import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';

class SectionConfirm extends StatelessWidget {
  final String studentId;
  final VoidCallback onConfirm;

  const SectionConfirm({
    super.key,
    required this.studentId,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
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
            "Bestätigung",
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Bitte bestätigen Sie Ihre Modulwahl.",
            style: AppTextStyles.body.copyWith(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              textStyle: AppTextStyles.button.copyWith(fontSize: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            child: const Text("Bestätigen"),
          ),
        ],
      ),
    );
  }
}
