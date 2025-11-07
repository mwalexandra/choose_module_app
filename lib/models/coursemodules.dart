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

    final semestersJson = json['semesters'] as Map?;
    if (semestersJson != null) {
      semestersJson.forEach((key, value) {
        semMap[key.toString()] = Semester.fromJson(
          key.toString(),
          Map<String, dynamic>.from(value as Map),
        );
      });
    }

    return CourseModules(
      kurs: kurs,
      lastUpdate: DateHelpers.parseDate(json['lastUpdate']),
      semesters: semMap,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lastUpdate': DateHelpers.formatDate(lastUpdate),
      'semesters': semesters.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

}
