class DateHelpers {
  
  static DateTime parseDate(String date) {
    final parts = date.split('.');
    return DateTime(
      int.parse(parts[2]),
      int.parse(parts[1]),
      int.parse(parts[0]),
    );
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
           '${date.month.toString().padLeft(2, '0')}.'
           '${date.year}';
  }
}