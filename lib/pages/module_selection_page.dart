import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';


class ModuleSelectionPage extends StatefulWidget {

  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1; // Init WPM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      appBar: AppBar(
        title: Text("WPM $selectedWPM", style: AppTextStyles.heading), // Titel hängt von selectedWPM an
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // WPM-Wahl Tasten
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                int wpm = index + 1;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedWPM == wpm 
                      ? AppColors.secondary
                      : AppColors.borderLight,
                      foregroundColor: AppColors.textPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      textStyle: AppTextStyles.button,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm; // WPM erstellen
                      });
                    },
                    child: Text("$wpm"),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: AppTextStyles.button,
            ),
            onPressed: () => Navigator.pushNamed(context, '/confirmation'),
            child: Text("WPM Wahl bestätigen"),
            ),
          ],
        ),
      ),
    );
  }
}
