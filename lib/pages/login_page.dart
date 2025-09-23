import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _surnameController = TextEditingController();

  void _login() {
    final surname = _surnameController.text.trim();

    if (surname.isNotEmpty) {
  
      Navigator.pushNamed(
        context,
        '/modules',
        arguments: {'surname': surname},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Put your surname here')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authorisation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: 'Surname',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
