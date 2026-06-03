import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Service/ApiService.dart';
import '../BookingDetails/BookingDetails_riverpod.dart';

class PageNotifier extends Notifier<int> {
  bool isChecked = false;
  List<Map<String, dynamic>> tables = [];
  bool isLoading = false;
  int? selectedTableId;
  int? selectedTableIndex;
  Map<String, dynamic> selectedTableData = {}; // ← أضف هذا
  @override
  int build() => 0;

  // ── جلب الطاولات المتاحة ──
  Future<void> fetchTables({
    required BuildContext context,
    required int? branchId,
    required String? date,
    required String? startTime,
    required String? endTime,
    required int? partySize,
  }) async {


    isLoading = true;
    ref.notifyListeners();

    // ✅ endpoint بدون query parameters
    final endpoint = "v1/$roles/branches/$branchId/tables";

    // ✅ data تحتوي على query parameters
    final data = {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'party_size': partySize.toString(),
    };

    final response = await ApiService().get(endpoint, data, context);
  //  print(response);
    if (response?["success"] == true) {
      tables = List<Map<String, dynamic>>.from(response?["data"] ?? []);
    }

    isLoading = false;
    ref.notifyListeners();
  }

  // ── تحديد طاولة ──
  void selectTable(int index,bool isAvailable) {
    if (!isAvailable) return;
    if (selectedTableIndex == index) {
      selectedTableIndex = null;
      selectedTableId = null;
      selectedTableData = {};
    } else {
      selectedTableIndex = index;
      selectedTableId = tables[index]["id"];
      selectedTableData = Map<String, dynamic>.from(tables[index]);
    }
    ref.notifyListeners();
  }
  // ── إنشاء الحجز ──
  Future<Map<String, dynamic>?> createBooking({
    required BuildContext context,
    required Map<String, dynamic> bookingData,
  }) async {
    final carPlate = ref.read(BookingDetails_riverpod.notifier).CarPlate.text; // ← صحح
    final carColor = ref.read(BookingDetails_riverpod.notifier).CarColor.text; // ← صحح
    final needsParking = ref.read(BookingDetails_riverpod.notifier).isFirstSelected();
    final body = <String, dynamic>{
      'branch_id': bookingData['branch_id'],
      'booking_date': bookingData['booking_date'],
      'start_time': bookingData['start_time'],
      'end_time': bookingData['end_time'],
      'party_size': bookingData['party_size'],
      if ((bookingData['children_count'] ?? 0) > 0)
        'children_count': bookingData['children_count'],
      if (bookingData['service_mode'] != null)
        'service_mode': bookingData['service_mode'],
      if (selectedTableId != null)
        'table_id': selectedTableId,
      if (needsParking) ...{
        'needs_parking': true,
        'parking_hours':"2",
        'parking_location': selectedTableData["location_type"],
        if (carPlate.isNotEmpty) 'car_plate': carPlate,
        if (carColor.isNotEmpty) 'car_color': carColor,
      },
    };

    final response = await ApiService().post(
      "v1/$roles/bookings",
      body,
      context,
    );
    return response;
  }

  void setChecked() {
    isChecked = !isChecked;
    ref.notifyListeners();
  }

  Map<String, dynamic> policiesData = {};

  Future<void> fetchPolicies({
    required BuildContext context,
    required int branchId,
  }) async {
    final response = await ApiService().get(
      "v1/guest/branches/$branchId/policies",
      null,
      context,
    );
    if (response?["success"] == true) {
      policiesData = Map<String, dynamic>.from(response?["data"] ?? {});
      ref.notifyListeners();
    }

  }
  void resetToDefault() {
    tables = [];                     // إعادة قائمة الطاولات فارغة
    selectedTableIndex = null;       // عدم تحديد أي طاولة
    selectedTableId = null;          // إزالة ID الطاولة المحددة
    selectedTableData = {};          // إزالة بيانات الطاولة
    isChecked = false;               // إعادة checkbox للوضع الافتراضي
    isLoading = false;               // إعادة حالة التحميل
    policiesData = {};               // إعادة السياسات
    ref.notifyListeners();           // تحديث الـ UI
  }
}

final AvailableTables_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);