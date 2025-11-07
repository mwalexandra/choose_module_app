/// Универсальная функция безопасного преобразования данных Firebase в Map<String, dynamic>
Map<String, dynamic> mapFromFirebase(dynamic value) {
  if (value == null) return {};
  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), mapFromFirebase(v)));
  }
  if (value is List) {
    return {'list': value.map(mapFromFirebase).toList()};
  }
  return {'value': value};
}
