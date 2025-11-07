import 'module.dart';
import '../services/date_helpers.dart';

class Semester {
  final String id;
  final DateTime chooseOpenDate;
  final DateTime chooseCloseDate;
  final List<Module> modules;

  Semester({
    required this.id,
    required this.chooseOpenDate,
    required this.chooseCloseDate,
    required this.modules,
  });

  factory Semester.fromJson(String id, Map<String, dynamic> json) {
    final modulesList = (json['modules'] as List?)
            ?.map((e) => Module.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return Semester(
      id: id,
      chooseOpenDate: DateHelpers.parseDate(json['chooseOpenDate']),
      chooseCloseDate: DateHelpers.parseDate(json['chooseCloseDate']),
      modules: modulesList,
    );
  }

  Map<String, dynamic> toJson() => {
        'chooseOpenDate': DateHelpers.formatDate(chooseOpenDate),
        'chooseCloseDate': DateHelpers.formatDate(chooseCloseDate),
        'modules': modules.map((m) => m.toJson()).toList(),
      };
}
