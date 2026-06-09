import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart';
class PageNotifier extends Notifier<int> {
  DateTime? startDate;
  String? startTime;
  String? endTime;
  int guests = 1;
  int children = 0;
  int selectedButton = -1;
  String? selectedServiceMode;

  // ← البيانات المجمعة للنقل للشاشة الثانية
  Map<String, dynamic> bookingData = {};

  @override
  int build() {
    resetToDefault();
    return 0;
  }
  void resetToDefault() {
    startDate = null;

    final now = DateTime.now();
    final startDateTime = now.add(const Duration(minutes: 1));
    final endDateTime = startDateTime.add(const Duration(hours: 2));

    startTime = _formatTime(startDateTime);
    endTime = _formatTime(endDateTime);

    guests = 1;
    children = 0;
    selectedButton = -1;
    selectedServiceMode = null;
    bookingData = {};
    state = 0;
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return "$h:$m";
  }
  void setDate(DateTime date) {
    startDate = date;
    state = date.millisecondsSinceEpoch;
    ref.notifyListeners();
  }

  String get formattedDate {
    if (startDate == null) return '';
    return DateFormat('yyyy-MM-dd').format(startDate!);
  }

  void setStartTime(String time) {
    final parts = time.split(':');
    if (parts.length >= 3) {
      int hour = int.parse(parts[0]);
      String minute = parts[1].padLeft(2, '0');
      final ampm = parts[2].toUpperCase().trim();
      if (ampm == "PM" && hour != 12) hour += 12;
      if (ampm == "AM" && hour == 12) hour = 0;
      startTime = "${hour.toString().padLeft(2, '0')}:$minute";
    } else if (parts.length == 2) {
      startTime = "${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}";
    }

    // ← احسب end_time بشكل صحيح
    final parsed = DateTime(2000, 1, 1,
      int.parse(startTime!.split(':')[0]),
      int.parse(startTime!.split(':')[1]),
    );
    endTime = _formatTime(parsed.add(const Duration(hours: 2)));

    state++;
  }

  void setGuests(String operation) {
    if (operation == "+") { if (guests < 50) guests++; }
    else { if (guests > 1) guests--; }
    ref.notifyListeners();
  }

  void setChildren(String operation) {
    if (operation == "+") { if (children < 50) children++; }
    else { if (children > 0) children--; }
    ref.notifyListeners();
  }

  void selectButton(int index) {
    selectedButton = index;
    const modes = {0: 'takeaway', 1: 'dine_in', 2: 'dine_in_to_go'};
    selectedServiceMode = modes[index];
    ref.notifyListeners();
  }

  // ← جمع البيانات وتخزينها
  Map<String, dynamic> collectBookingData(int branchId,String businessName) {
    final textLanguage = TextLanguage();

    String translatedMode = "";
    switch (selectedServiceMode) {
      case 'takeaway':
        translatedMode = textLanguage.GetWord("طلب سفري");
        break;
      case 'dine_in':
        translatedMode = textLanguage.GetWord("تناول داخل المطعم");
        break;
      case 'dine_in_to_go':
        translatedMode = textLanguage.GetWord("تناول ثم سفري");
        break;
    }
    bookingData = {
      'branch_id': branchId,
      'booking_date': formattedDate,
      'start_time':startTime,
      'end_time': endTime,
      'party_size': guests,
      'children_count': children,
      'service_mode': selectedServiceMode,
      'service_mode_translated': translatedMode, // (هذا المفتاح الجديد المترجم للواجهات)
      'businessName':businessName,
    };
    /*
        "booking_date": "2026-03-24",
      "start_time": "18:30",
      "end_time": "20:00",
      "party_size": 2,
      "children_count": 1,
      "service_mode": "dine_in"
     */
    return bookingData;
  }

}

final SetYourBookingDetails_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);



/*
 Future<Map<String, dynamic>?> createBooking({
    required BuildContext context,
    required int branchId,
    int? tableId,
    String? specialRequests,
  }) async {
    final body = <String, dynamic>{
      'branch_id': branchId,
      'booking_date': formattedDate,
      'start_time': startTime,
      'end_time': endTime,
      'party_size': guests,
    };

    if (children > 0) body['children_count'] = children;
    if (tableId != null) body['table_id'] = tableId;
    if (specialRequests != null) body['special_requests'] = specialRequests;

    final response = await ApiService().post(
      "v1/guest/bookings",
      body,
      context,
    );

    print("createBooking: $response");
    return response;
  }
 */