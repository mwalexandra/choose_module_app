import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userIDController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _userIDController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _userIDController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final userID = _userIDController.text.trim();
    final password = _passwordController.text.trim();

    // ignore: deprecated_member_use
    final databaseReference = FirebaseDatabase.instance.reference();
    final snapshot = await databaseReference.child('students').child(userID).once();

    if (snapshot.snapshot.value != null) {
      final studentData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      final studentPassword = studentData['password'];

      if (studentPassword == password) {
        // Навигация на страницу модулей с передачей studentId
        Navigator.pushReplacementNamed(
          context,
          '/modules',
          arguments: {
            'studentId': userID,
            'name': studentData['name'],
            'surname': studentData['surname'],
            'specialty': studentData['specialty'],
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _userIDController,
                decoration: const InputDecoration(labelText: "Student ID"),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter Student ID" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
                validator: (value) =>
                    value == null || value.isEmpty ? "Enter Password" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLogin,
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}