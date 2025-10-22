import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  final DatabaseReference _db = FirebaseDatabase.instance.ref();

  bool _loading = false;

  Future<void> _login() async {
    final studentId = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bitte ID und Passwort eingeben')));
      return;
    }

    setState(() => _loading = true);

    try {
      // Поиск студента по полю "id" (ключи 0,1,...)
      final snapshot = await _db
          .child('students')
          .orderByChild('id')
          .equalTo(studentId)
          .get();

      if (!snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student nicht gefunden')));
        setState(() => _loading = false);
        return;
      }

      // Преобразуем snapshot.value в Map<String, dynamic>
      final Map<String, dynamic> studentsMap =
          Map<String, dynamic>.from(snapshot.value as Map);
          
      // Получаем первый найденный объект
      final studentDataRaw = studentsMap.values.first;
      final studentData = Map<String, dynamic>.from(studentDataRaw);

      // Проверяем пароль
      if (studentData['password'] != password) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falsches Passwort')));
        setState(() => _loading = false);
        return;
      }

      // Переход на страницу выбора модулей
      Navigator.pushReplacementNamed(context, '/modules', arguments: {
        'studentId': studentId,
        'name': studentData['name'] ?? '',
        'surname': studentData['surname'] ?? '',
        'specialty': studentData['specialty'] ?? '',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')));
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _idController,
                decoration: const InputDecoration(labelText: 'Student ID'),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Passwort'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              _loading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Login'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
