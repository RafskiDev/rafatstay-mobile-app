import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';

import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';

class PageNotifier extends Notifier<int> {
  List<Map<String, dynamic>> bookingsData = [];
  Map<String, dynamic> bookingDetailss = {};

  bool hasFetched = false;
  final bool value = false;
  final List<String> tabs = ["Upcoming", "On-site", "Completed", "Cancelled"];
  List<bool> bookingTicketStates = [false, false];
  List<bool> bookingDetails = [false, false];
  bool requestAssistance = false;
  int selectedAssistanceIndex = -1;

  int currentPage = 1;
  bool isLoading = false;
  bool isFetchingMore = false;
  bool hasMore = true;

  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }

  void setBookingTicketState(int index) {
    bookingTicketStates[index] = !bookingTicketStates[index];
    ref.notifyListeners();
  }

  void setBookingDetails(int index) {
    bookingDetails[index] = !bookingDetails[index];
    ref.notifyListeners();
  }

  void setRequestAssistance() {
    requestAssistance = !requestAssistance;
    ref.notifyListeners();
  }

  void setSelectedAssistance(int itemIndex) {
    if (selectedAssistanceIndex == itemIndex) {
      selectedAssistanceIndex = -1;
    } else {
      selectedAssistanceIndex = itemIndex;
    }
    ref.notifyListeners();
  }

  void resetSelectedAssistance() {
    selectedAssistanceIndex = -1;
    ref.notifyListeners();
  }
  void closeRequestAssistance() {
    requestAssistance = false;
    ref.notifyListeners();
  }

  // ✅ دالة reset لإعادة تعيين كل الحالة
  void resetBookings() {
    bookingsData = [];
    currentPage = 1;
    hasMore = true;
    isLoading = false;
    isFetchingMore = false;
    hasFetched = false;
    ref.notifyListeners();
  }



  Future<void> rebook(BuildContext context, int bookingId, Map<String, dynamic> booking) async {
    String formatTime(String? time) {
      if (time == null) return "";
      final parts = time.split(":");
      if (parts.length >= 2) return "${parts[0]}:${parts[1]}";
      return time;
    }
    final body = {
      "booking_date": booking["booking_date"],
      "start_time": formatTime(booking["start_time"]?.toString()),
      "end_time": formatTime(booking["end_time"]?.toString()),
    };
    final response = await ApiService().post(
      "v1/guest/bookings/$bookingId/rebook",
      body,
      context,
    );
    if (response?["success"] == true) {
      ToastMessages(
        context,
        TextLanguage().GetWord("تم إعادة الحجز بنجاح"),
        Themes().GetColor("success"),
        Themes().GetColor("white"),
      );
    } else {
      ToastMessages(
        context,
        TextLanguage().GetWord("فشل إعادة الحجز"),
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }
  // ─── جلب قائمة الحجوزات ───────────────────────────────────────────
  Future<void> bookings({
    required BuildContext context,
    String? status,
    bool loadMore = false,
  }) async {
    if (loadMore) {
      if (!hasMore || isFetchingMore) return;
      isFetchingMore = true;
    } else {
      currentPage = 1;
      hasMore = true;
      isLoading = true;
      bookingsData.clear();
    }

    ref.notifyListeners();

    final Map<String, String> params = {
      //"per_page": "4",
      "page": currentPage.toString(),
    };

    if (status != null) {
      params["status"] = status;
    }

    final response = await ApiService().get(
      "v1/$roles/bookings",
      params,
      context,
    );
    if (response?["success"] == true) {
      final data = response?['data'];
      final items = data?['items'] ?? [];
      final pagination = data?['pagination'];

      final list = List<Map<String, dynamic>>.from(items);
      if (loadMore) {
        bookingsData.addAll(list);
      } else {
        bookingsData = list;
      }
      // print(bookingsData[0]);
      if (pagination != null) {
        final lastPage = pagination['last_page'] ?? 1;
        hasMore = currentPage < lastPage;
      } else {
        hasMore = list.length >= 5;
      }

      currentPage++;
    } else {
      hasMore = false;
    }

    isLoading = false;
    isFetchingMore = false;
    hasFetched = true;
   // getBookingDetails(context: context, bookingId: 68);

    ref.notifyListeners();
  }

  Future<void> checkIn({
    required BuildContext context,
    required int bookingId,
  }) async {
  //  print("checkIn: $bookingId");
    final response = await ApiService().patch(
      "v1/$roles/bookings/$bookingId/check-in",
      {},
      context,
    );
    if (response?["success"] == true) {
      ref.notifyListeners();
    }else{
      final message = response?["message"]?.toString() ?? "حدث خطأ";
      ToastMessages(
        context,
        message,
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

  Future<void> loadMore(BuildContext context, String status) async {
    if (isFetchingMore || !hasMore) return;
    await bookings(context: context, status: status, loadMore: true);
  }

  // ─── جلب تفاصيل حجز واحد ─────────────────────────────────────────
  Future<void> getBookingDetails({
    required BuildContext context,
    required int bookingId,
  }) async {
    bookingDetailss.clear();
    final response = await ApiService().get(
      "v1/$roles/bookings/$bookingId",
      {},
      context,
    );
   // print("bookingDetails: $response");
    if (response?["success"] == true) {
      bookingDetailss = Map<String, dynamic>.from(response?['data'] ?? {});
      ref.notifyListeners();
    }


  }

  // ─── إلغاء حجز ───────────────────────────────────────────────────
  Future<void> cancelBooking({
    required BuildContext context,
    required int bookingId,
    String? reason,
  }) async {
    await ApiService().patch(
      "v1/guest/bookings/$bookingId/cancel",
      reason != null ? {"cancellation_reason": reason} : null,
      context,
    );
  }

  // ─── إعادة تحميل الحجوزات (force refresh) ────────────────────────
  Future<void> refreshBookings({
    required BuildContext context,
    String? status,
  }) async {
    resetBookings();
    await bookings(context: context, status: status);
  }

  // ─── طلب مساعدة on-site ───────────────────────────────────────────
  List<Map<String, dynamic>> assistanceRequests = [];

  Future<void> requestAssistanceApi({
    required BuildContext context,
    required int bookingId,
    required String type,
    String? notes,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    final response = await ApiService().post(
      "v1/$roles/bookings/$bookingId/assistance",
      {
        "type": type,
        if (notes != null && notes.isNotEmpty) "notes": notes,
      },
      context,
    );

    if (response["success"] == true) {
      onSuccess?.call();
      ref.notifyListeners();
    } else {
      onError?.call();
    }
  }
  Future<void> finishExperience({
    required BuildContext context,
    required int bookingId,
    VoidCallback? onSuccess,
  }) async {
    final response = await ApiService().patch(
      "v1/$roles/bookings/$bookingId/finish",
      {},
      context,
    );
    if (response?["success"] == true) {
      bookingsData.removeWhere((b) => b["id"] == bookingId);
      ref.notifyListeners();
      onSuccess?.call();
    } else {
      ToastMessages(
        context,
        response?["message"] ?? TextLanguage().GetWord("حدث خطأ"),
        Themes().GetColor("error"),
        Themes().GetColor("white"),
      );
    }
  }

}
final Booking_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);


