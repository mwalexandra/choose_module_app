import 'package:flutter/material.dart';

class ModuleSelectionPage extends StatefulWidget {

  @override
  _ModuleSelectionPageState createState() => _ModuleSelectionPageState();
}

class _ModuleSelectionPageState extends State<ModuleSelectionPage> {
  int selectedWPM = 1; // Init WPM

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WPM $selectedWPM"), // Titel hängt von selectedWPM an
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
                      backgroundColor: selectedWPM == wpm ? Colors.blue : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        selectedWPM = wpm; // Erstellen WPM
                      });
                    },
                    child: Text("$wpm"),
                  ),
                );
              }),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/confirmation'),
              child: Text("WPM Wahl bestätigen"),
            ),
          ],
        ),
      ),
    );
  }
}
