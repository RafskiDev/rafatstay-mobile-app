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
      await ref.read(History_rverpod.notifier).fetchHistoryScreen(context: context);
    });
  }
  @override
  Widget build(BuildContext context) {
    ref.watch(History_rverpod.notifier);
    ref.watch(History_rverpod);
    final notifier = ref.watch(History_rverpod.notifier);
    final bookings = notifier.bookInProgress;
    final reviews = notifier.statusForRestaurants;
    final TextLanguage textL = TextLanguage();
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
                     Text(textL.GetWord("جميع الحجوزات"),style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                   ],
                 ),
                 SizedBox(height:Sizes(context).GetHeight()*2),
                  ListView.builder(
                    itemCount: bookings.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final bookingObj = bookings[index];
                      final card = bookingObj['card'] ?? {};
                      final schedule = card['schedule'] ?? {};
                      final branchInfo = card['branch'] ?? {};
                      final bookingId = bookingObj['booking_id'];
                      final headline = card['headline'] ?? '';
                      final branchName = branchInfo['label'] ?? '';
                      final dateLabel = schedule['date_label'] ?? '';
                      final timeLabel = schedule['time_label'] ?? '';
                      String bookingNumber = '';
                      final regExp = RegExp(r'Booking Number (\d+)');
                      final match = regExp.firstMatch(headline);
                      if (match != null) bookingNumber = match.group(1) ?? '';
                      return Padding(
                        padding: EdgeInsets.only(bottom: Sizes(context).GetHeight() * 1),
                        child: BookingCard(
                          id: bookingId,
                          mainImage: 'assets/images/a2a245e83857039e9ace75bf15fe92271da37762.png',
                          bookingNumber: bookingNumber,
                          price: '0',
                          paymentMethod: '',
                          restaurantName: branchName,
                          restaurantLocation: ' ',
                          restaurantLogo: "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                          date: dateLabel,
                          time: timeLabel,
                          footer: false,
                          textOnTap: "Rebooking",
                          onTap: () {
                            // إعادة الحجز - سننفذه لاحقاً
                          },
                          onTap_: () {
                            print(bookingId);
                            // الانتقال إلى تفاصيل الحجز (HistoryDescription) مع تمرير booking_id
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, a, b) => HistoryDescription(bookingId: bookingId,),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                if(reviews.isNotEmpty) ...[
                  Row(
                    children: [
                      Text("Status for Restaurants",style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                    ],
                  ),
                  SizedBox(height:Sizes(context).GetHeight()*2),
                  ...reviews.map((review) => Padding(
                    padding: EdgeInsets.only(bottom: Sizes(context).GetHeight() * 2),
                    child: ReviewCard(
                      reviewData: review,
                      onLikeToggle: (){

                      },
                      isLiked:  false,
                    ),
                  )),
                  SizedBox(height:Sizes(context).GetHeight()*5),
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

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> reviewData;
  final VoidCallback onLikeToggle;
  final bool isLiked;

  const ReviewCard({
    super.key,
    required this.reviewData,
    required this.onLikeToggle,
    required this.isLiked,
  });

  @override
  Widget build(BuildContext context) {
    final branchName = reviewData['branch_name'] ?? '';
    final commentPreview = reviewData['comment_preview'] ?? '';
    final sentiment = reviewData['sentiment'] ?? {};
    final tone = sentiment['tone'] ?? 'positive'; // positive أو negative
    final iconAsset = tone == 'positive' ? "assets/icon/likes.svg" : "assets/icon/dislike.svg";
    final Sizes sizes = Sizes(context);
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
          _buildHeader(context, branchName, iconAsset),
           SizedBox(height: sizes.GetHeight() * 2),
          _buildReviewText(commentPreview),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String branchName, String iconAsset) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Themes().GetColor("primaryA"),
            shape: BoxShape.circle,
          ),
          child: CircleAvatar(
            radius: Sizes(context).GetWidth() * 3.5,
            backgroundImage: const AssetImage("assets/images/a2a245e83857039e9ace75bf15fe92271da37762.png"),
            backgroundColor: Colors.transparent,
          ),
        ),
        SizedBox(width: Sizes(context).GetWidth() * 2),
        Container(
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE0C8),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Color(0xFF281F0B),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: Sizes(context).GetWidth() * 2.5,
                  backgroundImage: const AssetImage("assets/images/88d1a2c3434cab97d9a0cacb9386734b9a7653b6.png"),
                  backgroundColor: Colors.transparent,
                ),
              ),
              SizedBox(width: Sizes(context).GetWidth() * 1),
              Text(
                branchName,
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
        GestureDetector(
          onTap: onLikeToggle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFEBE0C8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: SvgPicture.asset(
              iconAsset,
              height: Sizes(context).GetWidth() * 5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        height: 1.6,
        color: Colors.black54,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}