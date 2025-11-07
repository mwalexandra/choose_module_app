import 'package:firebase_database/firebase_database.dart';
import '../models/student.dart';

class StudentsService {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref().child('students');

  /// Текущий авторизованный студент (сессия)
  Student? currentStudent;

  // Helper для безопасного преобразования LinkedMap в Map<String, dynamic>
  Map<String, dynamic> _mapFromFirebase(dynamic value) {
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), _mapFromFirebase(val)));
    }
    return value;
  }

  // Создание студента
  Future<void> createStudent(Student student) async {
    await _dbRef.child(student.id).set(student.toJson());
  }

  // Получение всех студентов
  Future<List<Student>> getAllStudents() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final id = entry.key.toString();
        final json = _mapFromFirebase(entry.value);
        return Student.fromJson(id, json);
      }).toList();
    }
    return [];
  }

  // Получение студента по id
  Future<Student?> getStudentById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (snapshot.exists) {
      final json = _mapFromFirebase(snapshot.value);
      return Student.fromJson(id, json);
    }
    return null;
  }

  // Обновление студента
  Future<void> updateStudent(Student student) async {
    await _dbRef.child(student.id).update(student.toJson());

    // Если обновляем текущего студента, синхронизируем currentStudent
    if (currentStudent != null && currentStudent!.id == student.id) {
      currentStudent = student;
    }
  }

  // Удаление студента
  Future<void> deleteStudent(String id) async {
    await _dbRef.child(id).remove();

    // Если удаляем текущего студента, очищаем сессию
    if (currentStudent != null && currentStudent!.id == id) {
      currentStudent = null;
    }
  }
}
