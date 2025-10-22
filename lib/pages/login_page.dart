import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final studentId = _idController.text.trim();
    final password = _passwordController.text;

    if (studentId.isEmpty || password.isEmpty) return;

    setState(() => _loading = true);

    final snapshot = await FirebaseDatabase.instance
        .ref('students/$studentId')
        .get();

    if (!snapshot.exists) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student not found')),
      );
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    if (data['password'] != password) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password')),
      );
      return;
    }

    // Переходим на страницу выбора модулей
    setState(() => _loading = false);
    Navigator.pushReplacementNamed(
      context,
      '/modules',
      arguments: {
        'studentId': studentId,
        'name': data['name'] ?? '',
        'surname': data['surname'] ?? '',
        'specialty': data['specialty'] ?? '',
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _idController,
                      decoration: const InputDecoration(labelText: 'ID'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
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
