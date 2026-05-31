import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Them.dart';
import '../../Utils/ToastMessage.dart';
import '../AvailableTables/AvailableTables_riverpod.dart';
import '../BookingDetails/BookingDetails_riverpod.dart';
import '../RestaurantDetalis/RestaurantDetalis_riverpod.dart' show RestaurantDetalis_riverpod;
class PageNotifier extends Notifier<int> {
  int? lastInstallmentChoice;

  @override
  int build() {
    return -1;
  }
  void selectIndex(int index) {
    state = (state == index) ? -1 : index;
  }
  /*
  Future<String?> initiatePayment(
      BuildContext context,
      int subscriptionId,
      ) async {
    final response = await ApiService().post(
      "v1/payments/subscription/initiate",
      {
        "subscription_id": subscriptionId,
        "redirect_url": "https://rafatstay.com/success",
      },
      context,
    );
    return response?['data']?['redirect_url'];
  }

   */

  // ─── حالة الدفع ───
  Future<Map<String, dynamic>?> checkPaymentStatus(
      BuildContext context,
      String reference,
      ) async {
    final response = await ApiService().get(
      "v1/payments/$reference/status",
      {},
      context,
    );
    return response?['data'];
  }


  Future<Map<String, dynamic>?> createBooking({
    required BuildContext context,
    required Map<String, dynamic> bookingData,
  }) async {
    final carPlate = ref.read(BookingDetails_riverpod.notifier).CarPlate.text; // ← صحح
    final carColor = ref.read(BookingDetails_riverpod.notifier).CarColor.text; // ← صحح
    final needsParking = ref.read(BookingDetails_riverpod.notifier).isFirstSelected();
    final garage = ref.read(RestaurantDetalis_riverpod.notifier).garage;
  //  final parking_spot_number = garage.isNotEmpty ? garage[0]["parking_spot_number"].toString() : "0";
    final rawDuration = garage.isNotEmpty ? garage[0]["duration"].toString() : "1";
    final String digitsOnly = RegExp(r'\d+').stringMatch(rawDuration) ?? "1";
    final int duration = int.tryParse(digitsOnly) ?? 1;
    final body = <String, dynamic>{
      'branch_id': bookingData['branch_id'],
      'booking_date': bookingData['booking_date'],
      'start_time': bookingData['start_time'],
      'end_time':  _addOneHour(bookingData['start_time']),//bookingData['end_time']
      'party_size': bookingData['party_size'],
      'table_id': bookingData['table_id'],
      if ((bookingData['children_count'] ?? 0) > 0)
        'children_count': bookingData['children_count'],
      if (bookingData['service_mode'] != null)
        'service_mode': bookingData['service_mode'],
    //  if (ref.read(AvailableTables_riverpod.notifier).selectedTableId != null)
        'items': (bookingData['items'] ?? []).map((m) {
          final itemMap = {
            'menu_item_id': m['menu_item_id'],
            'item_name': m['item_name'] ?? m['title'] ?? '', // fallback لـ title
            'quantity': m['quantity'] ?? 1,
          };

          if (m['cooking_method'] != null && m['cooking_method'].toString().isNotEmpty) {
            itemMap['cooking_method'] = m['cooking_method'];
          }
          if (m['doneness_level'] != null && m['doneness_level'].toString().isNotEmpty) {
            itemMap['doneness_level'] = m['doneness_level'];
          }
          if (m['notes'] != null && m['notes'].toString().isNotEmpty) {
            itemMap['notes'] = m['notes'];
          }

          return itemMap;
        }).toList(),
      if (needsParking) ...{
        'needs_parking': true,
        'parking_hours':duration.toString(),
        'parking_location': bookingData['location_type'] ?? '',
        if (carPlate.isNotEmpty) 'car_plate': carPlate,
        if (carColor.isNotEmpty) 'car_color': carColor,
        //نضيف هنا موقف السيار يعني مكانها "floor": "P5",
      },
    };
    final response = await ApiService().post(
      "v1/$roles/bookings",
      body,
      context,
    );
    return response;
  }

  Future<dynamic> payBooking({
    required BuildContext context,
    required int bookingId,
    required String paymentMethod,
    String? redirectUrl,
  }) async {
    final body = <String, dynamic>{
      "payment_method": paymentMethod,
      if (paymentMethod != "cash")
        "redirect_url": redirectUrl ?? "https://rafatstay.com/payment/callback",
    };



    final response = await ApiService().post(
      "v1/guest/bookings/$bookingId/pay",
      body,
      context,
    );
    if (response?["success"] == true) {
      final data = response["data"];
      if (data["type"] == "cash") {
        return true;
      } else if (data["type"] == "digital") {
        return data["redirect_url"];
      }
      return true;
    } else {
      if (context.mounted) {
        ToastMessages(
          context,
          response?["message"] ?? TextLanguage().GetWord("فشل الدفع"),
          Themes().GetColor("error"),
          Themes().GetColor("white"),
        );
      }
      return false;
    }
  }

  String _addOneHour(String startTime) {
    final parts = startTime.split(':');
    final hour = (int.parse(parts[0]) + 1) % 24;
    final minute = parts[1];
    print('hour:${hour.toString().padLeft(2, '0')}:$minute');
    return '${hour.toString().padLeft(2, '0')}:$minute';
  }

}

final Payment_riverpod = NotifierProvider<PageNotifier, int>(PageNotifier.new);