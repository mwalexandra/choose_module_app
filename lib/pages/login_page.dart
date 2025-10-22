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
  final _database = FirebaseDatabase.instance.ref("students");
  String? _errorMessage;
  bool _loading = false;

  Future<void> _login() async {
    setState(() {
      _errorMessage = null;
      _loading = true;
    });

    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = "Bitte ID und Passwort eingeben";
        _loading = false;
      });
      return;
    }

    try {
      // читаем запись студента по ID
      final snapshot = await _database.child(id).get();

      if (!snapshot.exists) {
        setState(() {
          _errorMessage = "Student nicht gefunden";
          _loading = false;
        });
        return;
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);

      if (data['password'] != password) {
        setState(() {
          _errorMessage = "Falsches Passwort";
          _loading = false;
        });
        return;
      }

      // вход успешен
      Navigator.pushNamed(
        context,
        '/modules',
        arguments: {
          'studentId': id,
          'name': data['name'] ?? '',
          'surname': data['surname'] ?? '',
          'specialty': data['specialty'] ?? '',
        },
      );
    } catch (e) {
      setState(() {
        _errorMessage = "Fehler beim Zugriff auf die Datenbank";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Login')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Bitte Student-ID und Passwort eingeben',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _idController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Student ID',
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Passwort',
                ),
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Anmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
