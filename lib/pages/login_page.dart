import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentIDController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {

    if (_formKey.currentState!.validate()) {
      final studentID = _studentIDController.text.trim();
      final password = _passwordController.text.trim();
      //TODO add authentication logic here
      print("Login: $studentID | Password: $password");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Put your student ID and password here')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _studentIDController,
                decoration: InputDecoration(labelText: "Student ID"),
                textInputAction: TextInputAction.next, // Enter → перейти к паролю
                validator: (value) =>
                    value!.isEmpty ? "Enter Student ID" : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                textInputAction: TextInputAction.done, // Enter → сабмит
                onFieldSubmitted: (_) => _login(), // обработчик Enter
                validator: (value) =>
                    value!.isEmpty ? "Enter Password" : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
            ],
          ),
        ),
          ],
        ),
      ),
    );
  }
}
