import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'pages/login_page.dart';
import 'pages/module_selection/module_selection_page.dart';
import 'models/student.dart';

/// Конфигурация Firebase
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
      title: 'Module Selection',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());

          case '/modules':
            final args = settings.arguments as Map<String, dynamic>?;

            // Проверяем аргументы
            if (args == null || args['student'] == null) {
              return MaterialPageRoute(
                builder: (_) => const Scaffold(
                  body: Center(child: Text('Ошибка: отсутствуют данные студента')),
                ),
              );
            }

            final student = args['student'] as Student;

            return MaterialPageRoute(
              builder: (_) => ModuleSelectionPage(
                student: student,
              ),
            );

          default:
            return MaterialPageRoute(builder: (_) => const LoginPage());
        }
      },
    );
  }
}
