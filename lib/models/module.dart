class Module {
  final String id;
  final String name;
  final String description;
  final String dozent;
  final int participants;

  Module({
    required this.id,
    required this.name,
    required this.description,
    required this.dozent,
    required this.participants,
  });

  factory Module.fromJson(Map<String, dynamic> json) {
    return Module(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      dozent: json['dozent'] ?? '',
      participants: json['participants'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'dozent': dozent,
      'participants': participants,
    };
  }
}
