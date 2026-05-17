class DateTimeHelper {
  static String extractTime(String dateTime) {
    if (dateTime.isEmpty) return "";

    // ✅ إذا كان فيه T أو - يعني ISO format
    if (dateTime.contains("T") || dateTime.contains("-")) {
      final cleaned = dateTime.replaceAll("T", " ").replaceAll("Z", "").split(".")[0];
      final parts = cleaned.split(" ");
      if (parts.isEmpty) return "";

      // التاريخ
      final dateParts = parts[0].split("-");
      final year = dateParts.length > 0 ? dateParts[0] : "";
      final month = dateParts.length > 1 ? dateParts[1] : "";
      final day = dateParts.length > 2 ? dateParts[2] : "";

      // الوقت
      String timeString = "";
      if (parts.length > 1) {
        final timeParts = parts[1].split(":");
        int hour = int.tryParse(timeParts[0]) ?? 0;
        final String minute = timeParts.length > 1 ? timeParts[1] : "00";
        final String period = hour >= 12 ? "PM" : "AM";
        if (hour > 12) hour -= 12;
        if (hour == 0) hour = 12;
        timeString = "$hour:$minute $period";
      }

      return "$year-$month-$day $timeString";
    }

    // إذا كان نص جاهز
    return dateTime;
  }

  // 2026-02-13 16:00:00 → 13 Feb
  static String extractDate(String dateTime) {
    if (dateTime.isEmpty) return "";
    final parts = dateTime.split(" ");
    if (parts.length < 1) return "";
    final dateParts = parts[0].split("-");
    if (dateParts.length < 3) return "";

    const months = {
      "01": "Jan", "02": "Feb", "03": "Mar",
      "04": "Apr", "05": "May", "06": "Jun",
      "07": "Jul", "08": "Aug", "09": "Sep",
      "10": "Oct", "11": "Nov", "12": "Dec",
    };

    final day = dateParts[2];
    final month = months[dateParts[1]] ?? "";
    return "$day $month";
  }

  String getRemainingTime(Map<String, dynamic> booking) {
    try {
      if (booking['booking_date'] == null || booking['start_time'] == null)
        return "--";

      final bookingDate = DateTime.parse(booking['booking_date']);

      final startTimeParts = (booking['start_time'] as String).split(':');
      final bookingStart = DateTime(
        bookingDate.year, bookingDate.month, bookingDate.day,
        int.parse(startTimeParts[0]),
        int.parse(startTimeParts[1]),
        startTimeParts.length > 2 ? int.parse(startTimeParts[2]) : 0,
      );

      final endTimeParts = (booking['end_time'] as String).split(':');
      final bookingEnd = DateTime(
        bookingDate.year, bookingDate.month, bookingDate.day,
        int.parse(endTimeParts[0]),
        int.parse(endTimeParts[1]),
        endTimeParts.length > 2 ? int.parse(endTimeParts[2]) : 0,
      );

      final now = DateTime.now();

      // ← انتهى الحجز
      if (now.isAfter(bookingEnd)) return "0D : 0H : 0M : 0S";

      // ← الحجز لم يبدأ بعد — عداد حتى البداية
      final difference = now.isBefore(bookingStart)
          ? bookingStart.difference(now)
          : bookingEnd.difference(now); // ← بدأ — عداد حتى النهاية

      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      final seconds = difference.inSeconds % 60;

      return "${days}D : ${hours}H : ${minutes}M : ${seconds}S";
    } catch (e) {
      print("getRemainingTime error: $e");
      return "--";
    }
  }
  String formatDate(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}";
    } catch (e) {
      return "";
    }
  }
  //18:15  →  6:15 PM
  String formatTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 2) {
      int hour = int.parse(parts[0]);
      final String minutes = parts[1];
      final String period = hour >= 12 ? 'PM' : 'AM';
      hour = hour % 12;
      if (hour == 0) hour = 12;
      return "${hour}:${minutes} $period";
    }
    return time;
  }
  //10/1
  String formatDateOnly(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}";
    } catch (e) {
      return "";
    }
  }

  //17:40 23/3
  String formatDateTime(String? dateStr) {
    if (dateStr == null) return "";
    try {
      final date = DateTime.parse(dateStr);
      int hour = date.hour % 12;
      if (hour == 0) hour = 12;
      final minute = date.minute.toString().padLeft(2, '0');
      final period = date.hour >= 12 ? 'PM' : 'AM';
      final day = date.day.toString();
      final month = date.month.toString();

      return "$hour:$minute $period $day/$month";
    } catch (e) {
      return "";
    }
  }
  //Sun-Thu
  String formatRangeDays(List days) {
    if (days.isEmpty) return "";

    String mapDay(String day) {
      switch (day) {
        case "saturday": return "Sat";
        case "sunday": return "Sun";
        case "monday": return "Mon";
        case "tuesday": return "Tue";
        case "wednesday": return "Wed";
        case "thursday": return "Thu";
        case "friday": return "Fri";
        default: return day;
      }
    }

    final first = mapDay(days.first);
    final last = mapDay(days.last);

    return "$first - $last";
  }
}