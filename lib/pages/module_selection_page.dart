import 'package:flutter/material.dart';

class ModuleSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Выбор модулей")),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, '/confirmation'),
          child: Text("Перейти к подтверждению"),
        ),
      ),
    );
  }
}
