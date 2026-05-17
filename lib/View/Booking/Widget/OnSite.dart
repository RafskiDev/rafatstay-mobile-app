import 'dart:io';
import 'dart:ui' as ui;
import 'package:gal/gal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Utils/ToastMessage.dart';
import '../../../Widget/Ticket.dart';
import '../../../Widget/WidgetButton.dart';
import '../../BookingDetails/BookingDetails.dart';
import '../../Chat/Chat.dart';
import '../Booking_riverpod.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'BookingDetails.dart';
class OnSite extends ConsumerStatefulWidget {
  const OnSite({super.key});

  @override
  ConsumerState<OnSite> createState() => _OnSiteState();
}

class _OnSiteState extends ConsumerState<OnSite> {
  final GlobalKey ticketKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return; // ← تحقق أولاً
      final notifier = ref.read(Booking_riverpod.notifier);
      await notifier.bookings(context: context, status: "on_site");
      final data = notifier.bookingsData;
      if (data.isNotEmpty) {
        await notifier.getBookingDetails(
          context: context,
          bookingId: data[0]['id'] as int,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(Booking_riverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    final bookingsData = ref.read(Booking_riverpod.notifier).bookingsData;
    final booking = bookingsData.isNotEmpty ? bookingsData[0] : null;

    if (booking == null) return const SizedBox.shrink();
    final GlobalKey ticketKey = GlobalKey();
    return  Column(
      children: [
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset("assets/icon/BookingTicket.svg",color:Themes().GetColor("textPrimary"),),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(textLanguage.GetWord('حجز تذكرة')),
              ],
            ),
            InkWell(
              onTap:(){
                ref.read(Booking_riverpod.notifier).setBookingTicketState(1);
              },
              child:SvgPicture.asset(ref.read(Booking_riverpod.notifier).bookingTicketStates[1]?"assets/icon/ArrowAbove.svg":"assets/icon/DownArrow.svg"),
            ),
          ],
        ),
        SizedBox(height: sizes.GetHeight() * 2),
        Visibility(visible:ref.read(Booking_riverpod.notifier).bookingTicketStates[1],child:Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: RepaintBoundary(
                    key: ticketKey,
                    child:Ticket(
                      bookingNumber: booking['id'] ?? 0,
                      payAmount: double.tryParse(bookingsData[0]['total_amount']?.toString() ?? "0") ?? 0.0,
                      checkInDate: DateTimeHelper().formatDate(bookingsData[0]['booking_date']) ?? "",
                      checkInTime: DateTimeHelper().formatTime(bookingsData[0]['end_time']) ?? "",
                      childrenCount: booking['children_count'] ?? 0,
                      tableNumber: booking['table']?['table_number'] ?? "N/A",
                      width: sizes.GetWidth() * 80,
                      height: sizes.GetHeight() * 25,
                      party_size:booking['party_size'] ?? 0,
                    ),
                  ),
                ),
                SizedBox(width: sizes.GetWidth() * 2),
                Column(
                  children: [
                    CircularButton(
                      size: sizes.GetWidth() * 10,
                      onTap: () {
                        downloadTicket(context,ticketKey);
                      },
                      backgroundColor: Themes().GetColor("background"),
                      borderColor:Themes().GetColor("primaryA"),
                      borderWidth: 1,
                      child: SvgPicture.asset(
                        "assets/icon/download.svg",
                        height: sizes.GetHeight() * 3,
                        color:Themes().GetColor("primaryA"),
                      ),
                    ),
                    SizedBox(height: sizes.GetHeight() * 5),
                    CircularButton(
                      size: sizes.GetWidth() * 10,
                      onTap: () {
                        shareTicket(context,ticketKey);
                      },
                      backgroundColor: Themes().GetColor("background"),
                      borderColor:Themes().GetColor("primaryA"),
                      borderWidth: 1,
                      child: SvgPicture.asset(
                        "assets/icon/sharing.svg",
                        height: sizes.GetHeight() * 3,
                        color:Themes().GetColor("primaryA"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: sizes.GetHeight() * 2),
          ],
        ),
        ),
        Row(
          mainAxisAlignment:MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset("assets/icon/BookingTicket.svg",color:Themes().GetColor("textPrimary"),),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(textLanguage.GetWord("تفاصيل الحجز")),
              ],
            ),
            InkWell(
              onTap:(){
                ref.read(Booking_riverpod.notifier).setBookingTicketState(0);
              },
              child:SvgPicture.asset(ref.read(Booking_riverpod.notifier).bookingTicketStates[0]?"assets/icon/ArrowAbove.svg":"assets/icon/DownArrow.svg"),
            ),
          ],
        ),
        SizedBox(height: sizes.GetHeight() * 2),
        Visibility(visible:ref.read(Booking_riverpod.notifier).bookingTicketStates[0],child:Column(
          children: [
            SizedBox(height: sizes.GetHeight() * 2),
            BookingDetail(ref:ref),
          ],
        )),
        ref.read(Booking_riverpod.notifier).bookingTicketStates[0]?SizedBox(height: sizes.GetHeight() * 2):Container(),
        Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetHeight() * 2),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(sizes.GetHeight() * 0.5),
                decoration: ref.read(Booking_riverpod.notifier).requestAssistance
                    ? BoxDecoration(
                  border: Border.all(color: Themes().GetColor("textPrimary")),
                  borderRadius: BorderRadius.circular(30),
                )
                    : null, // ⬅️ فقط البوردر يظهر/يختفي
                child: InkWell(
                  onTap: () {
                    ref.read(Booking_riverpod.notifier).setRequestAssistance();
                    showCustomBottomSheet(context, ref);
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        height: sizes.GetHeight() * 2.5,
                        "assets/icon/HeartInHand.svg",
                      ),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(textLanguage.GetWord('طلب المساعدة')),
                      SizedBox(width: sizes.GetWidth() * 3),
                      SvgPicture.asset(
                        height: sizes.GetHeight() * 2.5,
                        ref.read(Booking_riverpod.notifier).requestAssistance
                            ? "assets/icon/DownArrow.svg"
                            : "assets/icon/Arrow_one.svg",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: sizes.GetHeight() * 2),
        Container(
          padding:EdgeInsets.symmetric(horizontal:sizes.GetHeight()*2),
          child: InkWell(
            onTap:(){
              ref.read(Booking_riverpod.notifier).setRequestAssistance();
              /*
              ref.read(Booking_riverpod.notifier).createBooking(
                context: context,
                branchId: 1,
                bookingDate: "2026-03-01",
                startTime: "19:00",
                endTime: "21:00",   // ← ساعتين مثلاً
                partySize: 4,
                notes: "طاولة بعيدة عن الضوضاء",
              );

               */
             // showCustomBottomSheet(context, ref);
            },
            child: Container(
              padding: EdgeInsets.all(sizes.GetHeight() * 0.5),
              child: Row(
                children: [
                  SvgPicture.asset(height:sizes.GetHeight()*2.5,"assets/icon/AddNewOrder.svg"),
                  SizedBox(width: sizes.GetWidth() * 1),
                  Text(textLanguage.GetWord('إضافة طلب جديد')),
                  SizedBox(width: sizes.GetWidth() * 10),
                  SvgPicture.asset(height:sizes.GetHeight()*2.5,"assets/icon/Arrow_one.svg"),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: sizes.GetHeight() * 20),
        WidgetButton(
          width: sizes.GetWidth()*45,
          isCircular:true,
          context: context,
          buttonText:"Finish Experience",
          textColor:Themes().GetColor("textPrimary"),
          onPressed: () {
            print("تم الضغط على الزر");
          },
          backgroundColor:ref.read(Booking_riverpod.notifier).bookingDetails[0]?Themes().GetColor("primaryS"): Themes().GetColor("primaryA"),
        ),
      ],
    );
  }
  Future<void> shareTicket(BuildContext context,GlobalKey ticketKey) async {
    try {
      final String url = "https://yourapp.com/booking/";

      await Share.share(
        "تذكرة الحجز رقم \n\nشاهد التفاصيل عبر الرابط:\n$url",
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ فشلت المشاركة: $e')),
      );
    }
  }

  Future<void> downloadTicket(BuildContext context,GlobalKey ticketKey) async {
    try {
      // التقط صورة التذكرة
      final boundary = ticketKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      // احفظ مؤقتاً
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/ticket_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = await File(filePath).create();
      await file.writeAsBytes(pngBytes);

      // احفظ في الاستوديو
      await Gal.putImage(filePath);
      ToastMessages(context,'تم الحفظ',Themes().GetColor("success"),Themes().GetColor("white"));
    } catch (e) {
      if (e.toString().contains('permission')) {
        ToastMessages(context,'❌ يرجى منح إذن الوصول للصور',Themes().GetColor("error"),Themes().GetColor("white"));
      } else {
        ToastMessages(context,'فشل الحفظ',Themes().GetColor("error"),Themes().GetColor("white"));
      }
    }
  }
  void showCustomBottomSheet(BuildContext context, WidgetRef ref) {
    TextLanguage textLanguage = TextLanguage();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final sizes = Sizes(context);

        // 🟢 قائمة واحدة لكل الخيارات
        List<Map<String, String>> assistanceOptions = [
          {
            "icon": "assets/icon/RequestTableCleaning.svg",
            "text": textLanguage.GetWord('طلب تنظيف الطاولات'),
          },
          {
            "icon": "assets/icon/DoNotDisturb.svg",
            "text": textLanguage.GetWord('لا تخل'),
          },
          {
            "icon": "assets/icon/DislikeMeal.svg",
            "text": textLanguage.GetWord("لم يعجبني الطعام")
          },
          {
            "icon": "assets/icon/RequestManager.svg",
            "text":textLanguage.GetWord('مدير الطلبات'),
          },
        ];

        return Consumer(
          builder: (context, ref, _) {
            ref.watch(Booking_riverpod);
            final selectedIndex = ref.watch(Booking_riverpod.notifier).selectedAssistanceIndex;
            return Container(
             padding:EdgeInsets.all(8.0),
              height: sizes.GetHeight() * 65,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: sizes.GetHeight() * 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          textLanguage.GetWord("كيف يمكننا مساعدتك"),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: SvgPicture.asset("assets/icon/cancel.svg"),
                        ),
                      ],
                    ),
                    const Divider(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal:sizes.GetWidth()*5,vertical:0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // عمودين
                          crossAxisSpacing: sizes.GetWidth() * 16,
                          mainAxisSpacing: sizes.GetHeight() * 2,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: assistanceOptions.length,
                        itemBuilder: (context, index) {
                          return ImageTextBox(
                            imagePath: assistanceOptions[index]["icon"]!,
                            text: assistanceOptions[index]["text"]!,
                            isSelected: selectedIndex == index,
                            onTap: () {
                              ref.read(Booking_riverpod.notifier).setSelectedAssistance(index);
                            },
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/icon/time.svg"),
                        Text(textLanguage.GetWord("ستتلقى المساعدة في غضون 3-5 دقائق")),
                      ],
                    ),
                    WidgetButton(
                      width: sizes.GetWidth() * 58,
                      isCircular: true,
                      context: context,
                      buttonText: textLanguage.GetWord('منتهي'),
                      textColor: Themes().GetColor("textPrimary"),
                      onPressed: () {
                        if(ref.read(Booking_riverpod.notifier).selectedAssistanceIndex!=-1){
                          const typeMap = {
                            0: "table_cleaning",  // طلب تنظيف الطاولات
                            1: "waiter",          // لا تخل
                            2: "manager",         // لم يعجبني الطعام
                            3: "manager",         // مدير الطلبات
                          };
                          final selectedIndex = ref.read(Booking_riverpod.notifier).selectedAssistanceIndex;
                          final bookings = ref.read(Booking_riverpod.notifier).bookingsData;
                          if (bookings.isNotEmpty) {
                            ref.read(Booking_riverpod.notifier).requestAssistanceApi(
                              context: context,
                              bookingId: bookings[0]["id"],
                              type: typeMap[selectedIndex] ?? "waiter",
                              notes: assistanceOptions[selectedIndex]["text"],
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      backgroundColor: selectedIndex != -1
                          ? Themes().GetColor("primaryA")
                          : Themes().GetColor("primaryS"),
                    ),
                    SizedBox(height: sizes.GetHeight() * 1),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: (){
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation1, animation2) =>
                                    Chat(branch_id: 1,),
                                transitionDuration: Duration.zero,
                                reverseTransitionDuration: Duration.zero,
                              ),
                            );
                          },
                          child: Container(
                            width: sizes.GetHeight() *4,
                            height: sizes.GetHeight() * 4,
                            decoration: BoxDecoration(
                              color: Themes().GetColor("primaryS"),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icon/chat.svg",
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      ref.read(Booking_riverpod.notifier).setRequestAssistance();
      ref.read(Booking_riverpod.notifier).resetSelectedAssistance();
    });
  }
}

class ImageTextBox extends StatelessWidget {
  final String imagePath; // مسار الصورة
  final String text;      // النص الذي يظهر أسفل الصورة
  final bool isSelected;  // حالة التحديد
  final VoidCallback onTap;

  const ImageTextBox({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20), // 🟢 تأثير الضغط دائري
      child: Container(
        // 🟢 احذف width و height - دع GridView يتحكم بالحجم
        padding: EdgeInsets.symmetric(
          horizontal: sizes.GetWidth() * 2,
          vertical: sizes.GetHeight() * 1.5,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isSelected
                ? Themes().GetColor("secondary500")
                : Themes().GetColor("textSecondary"),
          ),
          color:isSelected? Themes().GetColor("primaryA"):Colors.transparent,
          borderRadius: BorderRadius.circular(20),

        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 🟢 توسيط عمودي
          mainAxisSize: MainAxisSize.min,
          children: [
            // الدائرة مع الأيقونة
            Container(
              width: sizes.GetHeight() * 6,
              height: sizes.GetHeight() * 6,
              decoration: BoxDecoration(
                color:isSelected? Themes().GetColor("secondary500"):Color(0xFF87CEEB),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  imagePath,
                  height: sizes.GetHeight() * 4,
                  width: sizes.GetHeight() * 4,
                  fit: BoxFit.contain,
                  color: isSelected
                      ? Themes().GetColor("white")
                      : Themes().GetColor("textPrimary"),
                ),
              ),
            ),

            SizedBox(height: sizes.GetHeight() * 0.2),
            // النص
            Flexible( // 🟢 بدلاً من Expanded لتجنب مشاكل الحجم
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2, // 🟢 حد أقصى سطرين
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected
                      ? Themes().GetColor("textPrimary")
                      : Themes().GetColor("textSecondary"),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
String formatDate(String? dateStr) {
  if (dateStr == null) return "";
  try {
    final date = DateTime.parse(dateStr);
    return "${date.day}/${date.month}";
  } catch (e) {
    return "";
  }
}