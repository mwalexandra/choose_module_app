import 'package:flutter/material.dart';
import '../constants/app_styles.dart';
import '../constants/app_colors.dart';
import '../models/student.dart';
import '../services/students_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    final studentId = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (studentId.isEmpty || password.isEmpty) {
      _showSnackBar('Please fill in both fields', AppColors.error);
      return;
    }

    setState(() => _loading = true);

    try {
      final studentService = StudentsService();
      final Student? student = await studentService.getStudentById(studentId);

      if (student == null) {
        _showSnackBar('Student not found', AppColors.error);
        setState(() => _loading = false);
        return;
      }

      if (student.password != password) {
        _showSnackBar('Incorrect password', AppColors.error);
        setState(() => _loading = false);
        return;
      }

      studentService.currentStudent = student;

      setState(() => _loading = false);

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        '/modules',
        arguments: student,
      );
    } catch (e, stack) {
      debugPrint('🔥 Login error: $e');
      debugPrintStack(stackTrace: stack);
      _showSnackBar('Error: $e', AppColors.error);
      setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    final backgroundColor =
        isDark ? AppColors.darkBackgroundMain : AppColors.backgroundMain;
    final cardColor = isDark ? AppColors.darkCard : AppColors.card;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;

    return Scaffold(
      backgroundColor: backgroundColor,
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
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Student Login',
                      style: AppTextStyles.heading(isDark: isDark)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _idController,
                    style: AppTextStyles.body(isDark: isDark),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: textColor),
                      labelText: 'Student ID',
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackgroundSubtle
                          : AppColors.backgroundSubtle,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: AppTextStyles.body(isDark: isDark),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock, color: textColor),
                      labelText: 'Password',
                      labelStyle: TextStyle(color: textColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackgroundSubtle
                          : AppColors.backgroundSubtle,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text('Login', style: AppTextStyles.button()),
                      ),
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
