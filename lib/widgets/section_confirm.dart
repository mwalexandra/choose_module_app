import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/services/data_helpers.dart';

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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: getSelectedModules(studentId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final modules = snapshot.data!;

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
              // Заголовок
              Text(
                "Ihre gewählten Module:",
                style: AppTextStyles.body.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Список выбранных модулей
              if (modules.isNotEmpty)
                Column(
                  children: modules.map((module) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bookmark, color: Colors.green, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${module['name']} – ${module['dozent']}",
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
              else
                Text(
                  "Noch keine Module ausgewählt.",
                  style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
                ),

              const SizedBox(height: 20),

              // Кнопка подтверждения
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
                child: const Text("Wahl bestätigen"),
              ),
            ],
          ),
        );
      },
    );
  }
}
