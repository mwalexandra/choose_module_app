import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';
import 'package:choose_module_app/widgets/section_rules.dart';

class ModuleSelectionPage extends StatefulWidget {
  
@override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text("WPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
                SizedBox(width: 8),
                Text("$selectedWPM", style: AppTextStyles.body.copyWith(fontSize: 20)),
              ],
            ),
            Row(
              children: List.generate(3, (index) {
                int wpm = index + 1;
                bool isSelected = selectedWPM == wpm;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppColors.secondary
                          : AppColors.borderLight,
                      foregroundColor: AppColors.textPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: AppTextStyles.body,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm;
                      });
                    },
                    child: Text("$wpm"),
                  ),
                );
              }),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Container(
            color: Colors.black,
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Секция с текстом и списком
            SectionRules(
              onCompleted: () {
                print("Als erledigt kenngezeichnet!");
              },
            ),
            SizedBox(height: 20),
            // Кнопка подтверждения выбора
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: AppTextStyles.button,
              ),
              onPressed: () => Navigator.pushNamed(context, '/confirmation'),
              child: Text("Wahl bestätigen"),
            ),
          ],
        ),
      ),
    );
  }
}
