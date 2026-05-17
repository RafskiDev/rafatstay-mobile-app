import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/LoadingService.dart';
import '../../Utils/DateTimeHelper.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/BookingCard.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import '../HistoryDescription/HistoryDescription.dart';
import '../RestaurantDetalis/RestaurantDetalis.dart';
import 'History_rverpod.dart';
class History extends ConsumerStatefulWidget{
  const History({super.key});

  @override
  ConsumerState<History> createState() => _HistoryState();
}

class _HistoryState extends ConsumerState<History> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      ref.read(History_rverpod.notifier).resetBooking();
      await ref.read(History_rverpod.notifier).booking(
        context: context,
        status: "completed",
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(History_rverpod.notifier);
    final notifier = ref.watch(History_rverpod.notifier);
    final bookCompleted = notifier.bookCompleted;
    return Scaffold(
      appBar:buildCustomAppBar(context,"History"),
      backgroundColor: Themes().GetColor("background"),
      body:ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          if (isLoading) return showLoading();
          return SingleChildScrollView(
            child: Container(
              padding:EdgeInsets.symmetric(horizontal:Sizes(context).GetWidth()*5),
              child: Column(
                children: [
                 Row(
                   children: [
                     Text("AII Bookings"),
                   ],
                 ),
                 SizedBox(height:Sizes(context).GetHeight()*2),
                 ListView.builder(
                    itemCount: bookCompleted.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final booking = bookCompleted[index];
                      final branch = booking["branch"] ?? {};
                      return Padding(
                        padding: EdgeInsets.only(bottom: Sizes(context).GetHeight() * 1),
                        child: BookingCard(
                          id: booking["id"],
                          mainImage: 'assets/images/a2a245e83857039e9ace75bf15fe92271da37762.png',
                          bookingNumber: booking["id"]?.toString() ?? "",
                          price: booking["total_amount"]?.toString() ?? '0',
                          paymentMethod: booking["payment_method"]?.toString() ?? '',
                          restaurantName: branch["name"] ?? "",
                          restaurantLocation: "${branch["city"] ?? ""} ${branch["address"] ?? ""}".trim(),
                          restaurantLogo: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                          date:DateTimeHelper().formatDate(booking["booking_date"] ?? ""),
                          time:DateTimeHelper().formatTime(booking["start_time"] ?? ""),
                          footer: false,
                          textOnTap:"Rebooking",
                          onTap:() {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    RestaurantDetalis(title: branch["name"], branchId: branch["id"]),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          onTap_:(){
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    HistoryDescription(),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  Row(
                    children: [
                      Text("Status for Restaurants",style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                    ],
                  ),
                  SizedBox(height:Sizes(context).GetHeight()*2),
                  ReviewCard(ref: ref),
                  SizedBox(height:Sizes(context).GetHeight()*5),
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final WidgetRef ref;
  const ReviewCard({super.key,required this.ref});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F3E9), // لون الخلفية مقارب للصورة
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context,ref),
          const SizedBox(height: 5),
          _buildReviewText(),
        ],
      ),
    );
  }

  // ويدجت مقسم للقسم العلوي (الصورة الشخصية، الشعار، وزر الإعجاب)
  Widget _buildHeader(BuildContext context,WidgetRef ref) {
    final notifier=ref.read(History_rverpod.notifier);
    final like=notifier.like;
    return Row(
      children: [
        // دائرة داخلها صورة فقط
        Container(
          padding: const EdgeInsets.all(2), // هذا هو سمك الإطار
          decoration:  BoxDecoration(
            color:Themes().GetColor("primaryA"),
            shape: BoxShape.circle,
          ),
          child:CircleAvatar(
            radius: Sizes(context).GetWidth() * 3.5,
            backgroundImage: AssetImage("assets/images/a2a245e83857039e9ace75bf15fe92271da37762.png"),
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(width:Sizes(context).GetWidth() * 2),
        Container(
           padding:EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE0C8), // لون الحاوية الداخلي
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               Container(
                padding: const EdgeInsets.all(2),
                decoration:  BoxDecoration(
                  color: Color(0xFF281F0B),
                  shape: BoxShape.circle,
                ),
                child:  CircleAvatar(
                  radius:Sizes(context).GetWidth() * 2.5,
                  backgroundImage: AssetImage("assets/images/88d1a2c3434cab97d9a0cacb9386734b9a7653b6.png"),
                  backgroundColor: Colors.transparent,
                ),
              ),
               SizedBox(width:Sizes(context).GetWidth() * 1),
              Text(
                'ALBAIK',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey.shade800,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE0C8),
            borderRadius: BorderRadius.circular(20),
          ),
          child:SvgPicture.asset(like?"assets/icon/likes.svg":"assets/icon/dislike.svg",height:Sizes(context).GetWidth()*5,),//dislike.svg
        )
      ],
    );
  }

  Widget _buildReviewText() {
    return const Text(
      "This is one of the best food ordering apps I've ever used!"
          "The interface is simple, the menu is clear, ordering takes only "
          "a few steps, and the notifications are accurate. I truly felt like "
          "the app was designed to make life easier, not more\n"
          "complicated.",
      style: TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
