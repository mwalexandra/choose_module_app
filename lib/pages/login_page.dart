import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../constants/app_styles.dart';

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

    final snapshot =
        await FirebaseDatabase.instance.ref('students/$studentId').get();

    if (!snapshot.exists) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Student not found'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    if (data['password'] != password) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: AppColors.secondary,
        ),
      );
      return;
    }

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundMain,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 500 ? 400 : screenWidth * 0.9,
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Student Login', style: AppTextStyles.heading),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundMain,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundMain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text('Login', style: AppTextStyles.button),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
