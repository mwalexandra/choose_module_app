import 'semester.dart';
import '../services/date_helpers.dart';

class CourseModules {
  final String kurs; // bspw. "pi23"
  final DateTime lastUpdate;
  final Map<String, Semester> semesters;

  CourseModules({
    required this.kurs,
    required this.lastUpdate,
    required this.semesters,
  });

  factory CourseModules.fromJson(String kurs, Map<String, dynamic> json) {
    final semMap = <String, Semester>{};
    final semestersJson = json['semesters'] as Map<String, dynamic>;

    semestersJson.forEach((key, value) {
      semMap[key] = Semester.fromJson(key, Map<String, dynamic>.from(value));
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
