import 'package:flutter/material.dart';
// import 'pages/login_page.dart';
import 'pages/module_selection_page.dart';
import 'pages/confirmation_page.dart';

void main() {
  runApp(ModuleChooseApp());
}

class ModuleChooseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Module Choose',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/modules',
      routes: {
//        '/login': (context) => LoginPage(),
        '/modules': (context) => ModuleSelectionPage(),
        '/confirmation': (context) => ConfirmationPage(),
      },
    );
  }
}
