import 'package:flutter/material.dart';
import '../services/data_helpers.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
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
    if (_formKey.currentState!.validate()) {
      final userID = _userIDController.text.trim();
      final password = _passwordController.text.trim();

      print("userID=$userID password=$password"); // отладка

      final students = await DataHelpers.loadStudents();
      final student = students.firstWhere(
        (s) => s.id == userID,
        orElse: () => Student(id: "", password: "", selectedModules: {}, name: '', surname: '', startYear: 0, specialty: ''),
      );

      if (student.id.isNotEmpty && student.password == password) {
        context.go(
          "/modules/${student.id}/${student.name}/${student.surname}",
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Student not found or incorrect password")),
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
                controller: _userIDController,
                decoration: InputDecoration(labelText: "Student ID"),
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    value!.isEmpty ? "Enter Student ID" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submitLogin(),
                validator: (value) =>
                    value!.isEmpty ? "Enter Password" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitLogin,
                child: Text("Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
