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

  factory Student.fromJson(String id, Map<String, dynamic> json) {
    final modules = <String, List<String>>{};
    final rawModules = json['selectedModules'] as Map? ?? {};

    rawModules.forEach((key, value) {
      if (value is List) {
        modules[key.toString()] = value.map((e) => e.toString()).toList();
      } else if (value is Map) {
        modules[key.toString()] =
            value.values.map((e) => e.toString()).toList();
      }
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'kurs': kurs,
      'password': password,
      'selectedModules': selectedModules,
    };
  }
}
