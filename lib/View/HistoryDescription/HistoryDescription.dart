import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/Them.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'HistoryDescription_rverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Widget/InfoRowItem.dart';
import 'Widget/MealItem.dart';
import 'Widget/ParkingInfoCard.dart';
import 'Widget/StaffReviewCard.dart';
import 'Widget/TableInfoBar.dart';

class HistoryDescription extends ConsumerStatefulWidget {
  final int bookingId;
  const HistoryDescription({super.key, required this.bookingId});

  @override
  ConsumerState<HistoryDescription> createState() => _HistoryDescriptionState();
}

class _HistoryDescriptionState extends ConsumerState<HistoryDescription> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(historyDescriptionProvider.notifier).fetchBookingDetails(widget.bookingId, context);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(historyDescriptionProvider);
    final notifier = ref.watch(historyDescriptionProvider.notifier);
    final data = notifier.bookingDetails;

    if (data == null) {
      return Scaffold(
        appBar: buildCustomAppBar(context, "History"),
        backgroundColor: Themes().GetColor("background"),
        body: showLoading(),
      );
    }

    final summary = data['summary'] ?? {};
    final sections = data['sections'] ?? {};

    final bookingDetailsSection = sections['booking_details'] ?? {};
    final cookingDetails = bookingDetailsSection['cooking_details'] ?? {};
    final table = bookingDetailsSection['table'];
    final parking = bookingDetailsSection['parking'];
    final itemsSummary = bookingDetailsSection['items_summary'] ?? {};
    final items = bookingDetailsSection['items'] ?? [];
    final restaurantRating = sections['restaurant_rating'] ?? {};
    final serviceRating = sections['service_rating'] ?? {};
    final reviewStory = sections['review_story'] ?? {};
    final staffRating = sections['staff_rating'] ?? {};
    final List<Map<String, dynamic>> mealsList = [];
    for (var item in items) {
      mealsList.add({
        'name': item['name']?.toString() ?? '',
        'price': (item['amount'] as num?)?.toInt() ?? 0,
        'mealsCount': (item['quantity'] as num?)?.toInt() ?? 0,
      });
    }
    final restaurantRatings = restaurantRating['items'] ?? [];
    final serviceRatings = serviceRating['items'] ?? [];
    final staffItems = staffRating['items'] ?? [];
    Map<String, dynamic> firstStaff = {};
    if (staffItems.isNotEmpty) firstStaff = staffItems[0];
    return Scaffold(
      appBar: buildCustomAppBar(context, "History"),
      backgroundColor: Themes().GetColor("background"),
      body:ValueListenableBuilder<bool>(
          valueListenable: LoadingService.isLoading,
          builder: (context, isLoading, child) {
            if (isLoading) return showLoading();
             return SingleChildScrollView(
               child: Container(
                 padding: EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth() * 5),
                 child: Column(
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Row(
                           children: [
                             SvgPicture.asset("assets/icon/bookingDeactivate.svg", height: Sizes(context).GetHeight() * 2),
                             SizedBox(width: Sizes(context).GetWidth() * 1),
                             GradientText(widget: Text(TextLanguage().GetWord("تفاصيل الحجز"))),
                           ],
                         ),
                         Text(summary['booking_number']?.toString() ?? '', style: TextStyle(color: Themes().GetColor("textSecondary"))),
                       ],
                     ),
                     SizedBox(height: Sizes(context).GetHeight() * 2),
                     Row(
                       children: [
                         Row(
                           children: [
                             GradientText(widget: SvgPicture.asset("assets/icon/MealDetails.svg", height: Sizes(context).GetHeight() * 2)),
                             SizedBox(width: Sizes(context).GetWidth() * 1),
                             GradientText(widget: Text(TextLanguage().GetWord('جميع الوجبات'))),
                             SizedBox(width: Sizes(context).GetWidth() * 1),
                             GradientText(widget: SvgPicture.asset("assets/icon/dollar.svg", height: Sizes(context).GetHeight() * 2)),
                             SizedBox(width: Sizes(context).GetWidth() * 1),
                             GradientText(widget: Text(itemsSummary['amount']?.toString() ?? '0')),
                             SizedBox(width: Sizes(context).GetWidth() * 1),
                             GradientText(widget: SvgPicture.asset("assets/icon/SAR.svg", height: Sizes(context).GetHeight() * 1.2)),
                           ],
                         ),
                       ],
                     ),
                     SizedBox(height: Sizes(context).GetHeight() * 2),
                     MealsList(meals: mealsList),
                     SizedBox(height: Sizes(context).GetHeight() * 2),
                     // Cooking details
                     if ((cookingDetails['items'] as List?)?.isNotEmpty == true) ...[
                       Row(
                         children: [
                           SvgPicture.asset("assets/icon/CookingMethod.svg"),
                           SizedBox(width: Sizes(context).GetWidth() * 1),
                           GradientText(widget: Text("Cooking details")),
                         ],
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                       InfoRowList(
                         items: (cookingDetails['items'] as List).map((item) {
                           return <String, String>{
                             'icon': item['icon']?.toString() ?? 'assets/icon/CookingMethod.svg',
                             'label': item['label']?.toString() ?? '',
                             'value': item['value']?.toString() ?? '',
                           };
                         }).toList(),
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                     ],
                     // Table
                     if (table != null) ...[
                       TableInfoBar(
                         tableNumber: int.tryParse(table['label']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ?? '') ?? 0,
                         price: num.tryParse(table['amount']?.toString() ?? '')?.toInt() ?? 0,
                         location: table['location_label'] ?? '',
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                     ],
                     // Parking
                     if (parking != null && parking['label'] != null) ...[
                       ParkingInfoCard(
                         price: num.tryParse(parking['amount']?.toString() ?? '')?.toInt() ?? 0,
                         hours: num.tryParse(parking['hours']?.toString() ?? '')?.toInt() ?? 0,
                         location: parking['location_label'] ?? '',
                         plateNumber: parking['car_plate'] ?? '',
                         carColor: parking['car_color'] ?? '',
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                     ],
                     // Restaurant Rating
                     if (restaurantRatings.isNotEmpty) ...[
                       Row(
                         children: [
                           Text(TextLanguage().GetWord("تقييم المطعم"), style: TextStyle(fontWeight: FontWeight.bold, color: Themes().GetColor("textPrimary"))),
                         ],
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                       SingleChildScrollView(
                         scrollDirection: Axis.horizontal,
                         child: Row(
                           children: restaurantRatings.map<Widget>((r) {
                             return Padding(
                               padding: const EdgeInsets.only(right: 8),
                               child: SquareButton(
                                 width: (r['label'] as String).length * 5.5 + 60,
                                 height: Sizes(context).GetHeight() * 5,
                                 backgroundColor: Themes().GetColor("backgroundOffWhite"),
                                 borderColor: Themes().GetColor("borderLight"),
                                 borderWidth: 1,
                                 borderRadius: 50,
                                 onTap: () {},
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Text(r['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
                                     SizedBox(width: Sizes(context).GetWidth() * 1),
                                     SvgPicture.asset("assets/icon/Star.svg", height: Sizes(context).GetHeight() * 2),
                                     SizedBox(width: Sizes(context).GetWidth() * 1),
                                     Text('${r['value']}/${r['max'] ?? 5}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Themes().GetColor("textSecondary"))),
                                   ],
                                 ),
                               ),
                             );
                           }).toList(),
                         ),
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                     ],
                     // Service Rating
                     if (serviceRatings.isNotEmpty) ...[
                       Row(
                         children: [
                           Text(TextLanguage().GetWord("تقييم الخدمة"), style: TextStyle(fontWeight: FontWeight.bold, color: Themes().GetColor("textPrimary"))),
                         ],
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                       SingleChildScrollView(
                         scrollDirection: Axis.horizontal,
                         child: Row(
                           children: serviceRatings.map<Widget>((r) {
                             return Padding(
                               padding: const EdgeInsets.only(right: 8),
                               child: SquareButton(
                                 width: (r['label'] as String).length * 5.5 + 60,
                                 height: Sizes(context).GetHeight() * 5,
                                 backgroundColor: Themes().GetColor("backgroundOffWhite"),
                                 borderColor: Themes().GetColor("borderLight"),
                                 borderWidth: 1,
                                 borderRadius: 50,
                                 onTap: () {},
                                 child: Row(
                                   mainAxisAlignment: MainAxisAlignment.center,
                                   mainAxisSize: MainAxisSize.min,
                                   children: [
                                     Text(r['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
                                     SizedBox(width: Sizes(context).GetWidth() * 1),
                                     SvgPicture.asset("assets/icon/Star.svg", height: Sizes(context).GetHeight() * 2),
                                     SizedBox(width: Sizes(context).GetWidth() * 1),
                                     Text('${r['value']}/${r['max'] ?? 5}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Themes().GetColor("textSecondary"))),
                                   ],
                                 ),
                               ),
                             );
                           }).toList(),
                         ),
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                     ],
                     // Staff Rating
                     if (staffItems.isNotEmpty) ...[
                       Row(
                         children: [
                           Text(TextLanguage().GetWord("تقييم الموظفين"), style: TextStyle(fontWeight: FontWeight.bold, color: Themes().GetColor("textPrimary"))),
                         ],
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 2),
                       StaffReviewCard(
                         name: firstStaff['staff_name'] ?? '',
                         role: firstStaff['staff_title'] ?? '',
                         imageUrl: 'assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png', // يمكن استبداله من API
                         ratings: (firstStaff['ratings'] as List? ?? []).map((rating) {
                           return {
                             'label': rating['label'],
                             'score': rating['value'],
                             'max': rating['max'] ?? 5,
                           };
                         }).toList(),
                         reviewText: reviewStory['comment'] ?? '',
                         tipAmount: num.tryParse(firstStaff['tip_amount']?.toString() ?? '')?.toDouble() ?? 0.0,
                         onTip: () {
                           // handle tip
                         },
                       ),
                       SizedBox(height: Sizes(context).GetHeight() * 7),
                     ],
                   ],
                 ),
               ),
             );
          }

      ),
    );
  }
}