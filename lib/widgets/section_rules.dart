import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';

class SectionRules extends StatelessWidget {
  final VoidCallback onCompleted;
  final String chooseTime;

  const SectionRules({super.key, required this.onCompleted, this.chooseTime = "03.06.2026"});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundSubtle, 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section-Titel
          Text(
            "Information zu den Modulen: ",
            style: AppTextStyles.body.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          // Liste
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: AppColors.secondary, 
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text("Frist der Wahl: ", style: AppTextStyles.body),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$chooseTime',
                      style: AppTextStyles.body,
                      overflow: TextOverflow.ellipsis, 
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2), 
                    child: Icon(
                      Icons.check_circle_outline,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Es gibt verbotene Wahlkombinationen. Wenn Sie eine solche wählen, erscheint eine entsprechende Meldung.",
                      style: AppTextStyles.body,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          // Taste "Als erledigt kennzeichnen"
          ElevatedButton(
            onPressed: onCompleted,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              textStyle: AppTextStyles.button,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text("Als erledigt kennzeichnen"),
          ),
        ],
      ),
    );
  }
}
