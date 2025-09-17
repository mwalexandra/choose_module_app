import 'package:flutter/material.dart';
import 'package:choose_module_app/constants/app_styles.dart';

class ModuleSelectionPage extends StatefulWidget {
  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1; // init WPM

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
            // Titel + WPM number
            Row(
              children: [
                Text(
                  "WPM",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "$selectedWPM",
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            // WPM Wahltasten
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
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
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
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            textStyle: AppTextStyles.button,
          ),
          onPressed: () => Navigator.pushNamed(context, '/confirmation'),
          child: Text("Wahl bestätigen"),
        ),
      ),
    );
  }
}
