import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rafatstay/View/Maps/Maps.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/GradientText.dart';
import '../../../Widget/WidgetButton.dart';
import '../../../Widget/WidgetCustomDialog.dart';
import '../Booking_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class BookingDetail extends StatelessWidget {
  final WidgetRef ref;
  final Map<String, dynamic>? booking; // ممكن تكون null لو ما فيه بيانات من API
  const BookingDetail({super.key,required this.ref,this.booking});
  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final items = booking?['items'] as List?;
   // final primaryCta = booking?['actions']?['primary_cta'];
    return Column(
      children: [
        if ((booking?['items'] as List?)?.isNotEmpty == true) ...[
          if (items != null && items.isNotEmpty)
            Container(
              padding: EdgeInsets.all(sizes.GetWidth() * 4),
              decoration: BoxDecoration(
                color: Themes().GetColor("backgroundOffWhite"),
                borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
              ),
              child: Column(
                children: items.map((item) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: sizes.GetHeight() * 1),
                    child: RowInkw(
                      title: item['name']?.toString() ?? '-',
                      price: double.tryParse(item['price']?.toString() ?? '0')?.toInt() ?? 0,
                      pots_number: item['quantity'] ?? 0,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],

        if (items != null && items.isNotEmpty &&
            (items[0]['cooking_method'] != null || items[0]['doneness_level'] != null))...[
          SizedBox(height: sizes.GetHeight() * 2),
          GradientText(
            widget:Row(
              children: [
                SvgPicture.asset("assets/icon/CookingMethod.svg", height: sizes.GetHeight() * 2.5),
                SizedBox(width: sizes.GetWidth() * 2),
                Text(TextLanguage().GetWord("تفاصيل الطبخ"), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(height: sizes.GetHeight() * 1.5),
            Container(
            padding: EdgeInsets.all(sizes.GetWidth() * 4),
            decoration: BoxDecoration(
              color: Themes().GetColor("backgroundOffWhite"),
              borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
            ),
            child: Column(
              children: [
                if (items[0]['cooking_method'] != null)
                  _buildDetailRow(
                    context,
                    "assets/icon/CookingMethod.svg",
                    TextLanguage().GetWord("طريقة الطهي"),
                    items[0]['cooking_method']?.toString() ?? 'Steamed',
                  ),
                if (items[0]['cooking_method'] != null && items[0]['doneness_level'] != null)
                  SizedBox(height: sizes.GetHeight() * 2),
                if (items[0]['doneness_level'] != null)
                  _buildDetailRow(
                    context,
                    "assets/icon/DonenessLevel.svg",
                    TextLanguage().GetWord("مستوى الإنجاز"),
                    items[0]['doneness_level']?.toString() ?? 'Medium Rare',
                  ),
              ],
            ),
          ),
          ],
        SizedBox(height: sizes.GetHeight() * 2),
        if (booking?['table'] != null) ...[
          Container(
            padding: EdgeInsets.all(sizes.GetWidth() * 4),
            decoration: BoxDecoration(
              color: Themes().GetColor("backgroundOffWhite"),
              borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/icon/TableDetails.svg"),
                    SizedBox(width: Sizes(context).GetWidth() * 1),
                    Text("${TextLanguage().GetWord("طاولة")} #${booking!['table']['table_number'] ?? '-'}"),
                  ],
                ),
                GradientText(
                  widget: Row(
                    children: [
                      SvgPicture.asset("assets/icon/dollar.svg"),
                      SizedBox(width: Sizes(context).GetWidth() * 1),
                      SvgPicture.asset("assets/icon/SAR.svg", color: Themes().GetColor("textPrimary"), height: Sizes(context).GetHeight() * 1.1),
                      SizedBox(width: Sizes(context).GetWidth() * 1),
                      Text(booking!['table']['reservation_fee']?.toString() ?? '0'),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SvgPicture.asset("assets/icon/LocationTable.svg"),
                    SizedBox(width: Sizes(context).GetWidth() * 1),
                    Text(booking!['table']['location_type']?.toString() ?? '-'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
        ],
        // Parking Section
        if (booking?['parking'] != null) ...[
          Container(
            padding: EdgeInsets.all(sizes.GetWidth() * 4),
            decoration: BoxDecoration(
              color: Themes().GetColor("backgroundOffWhite"),
              borderRadius: BorderRadius.circular(sizes.GetHeight() * 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    SvgPicture.asset("assets/icon/Parking.svg", height: Sizes(context).GetHeight() * 2),
                    SizedBox(width: Sizes(context).GetWidth() * 1),
                    Text(TextLanguage().GetWord("موقف سيارات")),
                  ],
                ),
                SizedBox(height: Sizes(context).GetHeight() * 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GradientText(
                      widget: Row(
                        children: [
                          SvgPicture.asset("assets/icon/dollar.svg", height: sizes.GetHeight() * 2.2),
                          SizedBox(width: sizes.GetWidth() * 1),
                          SvgPicture.asset("assets/icon/SAR.svg", height: sizes.GetHeight() * 1.4),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(booking!['parking']['fee']?.toString() ?? '0'),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/time.svg", height: sizes.GetHeight() * 2.2),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("${booking!['parking']['hours']} hours"),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/LocationTable.svg", height: sizes.GetHeight() * 2.2),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(booking!['parking']['location']?.toString() ?? ''),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/ABC.svg", height: sizes.GetHeight() * 2.2),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(booking!['parking']['car_plate']?.toString() ?? ''),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/carPainting.svg", height: sizes.GetHeight() * 2.2),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(booking!['parking']['car_color']?.toString() ?? ''),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

        ],
        if(booking?["branch"]?['latitude'] != null && booking?["branch"]?['longitude'] != null)...[
          SizedBox(height: Sizes(context).GetHeight() * 1),
          WidgetButton(
            width: sizes.GetWidth() * 50,
            isCircular: true,
            context: context,
            buttonText: TextLanguage().GetWord("متوجه إلى المطعم"),
            textColor: Themes().GetColor("textPrimary"),
            onPressed: () {

              final restaurantLat = booking?["branch"]?['latitude'];
              final restaurantLng = booking?['branch']?['longitude'];
              if (restaurantLat != null && restaurantLng != null) {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        Maps(restaurantLat: restaurantLat, restaurantLng: restaurantLng),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }

            },
            backgroundColor: Themes().GetColor("primary"),
          ),
        ],
        WidgetButton(
          width: sizes.GetWidth() * 50,
          isCircular: true,
          borderColor: Themes().GetColor("textPrimary"),
          textColor: Themes().GetColor("textPrimary"),
          context: context,
          buttonText: TextLanguage().GetWord("إلغاء الحجز"),
          onPressed: () {
            dialogue(context,ref);
          },
          backgroundColor: Themes().GetColor("background"),
        ),
      ],
    );
  }
  // ويدجت مساعدة لبناء صف التفاصيل (Cooking/Doneness)
  Widget _buildDetailRow(BuildContext context, String icon, String title, String value) {
    final sizes = Sizes(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SvgPicture.asset(icon, height: sizes.GetHeight() * 2.2),
            SizedBox(width: sizes.GetWidth() * 2),
            Text(title),
          ],
        ),
        SquareButton(
          width: sizes.GetWidth() * 28,
          height: sizes.GetHeight() * 3.5,
          onTap: () {},
          child: Text(value, style: TextStyle(color: Themes().GetColor("textPrimary"), fontSize: 12)),
          backgroundColor: Colors.transparent,
          borderColor: Colors.black54,
          borderWidth: 0.8,
          borderRadius: 15,
          elevation: 0,
        ),
      ],
    );
  }
  void dialogue(BuildContext context,WidgetRef ref) {
    WidgetCustomDialog(
      context,
      barrierDismissible: true,
      backgroundColor:Themes().GetColor("backgroundOffWhite"),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset("assets/images/fishFree.svg"),
          SizedBox(height: Sizes(context).GetHeight()*2),
          Text(
              TextLanguage().GetWord("في حال إلغاء هذا الحجز، سيتم تطبيق رسوم إلغاء بنسبة 20% على المبلغ الإجمالي. تغطي هذه الرسوم تكاليف المعالجة والخدمة."),
              style: TextStyle(color:Themes().GetColor("textPrimary")),
              textAlign: TextAlign.center
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          WidgetButton(
            width: Sizes(context).GetWidth()*75,
            isCircular:true,
            context: context,
            buttonText:TextLanguage().GetWord("تأكيد الإلغاء والرسوم"),
            textColor:Themes().GetColor("textPrimary"),
            backgroundColor: Themes().GetColor("primaryA"),
            onPressed: () {
              final bookings = ref.read(Booking_riverpod.notifier).bookingsData;
              if (bookings.isEmpty) return;

              ref.read(Booking_riverpod.notifier).cancelBooking(
                context: context,
                bookingId: bookings[0]["id"],
              ).then((_) {
                // ← تنظيف بعد الإلغاء
                ref.read(Booking_riverpod.notifier).bookingsData.clear();
                ref.read(Booking_riverpod.notifier).ref.notifyListeners();
              });
              Navigator.of(context).pop();
            },
          ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          WidgetButton(
            width: Sizes(context).GetWidth()*75,
            isCircular:true,
            context: context,
            buttonText:TextLanguage().GetWord("عُد"),
            textColor:Themes().GetColor("textPrimary"),
            borderColor:Themes().GetColor("textPrimary"),
            backgroundColor: Themes().GetColor("backgroundOffWhite"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }
}

class RowInkw extends StatelessWidget {
  final String title;
  final int price;
  final int pots_number;
  RowInkw({super.key,required this.title,required this.price,this.pots_number=0});

  @override
  Widget build(BuildContext context) {
    return  Row(
      mainAxisAlignment:MainAxisAlignment.spaceBetween,
      children: [
        Text(title),
        GradientText(
          widget: Row(
            children: [
              SvgPicture.asset("assets/icon/dollar.svg"),
              SizedBox(width: Sizes(context).GetWidth()*1),
              SvgPicture.asset("assets/icon/SAR.svg",height: Sizes(context).GetHeight()*1.1,),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(price.toString()),
            ],
          ),
        ),
        Row(
          children: [
            SvgPicture.asset("assets/icon/pots.svg",color:Themes().GetColor("textPrimary"),),
            SizedBox(width: Sizes(context).GetWidth()*1),
            Text(pots_number.toString()),
            SizedBox(width: Sizes(context).GetWidth()*1),
            Text(TextLanguage().GetWord("وجبات الطعام")),
          ],
        ),
      ],
    );
  }
}



