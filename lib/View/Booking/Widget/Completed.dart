import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Service/LoadingService.dart' show LoadingService;
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/ShowLoading.dart';
import '../../../Widget/WidgetButton.dart';
import '../../BookingDetailsSummary/BookingDetailsSummary.dart';
import '../../RateYourExperience/RateYourExperience.dart';
import '../../SecondRateYourExperience/SecondRateYourExperience.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../Booking_riverpod.dart';
class Completed extends ConsumerStatefulWidget {
  const Completed({super.key});

  @override
  ConsumerState<Completed> createState() => _CompletedState();
}
class _CompletedState extends ConsumerState<Completed> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    Future.microtask(() async {
      ref.read(completedBookingProvider.notifier).resetBookings();
      await ref.read(completedBookingProvider.notifier).bookings(
        context: context,
        status: "completed",
      );
    });
  }

  void _onScroll() {
    final notifier = ref.read(completedBookingProvider.notifier);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!notifier.isFetchingMore && notifier.hasMore) {
        notifier.loadMore(context, "completed");
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(completedBookingProvider);
    final notifier = ref.watch(completedBookingProvider.notifier);
    final bookCompleted = notifier.bookingsData;

    if (notifier.isLoading && bookCompleted.isEmpty) {
      return showLoading();
    }

    if (bookCompleted.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: Sizes(context).GetHeight() * 70,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: bookCompleted.length + (notifier.isFetchingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= bookCompleted.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final booking = bookCompleted[index];
          final branch = booking["branch"] ?? {};
          print(branch["image"]);
          return Padding(
            padding: EdgeInsets.only(bottom: Sizes(context).GetHeight() * 1),
            child: BookingCard(
              id: booking["id"],
              mainImage:branch["image"]??"",
              bookingNumber: booking["id"]?.toString() ?? "",
              price: booking["total_amount"]?.toString() ?? '0',
              paymentMethod: booking["payment_method"]?.toString() ?? '',
              restaurantName: branch["name"] ?? "",
              restaurantLocation:"",//هنا نضع طريقه الدفع ان كان كاش او غيرها
              restaurantLogo: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
              date: booking["booking_date"] ?? "",
              time:booking["display_time"] ?? booking["start_time"],
              booking:booking,
            ),
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final int id;
  final String mainImage;
  final String bookingNumber;
  final String price;
  final String paymentMethod;
  final String restaurantName;
  final String restaurantLocation;
  final String restaurantLogo;
  final String date;
  final String time;
  final bool footer;
  const BookingCard({
    super.key,
    required this.booking,
    required this.id,
    required this.mainImage,
    required this.bookingNumber,
    required this.price,
    required this.paymentMethod,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.restaurantLogo,
    required this.date,
    required this.time,
    this.footer=true
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(context),
              SizedBox(width: Sizes(context).GetWidth()*2),
              _info(context),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          _buttons(context,id),
          SizedBox(height: Sizes(context).GetHeight()*2),
          if(footer)_footer(context),
        ],
      ),
    );
  }

  // 📷 Image
  Widget _image(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl:mainImage,
        width: Sizes(context).GetWidth() * 30,
        height: Sizes(context).GetHeight() * 14,
        fit: BoxFit.cover,
        placeholder: (context, url) =>  Center(
          child:showLoading(),
        ),
        //ضفت هذا حتى لا يطبع الخطا
        errorListener: (dynamic exception) {
        },
        errorWidget: (context, url, error) {
          return Container(
            width: Sizes(context).GetWidth() * 30,
            height: Sizes(context).GetHeight() * 14,
            color: const Color(0xFFEEEEEE),
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  // ℹ️ Booking Info
  Widget _info(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          _InfoRow(
              icon1: "assets/icon/PromoTag.svg",
              text: '${TextLanguage().GetWord("رقم الحجز")} ${bookingNumber}',
            ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          _InfoRow(
            icon1: "assets/icon/LikePrice.svg",
            icon3: "assets/icon/SAR.svg",
            text: '${TextLanguage().GetWord('يدفع')} ${price}',
            subText:paymentMethod,
            //
          ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          _InfoRow(
            icon2: restaurantLogo,
            text: restaurantName,
            subText:restaurantLocation,
          ),
          SizedBox(height: Sizes(context).GetHeight()*1),
          Row(
            children: [
              SvgPicture.asset("assets/icon/SiteData.svg",color:Themes().GetColor("textSecondary"),height:Sizes(context).GetHeight()*1.5,),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Expanded(child: Text(DateTimeHelper().formatDateOnly(date),style:TextStyle(color:Themes().GetColor("textSecondary")))),
              SizedBox(width: Sizes(context).GetWidth()*5),
              SvgPicture.asset("assets/icon/time.svg",color:Themes().GetColor("textSecondary")),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Expanded(child: Text(time,style:TextStyle(color:Themes().GetColor("textSecondary")))),
            ],
          )
        ],
      ),
    );
  }

  // 🔘 Buttons
  Widget _buttons(BuildContext context,int id) {
    return Row(
      children: [
        Expanded(
          child: WidgetButton(
            buttonSize:Sizes(context).GetHeight()*1.8,
            context: context,
            isCircular: true,
            buttonText: TextLanguage().GetWord('تفاصيل الحجز'),
            onPressed: () {

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      BookingDetailsSummary(bookingId: booking["id"], bookingDetails:booking,),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            textColor:Themes().GetColor("textPrimary"),
            borderColor:Themes().GetColor("textPrimary"),
            backgroundColor:const Color(0xFFFAF5EB),
          )
        ),
        SizedBox(width: Sizes(context).GetWidth()*2),
        Expanded(
          child: WidgetButton(
            buttonSize:Sizes(context).GetHeight()*1.8,
            isCircular: true,
            context: context,
            buttonText: TextLanguage().GetWord('قيّم تجربتك'),
            onPressed: () {
              final id =booking["branch"]["id"];
              /*
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      SecondRateYourExperience(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
               */
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      RateYourExperience(branchId:id),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            textColor:Themes().GetColor("textPrimary"),
            backgroundColor:Themes().GetColor("primaryA"),
          ),
        ),
      ],
    );
  }

  // ⭐ Footer
  Widget _footer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [
        SvgPicture.asset("assets/icon/Honoring.svg"),
        SizedBox(width: Sizes(context).GetWidth()*1),
        Text(
          TextLanguage().GetWord("اكسب نقاط ولاء مقابل تقييمك"),
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}


// 🔹 Reusable Row
class _InfoRow extends StatelessWidget {
  final String icon1;
  final String icon2;
  final String icon3;
  final String text;
  final String subText;
  const _InfoRow({this.icon1='',this.icon2='',this.icon3='', required this.text, this.subText = ''});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        icon1.toString().isNotEmpty?SvgPicture.asset(icon1,color:Themes().GetColor("textPrimary")):const SizedBox(),
        icon2.toString().isNotEmpty?CircularButton(
          size:Sizes(context).GetHeight()*3,
          onTap: () {
            print("تم الضغط على الزر");
          },
          backgroundColor: Themes().GetColor("secondary500"),
          borderColor: Themes().GetColor("primary"),
          borderWidth:0.5,
          child: Image.asset(icon2),
        ):const SizedBox(),
        SizedBox(width: Sizes(context).GetWidth()*2),
         Expanded(
           child: Row(
             children: [
               Text(
                 text,
                 style: const TextStyle(fontSize: 12),
               ),
               SizedBox(width: Sizes(context).GetWidth()*0.5),
               icon3.isNotEmpty? SvgPicture.asset(icon3,height: Sizes(context).GetHeight()*1.5,color:Themes().GetColor("textPrimary")):const SizedBox(),
               SizedBox(width: Sizes(context).GetWidth()*1),
               Expanded(
                 child:subText.isEmpty?const SizedBox():Text(
                   subText,
                   style: const TextStyle(fontSize: 9),
                 ),
               ),
             ],
           ),
         ),
      ],
    );
  }
}