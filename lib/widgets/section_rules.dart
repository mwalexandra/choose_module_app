import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';

class SectionRules extends StatelessWidget {
  final VoidCallback onCompleted;
  final String chooseOpenDate;
  final String chooseCloseDate;

  const SectionRules({
    super.key,
    required this.onCompleted,
    required this.chooseOpenDate,
    required this.chooseCloseDate,
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
            "Information zu den Modulen:",
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          _buildRule(
            icon: Icons.check_circle_outline,
            text: "Wahl öffnet am: $chooseOpenDate",
          ),
          const SizedBox(height: 6),
          _buildRule(
            icon: Icons.check_circle_outline,
            text: "Frist der Wahl: $chooseCloseDate",
          ),
          const SizedBox(height: 6),
          _buildRule(
            icon: Icons.check_circle_outline,
            text:
                "Es gibt verbotene Wahlkombinationen. Wenn Sie eine solche wählen, erscheint eine entsprechende Meldung.",
          ),

          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Als erledigt kennzeichnen"),
          ),
        ],
      ),
    );
  }

  Widget _buildRule({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppColors.secondary, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTextStyles.body),
        ),
      ],
    );
  }
}
