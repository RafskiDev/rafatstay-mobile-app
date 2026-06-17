import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Service/ApiService.dart';
import '../../../Service/LoadingService.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/ShowLoading.dart';
import '../../../Widget/WidgetButton.dart';
import '../../BookingDetailsSummary/BookingDetailsSummary.dart';
import '../../RestaurantDetalis/RestaurantDetalis.dart';
import '../Booking_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
class Cancelled extends ConsumerStatefulWidget {
  const Cancelled({super.key});

  @override
  ConsumerState<Cancelled> createState() => _CancelledState();
}

class _CancelledState extends ConsumerState<Cancelled> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    Future.microtask(() async {

      ref.read(cancelledBookingProvider.notifier).resetBookings();

      await ref.read(cancelledBookingProvider.notifier).bookings(
        context: context,
        status: "cancelled",
      );
    });
  }

  void _onScroll() {
    final notifier = ref.read(cancelledBookingProvider.notifier);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!notifier.isFetchingMore && notifier.hasMore) {
        notifier.loadMore(context, "cancelled");
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
    final notifier = ref.watch(cancelledBookingProvider.notifier);
    final bookCancelled = notifier.bookingsData;
    return ValueListenableBuilder<bool>(
      valueListenable: LoadingService.isLoading,
      builder: (context, isLoading, child) {
        if (isLoading && bookCancelled.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(child: showLoading()),
          );
        }

        if (bookCancelled.isEmpty) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Text(
                  TextLanguage().GetWord("لا توجد حجوزات ملغية"),
                  style: TextStyle(
                    color: Themes().GetColor("textSecondary"),
                    fontSize: Sizes(context).GetHeight() * 2,
                  ),
                ),
              ),
            ),
          );
        }
        return SizedBox(
          height: Sizes(context).GetHeight() * 68,
          child: ListView.builder(
            controller: _scrollController,
            itemCount: bookCancelled.length + (notifier.isFetchingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= bookCancelled.length) {
                return  Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: showLoading()),
                );
              }
              final booking = bookCancelled[index];
              return Padding(
                padding: EdgeInsets.only(bottom: Sizes(context).GetHeight() * 2),
                child: BookingCard(
                  booking: booking,
                  mainImage:booking["branch"]["image"]??"",
                  bookingNumber: booking["id"]?.toString() ?? "",
                  paymentMethod: '',
                  restaurantName: booking["business"]?["name"] ?? "",
                  restaurantLocation: "",//نضع هنا نوع الدفع ان كان كاش او لا اي بوابه دفع
                  restaurantLogo: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                  date: booking["booking_date"] ?? "",
                  time:booking["display_time"] ?? booking["start_time"],
                ),
              );
            },
          ),
        );
      }
    );
  }
}

