import 'package:firebase_database/firebase_database.dart';
import '../models/student.dart';
import 'firebase_utils.dart';

class StudentsService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child('students');
  Student? currentStudent;

  Future<void> createStudent(Student student) async =>
      await _dbRef.child(student.id).set(student.toJson());

  Future<List<Student>> getAllStudents() async {
    final snapshot = await _dbRef.get();
    if (!snapshot.exists) return [];
    final data = Map<String, dynamic>.from(snapshot.value as Map);
    return data.entries.map((e) {
      final id = e.key.toString();
      final json = mapFromFirebase(e.value);
      return Student.fromJson(id, json);
    }).toList();
  }

  Future<Student?> getStudentById(String id) async {
    final snapshot = await _dbRef.child(id).get();
    if (!snapshot.exists) return null;
    final json = mapFromFirebase(snapshot.value);
    return Student.fromJson(id, json);
  }

  Future<void> updateStudent(Student student) async =>
      await _dbRef.child(student.id).update(student.toJson());
}
