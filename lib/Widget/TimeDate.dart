import 'package:flutter_svg/svg.dart';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/Them.dart';
import '../View/SetYourBookingDetails/SetYourBookingDetails_riverpod.dart';
class DynamicCalendar extends ConsumerStatefulWidget {
  final Function(DateTime)? onDateSelected;
  const DynamicCalendar({super.key, this.onDateSelected});

  @override
  ConsumerState<DynamicCalendar> createState() => _DynamicCalendarState();
}

class _DynamicCalendarState extends ConsumerState<DynamicCalendar> {
  DateTime currentDate = DateTime.now();

  List<DateTime> getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);
    final startOffset = firstDayOfMonth.weekday % 7;
    final totalDays = startOffset + lastDayOfMonth.day;

    return List.generate(totalDays, (index) {
      return DateTime(
        date.year,
        date.month,
        index - startOffset + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedDateInt = ref.watch(SetYourBookingDetails_riverpod);
    final selectedDate = DateTime.fromMillisecondsSinceEpoch(selectedDateInt);
    final theme = Themes();
    final sizes = Sizes(context);
    final days = getDaysInMonth(currentDate);

    return Center(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E2B8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black87),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER: الشهر والسنة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          currentDate = DateTime(
                            currentDate.year,
                            currentDate.month - 1,
                          );
                        });
                      },
                    ),
                    Text(
                      DateFormat('MMMM').format(currentDate),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          currentDate = DateTime(
                            currentDate.year,
                            currentDate.month + 1,
                          );
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          currentDate = DateTime(
                            currentDate.year - 1,
                            currentDate.month,
                          );
                        });
                      },
                    ),
                    Text(
                      currentDate.year.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          currentDate = DateTime(
                            currentDate.year + 1,
                            currentDate.month,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sizes.GetHeight() * 2),

            /// DAYS NAMES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'
              ].map((e) {
                return SizedBox(
                  width: 36,
                  child: Center(
                    child: Text(
                      e,
                      style: TextStyle(fontWeight: FontWeight.w500,color:theme.GetColor("textSecondary")),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: sizes.GetHeight() * 1),

            /// CALENDAR GRID
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemBuilder: (context, index) {
                final day = days[index];
                final isCurrentMonth = day.month == currentDate.month;
                final isSelected =
                DateUtils.isSameDay(day, selectedDate as DateTime?);
                final isPast = day.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day));

                return GestureDetector(
                  onTap: isCurrentMonth && !isPast
                      ? () {
                    ref.read(SetYourBookingDetails_riverpod.notifier).setDate(day);
                    widget.onDateSelected?.call(day); // ← أضف هذا
                  }
                      : null,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF0B2D3A) : null,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      isCurrentMonth ? day.day.toString() : '',
                      style: TextStyle(
                        color:isPast?theme.GetColor("icon"):theme.GetColor("primary"),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimePickerRow extends StatefulWidget {
  final double arrowHeight;
  final Color arrowColor;
  final Function(String)? onTimeChanged; // callback لإرجاع الوقت المختار
  const TimePickerRow({
    super.key,
    required this.arrowHeight,
    required this.arrowColor,
    this.onTimeChanged,
  });

  @override
  State<TimePickerRow> createState() => _TimePickerRowState();
}

class _TimePickerRowState extends State<TimePickerRow> {
  int hour = 12;
  int minute = 0;
  bool isPM = false;

  @override
  void initState() {
    super.initState();
    final now = TimeOfDay.now();
    hour = now.hourOfPeriod == 0 ? 12 : now.hourOfPeriod;
    minute = now.minute;
    isPM = now.period == DayPeriod.pm;
  }
  void _notifyTimeChanged() {
    if (widget.onTimeChanged != null) {
      widget.onTimeChanged!(getTime24Format());
    }
  }

  void incrementHour() {
    setState(() {
      hour = hour == 12 ? 1 : hour + 1;
    });
    _notifyTimeChanged();
  }

  void decrementHour() {
    setState(() {
      hour = hour == 1 ? 12 : hour - 1;
    });
    _notifyTimeChanged();
  }

  void incrementMinute() {
    setState(() {
      minute = (minute + 1) % 60;
    });
    _notifyTimeChanged();
  }

  void decrementMinute() {
    setState(() {
      minute = (minute - 1 + 60) % 60;
    });
    _notifyTimeChanged();
  }

  void toggleAmPm() {
    setState(() {
      isPM = !isPM;
    });
    _notifyTimeChanged();
  }

  String getTime24Format() {
    String ampm = isPM ? "PM" : "AM";
    return "${hour.toString()}:${minute.toString()}:${ampm.toString()}";
  }

  @override
  Widget build(BuildContext context) {
    String ampm = isPM ? "PM" : "AM";
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // الساعة
        _buildTimePicker(
          value: hour.toString(),
          onIncrement: incrementHour,
          onDecrement: decrementHour,
        ),

        // الدقيقة
        _buildTimePicker(
          value: minute.toString().padLeft(2, '0'),
          onIncrement: incrementMinute,
          onDecrement: decrementMinute,
        ),

        // AM/PM
        _buildTimePicker(
          value: ampm,
          onIncrement: toggleAmPm,
          onDecrement: toggleAmPm,
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onIncrement,
          child: Transform.rotate(
            angle: -pi / 2,
            child: SvgPicture.asset(
              "assets/icon/Arrow_one.svg",
              height: widget.arrowHeight,
              color: widget.arrowColor,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: widget.arrowHeight,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: onDecrement,
          child: Transform.rotate(
            angle: pi / 2,
            child: SvgPicture.asset(
              "assets/icon/Arrow_one.svg",
              height: widget.arrowHeight,
              color: widget.arrowColor,
            ),
          ),
        ),
      ],
    );
  }
}