class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;
  final String mainImage;
  final String bookingNumber;
  final String paymentMethod;
  final String restaurantName;
  final String restaurantLocation;
  final String restaurantLogo;
  final String date;
  final String time;

  const BookingCard({
    super.key,
    required this.booking,
    required this.mainImage,
    required this.bookingNumber,
    required this.paymentMethod,
    required this.restaurantName,
    required this.restaurantLocation,
    required this.restaurantLogo,
    required this.date,
    required this.time,
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
              SizedBox(width: Sizes(context).GetWidth() * 2),
              _info(context),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
          _buttons(context),
        ],
      ),
    );
  }

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

  Widget _info(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(
            icon1: "assets/icon/PromoTag.svg",
            text: '${TextLanguage().GetWord("رقم الحجز")} $bookingNumber',
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
          _InfoRow(
            icon2: restaurantLogo,
            text: restaurantName,
            subText: restaurantLocation,
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
          Row(
            children: [
              SvgPicture.asset(
                "assets/icon/SiteData.svg",
                color: Themes().GetColor("textSecondary"),
                height: Sizes(context).GetHeight() * 1.5,
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Text(DateTimeHelper().formatDateOnly(date),
                  style:
                  TextStyle(color: Themes().GetColor("textSecondary"))),
              SizedBox(width: Sizes(context).GetWidth() * 5),
              SvgPicture.asset(
                "assets/icon/time.svg",
                color: Themes().GetColor("textSecondary"),
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Text(DateTimeHelper().formatTime(time),
                  style:
                  TextStyle(color: Themes().GetColor("textSecondary"))),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight() * 1),
          _InfoRow(
            icon1: "assets/icon/SandGlass.svg",
            text: (booking["screen"]?["time_remaining"]?["formatted_compact"] ?? "--:--:--").toString(),
          ),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: WidgetButton(
            buttonSize: Sizes(context).GetHeight() * 1.9,
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
            textColor: Themes().GetColor("textPrimary"),
            borderColor: Themes().GetColor("textPrimary"),
            backgroundColor: const Color(0xFFFAF5EB),
          ),
        ),
        SizedBox(width: Sizes(context).GetWidth() * 2),
        Expanded(
          child: WidgetButton(
            buttonSize: Sizes(context).GetHeight() * 1.9,
            isCircular: true,
            context: context,
            buttonText: TextLanguage().GetWord('إعادة الحجز'),
            onPressed: () async {

              final branchId = (booking['branch'] as Map<String, dynamic>)['id'];
              final restaurantName = (booking['business'] as Map<String, dynamic>)['name'];
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder:
                      (_, __, ___) =>
                      RestaurantDetalis(
                        title: (restaurantName).toString(),
                        branchId: branchId),
                  transitionDuration:
                  Duration.zero,
                  reverseTransitionDuration:
                  Duration.zero,
                ),
              );
              // ignore: use_build_context_synchronously
             /*
              ProviderScope.containerOf(context).read(Booking_riverpod.notifier).rebook(
                context,
                booking["id"],
                booking,
              );
              */
            },
            textColor: Themes().GetColor("textPrimary"),
            backgroundColor: Themes().GetColor("primaryA"),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon1;
  final String icon2;
  final String icon3;
  final String text;
  final String subText;

  const _InfoRow({
    this.icon1 = '',
    this.icon2 = '',
    this.icon3 = '',
    required this.text,
    this.subText = '',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (icon1.isNotEmpty)
          SvgPicture.asset(icon1, color: Themes().GetColor("textPrimary")),
        if (icon2.isNotEmpty)
          CircularButton(
            size: Sizes(context).GetHeight() * 3,
            onTap: () {},
            backgroundColor: Themes().GetColor("secondary500"),
            borderColor: Themes().GetColor("primary"),
            borderWidth: 0.5,
            child: Image.asset(icon2),
          ),
        SizedBox(width: Sizes(context).GetWidth() * 2),
        Expanded(
          child: Row(
            children: [
              Text(text, style: const TextStyle(fontSize: 12)),
              if (icon3.isNotEmpty) ...[
                SizedBox(width: Sizes(context).GetWidth() * 1),
                SvgPicture.asset(icon3,
                    height: Sizes(context).GetHeight() * 1.5,
                    color: Themes().GetColor("textPrimary"))
              ],
              if (subText.isNotEmpty)
                Expanded(
                  child:
                  Text(subText, style: const TextStyle(fontSize: 9)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

String getCancelledTime(Map<String, dynamic> booking) {
  try {
    if (booking['cancelled_at'] == null) return "--:--:--";

    final DateTime cancelDate =
    DateTime.parse(booking['cancelled_at'].toString()).toLocal();

    final String hours = cancelDate.hour.toString().padLeft(2, '0');
    final String minutes = cancelDate.minute.toString().padLeft(2, '0');
    final String seconds = cancelDate.second.toString().padLeft(2, '0');

    return "${hours}H : ${minutes}M : ${seconds}S";
  } catch (e) {
    print("Error parsing cancelled_at: $e");
    return "--:--:--";
  }
}