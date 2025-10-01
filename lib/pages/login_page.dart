import 'package:flutter/material.dart';
import '../services/data_helpers.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      final students = await DataHelpers.loadStudents();
      final student = students.firstWhere(
        (s) => s.name == username,
        orElse: () => Student(name: "", password: ""),
      );

      if (student.name.isNotEmpty && student.password == password) {
        Navigator.pushReplacementNamed(context, "/modules");
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Неверные имя или пароль")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: "Имя студента"),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value!.isEmpty ? "Введите имя" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Пароль"),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
                validator: (value) =>
                    value!.isEmpty ? "Введите пароль" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLogin,
                child: Text("Войти"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
