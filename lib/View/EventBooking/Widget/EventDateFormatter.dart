class EventDateFormatter {
  static String date(String? dateStr) {
    if (dateStr == null) return "";
    final dt = DateTime.parse(dateStr);
    final months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
  }

  static String day(String? dateStr) {
    if (dateStr == null) return "";
    final dt = DateTime.parse(dateStr);
    final days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
    return days[dt.weekday - 1];
  }

  static String time(String? start, String? end) {
    if (start == null || end == null) return "";
    return "${_fmt(DateTime.parse(start))} – ${_fmt(DateTime.parse(end))}";
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? "AM" : "PM";
    return "$h:$m $period";
  }
}