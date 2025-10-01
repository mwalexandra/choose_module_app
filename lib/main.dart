import 'package:flutter/material.dart';
import 'pages/login_page.dart';
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
      title: 'Module Choose Page',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: '/login',
      
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginPage());

          case '/modules':
            final args = settings.arguments as Map<String, dynamic>?;
            final studentId = args?['userID'] ?? 'Unknown';
            return MaterialPageRoute(
              builder: (_) => ModuleSelectionPage(studentId: studentId),
            );

          //case '/confirmation':
          //  return MaterialPageRoute(builder: (_) => ConfirmationPage());

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(child: Text('Unknown route: ${settings.name}')),
              ),
            );
        }
      }
    );
  }
}
