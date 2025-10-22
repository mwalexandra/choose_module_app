import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/login_page.dart';
import 'pages/module_selection_page.dart';
// import 'pages/confirmation_page.dart';

// Конфигурация Firebase
const FirebaseOptions firebaseOptions = FirebaseOptions(
  apiKey: "AIzaSyDLj-MYa-lmMCwitrbSFzqunsG89DsMnb8",
  authDomain: "choose-module-app.firebaseapp.com",
  databaseURL: "https://choose-module-app-default-rtdb.firebaseio.com",
  projectId: "choose-module-app",
  storageBucket: "choose-module-app.firebasestorage.app",
  messagingSenderId: "262280266321",
  appId: "1:262280266321:web:0e81b381dc9e4ba74e2e70",
  measurementId: "G-SBESWR4C74",
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: firebaseOptions);
  runApp(const ModuleChooseApp());
}

class ModuleChooseApp extends StatelessWidget {
  const ModuleChooseApp({super.key});

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
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/modules':
            final args = settings.arguments as Map<String, dynamic>?;
            final studentId = args?['studentId'];
            final name = args?['name'] ?? '';
            final surname = args?['surname'] ?? '';
            final specialty = args?['specialty'] ?? '';

            if (studentId == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
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

          // case '/confirmation':
          //   return MaterialPageRoute(builder: (_) => ConfirmationPage());

          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
