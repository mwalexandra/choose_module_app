import '../services/date_helpers.dart';
import 'semester.dart';

class CourseModules {
  final String kurs;
  final DateTime lastUpdate;
  final Map<String, Semester> semesters;

  CourseModules({
    required this.kurs,
    required this.lastUpdate,
    required this.semesters,
  });

  factory CourseModules.fromJson(String kurs, Map<String, dynamic> json) {
    final semMap = <String, Semester>{};
    final semJson = json['semesters'] as Map? ?? {};

    semJson.forEach((key, value) {
      if (value is Map) {
        semMap[key.toString()] =
            Semester.fromJson(key.toString(), Map<String, dynamic>.from(value));
      }
    });

    return CourseModules(
      kurs: kurs,
      lastUpdate: DateHelpers.parseDate(json['lastUpdate']),
      semesters: semMap,
    );
  }

  Map<String, dynamic> toJson() {
    final semJson = <String, dynamic>{};
    semesters.forEach((key, value) {
      semJson[key] = value.toJson();
    });

    return {
      'lastUpdate': DateHelpers.formatDate(lastUpdate),
      'semesters': semJson,
    };
  }
}
