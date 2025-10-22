import 'package:firebase_database/firebase_database.dart';

// ignore: deprecated_member_use
final databaseReference = FirebaseDatabase.instance.ref();

void createStudent(String studentId, String name, String surname, String specialty) {
  databaseReference.child('students').child(studentId).set({
    'name': name,
    'surname': surname,
    'specialty': specialty,
  });
}

Future<Map<String, dynamic>> getStudent(String studentId) async {
  final event = await databaseReference.child('students').child(studentId).once();
  final snapshot = event.snapshot;
  if (snapshot.value != null) {
    return Map<String, dynamic>.from(snapshot.value as Map);
  } else {
    throw Exception('Student not found');
  }
}

void updateStudent(String studentId, Map<String, dynamic> updates) {
  databaseReference.child('students').child(studentId).update(updates);
}

void deleteStudent(String studentId) {
  databaseReference.child('students').child(studentId).remove();
}