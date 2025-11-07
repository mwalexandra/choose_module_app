class Student {
  final String id;
  final String name;
  final String surname;
  final String kurs;
  final String password;
  final Map<String, List<String>> selectedModules;

  Student({
    required this.id,
    required this.name,
    required this.surname,
    required this.kurs,
    required this.password,
    required this.selectedModules,
  });

  // Преобразование из JSON (Firebase snapshot)
  factory Student.fromJson(String id, Map<String, dynamic> json) {
    final Map<String, List<String>> modules = {}; // <"wpm1", ["moduleId1", "moduleId2"]>

    final sm = json['selectedModules'] as Map?;
    sm?.forEach((key, value) {
      final list = (value as List?)?.map((e) => e.toString()).toList() ?? [];
      modules[key.toString()] = list;
    });

    return Student(
      id: id,
      name: json['name']?.toString() ?? '',
      surname: json['surname']?.toString() ?? '',
      kurs: json['kurs']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      selectedModules: modules,
    );
  }

  // Преобразование обратно в JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'kurs': kurs,
      'password': password,
      'selectedModules': selectedModules.map((key, value) => MapEntry(key, value)),
    };
  }
}
