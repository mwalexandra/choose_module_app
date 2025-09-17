import 'package:flutter/material.dart';

class ModuleSelectionPage extends StatelessWidget {
  final int wpmNumber;

  ModuleSelectionPage({required this.wpmNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("WPM $wpmNumber"), 
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/confirmation'),
          child: Text("Wahl bestätigen"),
        ),
      ),
    );
  }
}
