import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/module_selection_page.dart';
//import 'pages/confirmation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
            final studentId = args?['studentId'];
            final name = args?['name'] ?? '';
            final surname = args?['surname'] ?? '';
            final specialty = args?['specialty'] ?? '';

            if (studentId == null) {
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(child: Text('Error: studentId is required')),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (_) => ModuleSelectionPage(
                studentId: studentId, 
                name: name, 
                surname: surname,
                specialty: specialty,
                ),
            );

          //case '/confirmation':
          //  return MaterialPageRoute(builder: (_) => ConfirmationPage());

          default:
            return MaterialPageRoute(builder: (_) => LoginPage());
        }
      }
    );
  }
}
