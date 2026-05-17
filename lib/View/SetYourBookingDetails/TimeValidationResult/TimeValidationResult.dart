class TimeValidationResult {
  final bool isValid;
  final String? errorMessage;

  TimeValidationResult({required this.isValid, this.errorMessage});
}

TimeValidationResult validateTime(String startTime, String endTime, DateTime? selectedDate) {
  final startParts = startTime.split(':').map(int.parse).toList();
  final endParts = endTime.split(':').map(int.parse).toList();

  final startMinutes = startParts[0] * 60 + startParts[1];
  int endMinutes = endParts[0] * 60 + endParts[1];

  // ✅ تجاوز منتصف الليل
  if (endMinutes <= startMinutes) {
    endMinutes += 24 * 60;
  }

  // ✅ فرق دقيقة واحدة على الأقل
  if (endMinutes - startMinutes < 1) {
    return TimeValidationResult(
      isValid: false,
      errorMessage: 'وقت الانتهاء يجب أن يكون بعد وقت البدء',
    );
  }

  // ✅ إذا اليوم الحالي، تحقق أن startTime بعد الآن
  if (selectedDate != null) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final selectedOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    if (selectedOnly == todayOnly) {
      final nowMinutes = now.hour * 60 + now.minute;

      // إذا startTime في اليوم التالي (تجاوز منتصف الليل)
      int adjustedStartMinutes = startMinutes;
      if (startMinutes < nowMinutes && (nowMinutes - startMinutes) > 12 * 60) {
        adjustedStartMinutes += 24 * 60;
      }

      if (adjustedStartMinutes <= nowMinutes) {
        return TimeValidationResult(
          isValid: false,
          errorMessage: 'وقت البدء يجب أن يكون بعد الوقت الحالي',
        );
      }
    }
  }

  return TimeValidationResult(isValid: true);
}

