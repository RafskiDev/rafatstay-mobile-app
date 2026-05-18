import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Widget/Ticket.dart' show Ticket;
import '../../../Service/LoadingService.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Utils/ToastMessage.dart';
import '../../../Widget/GradientText.dart';
import '../../../Widget/ShowLoading.dart';
import '../../../Widget/WidgetButton.dart';
import '../../../Widget/WidgetCustomDialog.dart';
import '../../BookingDetails/BookingDetails.dart';
import '../Booking_riverpod.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gal/gal.dart';
import 'BookingDetails.dart';
import 'EventCard.dart';
final timerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now());
});
class Upcoming extends ConsumerStatefulWidget {
  const Upcoming({super.key});

  @override
  ConsumerState<Upcoming> createState() => _UpcomingState();
}

class _UpcomingState extends ConsumerState<Upcoming> {
  final GlobalKey ticketKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(Booking_riverpod.notifier).bookings(context: context,status: "pending");
      await ref.read(Booking_riverpod.notifier).events(context: context,id:2);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(timerProvider);
    final sizes = Sizes(context);
    final theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final bookingsData = ref.watch(Booking_riverpod.notifier).bookingsData;
    final hasData = bookingsData.isNotEmpty;
    // قراءة قائمة الفعاليات التي أنشأناها وحفظنا البيانات بها
    final bookingNotifier = ref.watch(Booking_riverpod.notifier);
    final eventsList = bookingNotifier.eventsData;
    return ValueListenableBuilder<bool>(
        valueListenable: LoadingService.isLoading,
        builder: (context, isLoading, child) {
          return  isLoading
              ? showLoading()
              : !hasData
              ? SizedBox.shrink()
              :Column(
            children: [
              Row(
                children: [
                  Container(
                    width: sizes.GetHeight() * 4.2,
                    height: sizes.GetHeight() * 4.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.GetColor("secondaryPrimary"),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: ClipOval(
                        child: Image.asset(
                          "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: sizes.GetWidth() * 1),
                  Text(bookingsData[0]['business']?['name']?.toString() ?? ""),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(textLanguage.GetWord("الوقت المتبقي")),
                  Row(
                    children: [
                      SvgPicture.asset("assets/icon/SandGlass.svg",
                        color: Themes().GetColor("textPrimary"),),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(DateTimeHelper().getRemainingTime(ref
                          .read(Booking_riverpod.notifier)
                          .bookingsData[0])),
                    ],
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset("assets/icon/BookingTicket.svg",
                        color: Themes().GetColor("textPrimary"),),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(textLanguage.GetWord('حجز تذكرة')),
                    ],
                  ),
                  InkWell(
                    onTap: () {
                      ref.read(Booking_riverpod.notifier).setBookingTicketState(
                          0);
                    },
                    child: SvgPicture.asset(ref
                        .read(Booking_riverpod.notifier)
                        .bookingTicketStates[0]
                        ? "assets/icon/ArrowAbove.svg"
                        : "assets/icon/DownArrow.svg"),
                  ),
                ],
              ),
              SizedBox(height: sizes.GetHeight() * 2),
              Visibility(visible: ref
                  .read(Booking_riverpod.notifier)
                  .bookingTicketStates[0], child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RepaintBoundary(
                          key: ticketKey,
                          child:Ticket(
                            bookingNumber: bookingsData[0]['booking_number'] ?? 0,
                            payAmount: double.tryParse(bookingsData[0]['total_amount']?.toString() ?? "0") ?? 0.0,
                            checkInDate: DateTimeHelper().formatDate(bookingsData[0]['booking_date']) ?? "",
                            checkInTime: DateTimeHelper().formatTime(bookingsData[0]['end_time']) ?? "",
                            childrenCount: bookingsData[0]['children_count'] ?? 0,
                            tableNumber: bookingsData[0]['table']?['table_number'] ?? "0",
                            party_size: bookingsData[0]["party_size"] ?? 0,
                            width: sizes.GetWidth() * 80,
                            height: sizes.GetHeight() * 22,
                          ),
                        ),
                      ),
                      SizedBox(width: sizes.GetWidth() * 2),
                      Column(
                        children: [
                          CircularButton(
                            size: sizes.GetWidth() * 10,
                            onTap: () {
                              downloadTicket(context, ticketKey);
                            },
                            backgroundColor: Themes().GetColor("background"),
                            borderColor: Themes().GetColor("primaryA"),
                            borderWidth: 1,
                            child: SvgPicture.asset(
                              "assets/icon/download.svg",
                              height: sizes.GetHeight() * 3,
                              color: Themes().GetColor("primaryA"),
                            ),
                          ),
                          SizedBox(height: sizes.GetHeight() * 5),
                          CircularButton(
                            size: sizes.GetWidth() * 10,
                            onTap: () {
                              shareTicket(context, ticketKey);
                            },
                            backgroundColor: Themes().GetColor("background"),
                            borderColor: Themes().GetColor("primaryA"),
                            borderWidth: 1,
                            child: SvgPicture.asset(
                              "assets/icon/sharing.svg",
                              height: sizes.GetHeight() * 3,
                              color: Themes().GetColor("primaryA"),
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
              SizedBox(height: sizes.GetHeight() * 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SvgPicture.asset(height: sizes.GetHeight() * 2.5,
                        "assets/icon/bookingDeactivate.svg",
                        color: Themes().GetColor("textPrimary"),),
                      SizedBox(width: sizes.GetWidth() * 1),
                      Text(textLanguage.GetWord("تفاصيل الحجز")),
                    ],
                  ),
                  InkWell(

                    onTap: () {
                      ref.read(Booking_riverpod.notifier).setBookingDetails(0);
                    },
                    child: SvgPicture.asset(ref
                        .read(Booking_riverpod.notifier)
                        .bookingDetails[0]
                        ? "assets/icon/ArrowAbove.svg"
                        : "assets/icon/DownArrow.svg"),
                  ),
                ],
              ),
              Visibility(visible: ref
                  .read(Booking_riverpod.notifier).bookingDetails[0], child: Column(

                children: [
                  SizedBox(height: sizes.GetHeight() * 2),
                  if (ref.read(Booking_riverpod.notifier).bookingsData.isNotEmpty)...[
                    Row(
                      children: [
                        GradientText(
                          widget:Row(
                            children: [
                              SvgPicture.asset("assets/icon/pots.svg"),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text(textLanguage.GetWord("جميع الوجبات")),
                            ],
                          )
                         ),
                        SizedBox(width: sizes.GetWidth() * 3),
                        GradientText(
                            widget:Row(
                              children: [
                                SizedBox(width: sizes.GetWidth() * 1),
                                SvgPicture.asset("assets/icon/dollar.svg"),
                                SizedBox(width: sizes.GetWidth() * 1),
                                Text("2300"),
                                SizedBox(width: sizes.GetWidth() * 1),
                                SvgPicture.asset("assets/icon/SAR.svg",height: Sizes(context).GetHeight()*1.1),
                              ],
                            )
                        ),
                        ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    BookingDetail(booking: ref
                        .read(Booking_riverpod.notifier)
                        .bookingsData[0], ref: ref),
                  ],
                ],
              )),
              SizedBox(height: sizes.GetHeight() * 2),
              if (!ref.read(Booking_riverpod.notifier).bookingDetails[0])
              WidgetButton(
                width: sizes.GetWidth() * 45,
                isCircular: true,
                context: context,
                buttonText: textLanguage.GetWord('تحقق في'),
                textColor: Themes().GetColor("textPrimary"),
                onPressed: () {
                  final bookings = ref.read(Booking_riverpod.notifier).bookingsData;
                  if (bookings.isEmpty) return;
                  ref.read(Booking_riverpod.notifier).checkIn(
                    context: context,
                    bookingId: bookings[0]['id'] as int,
                  );
                },
                backgroundColor: Themes().GetColor("primaryS"),
              ),
              if(eventsList.isNotEmpty)...[
                Column(
                  children: [
                    Row(
                      children: [
                        Text(textLanguage.GetWord("الفعاليات"),style: TextStyle(fontWeight: FontWeight.bold,color: Themes().GetColor("textPrimary"))),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 2),
                    EventCard(eventsData:eventsList),
                  ],
                ),
               ],
            ],
          );
        }
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

}



