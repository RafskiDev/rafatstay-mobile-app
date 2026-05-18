import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/ShowLoading.dart';
import '../../Widget/WidgetAppBar.dart';
import 'TableDetails_riverpod.dart';

class TableDetails extends ConsumerStatefulWidget {
  final int branchId;
  final int tableId;
  final String startTime;
  final String endTime;
  final int partySize;

  const TableDetails({
    super.key,
    required this.branchId,
    required this.tableId,
    required this.startTime,
    required this.endTime,
    required this.partySize,
  });

  @override
  ConsumerState<TableDetails> createState() => _TableDetailsState();
}

class _TableDetailsState extends ConsumerState<TableDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String extractedDate = widget.startTime.split(' ').first;

      // 2. استخراج الوقت الصافي: "12:00:00"
      String fullTimeStart = widget.startTime.split(' ').last;
      String fullTimeEnd = widget.endTime.split(' ').last;

      // 3. قص الثواني للحصول على صيغة H:i المطلوبة: "12:00"
      String formattedStart = fullTimeStart.substring(0, 5);
      String formattedEnd = fullTimeEnd.substring(0, 5);
      ref.read(TableDetails_riverpod.notifier).fetchTableDetails(
        context,
        widget.branchId,
        widget.tableId,
        date: extractedDate,
        startTime: formattedStart,
        endTime: formattedEnd,
        partySize: widget.partySize,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(TableDetails_riverpod);
    final notifier = ref.watch(TableDetails_riverpod.notifier);
    final isLoading = notifier.isLoadingDetails;
    final tableDetails = notifier.tableDetails;
    final isChosen = notifier.isTableChosen;

    final sizes = Sizes(context);
    final theme = Themes();

    // استخراج البيانات من tableDetails (إذا كانت موجودة)
    final table = tableDetails?['table'] as Map<String, dynamic>?;
    final features = tableDetails?['features'] as Map<String, dynamic>?;
    final cta = tableDetails?['cta'] as Map<String, dynamic>?;

    final price = table?['reservation_fee'] ?? 0;
    final capacity = table?['capacity'] ?? 0;
    final statusCode = table?['status']?['code'] ?? 'unavailable';
    final statusLabel = table?['status']?['label'] ?? 'غير متاحة';
    final statusColor = statusCode == 'available' ? Colors.green : Colors.red;
    final locationLabel = table?['location_label'] ?? '';
    final capacityLabel = table?['capacity_label'] ?? '';
    final photoUrl = table?['photo_url'];
    final gallery = tableDetails?['table']?['gallery'] as List? ?? [];

    // قائمة الصور لعرضها في Carousel
    final List<String> imageUrls = [];
    if (photoUrl != null && photoUrl.isNotEmpty) imageUrls.add(photoUrl);
    if (gallery.isNotEmpty) imageUrls.addAll(gallery.cast<String>());

    // قائمة الميزات من الـ API
    final List<Map<String, dynamic>> featureItems =
        (features?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: isLoading
          ?  Center(child: showLoading())
          : Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: CarouselSlider(
                  items: imageUrls.isEmpty
                      ? [
                    Container(
                      color: theme.GetColor("primaryS"),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50),
                      ),
                    )
                  ]
                      : imageUrls.map((url) {
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: sizes.GetHeight() * 35,
                    viewportFraction: 1,
                    autoPlay: true,
                  ),
                ),
              ),
              Positioned(
                top: sizes.GetHeight() * 4,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: sizes.GetWidth() * 4),
                  child: GlassAppBar(
                    onBack: () => Navigator.pop(context),
                    onNotification: () {},
                    titel: "تفاصيل الطاولة",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.GetHeight() * 2),
          Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/LikePrice.svg",
                            color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("$price"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        SvgPicture.asset("assets/icon/SAR.svg",
                            color: theme.GetColor("textPrimary")),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/TablePerson.svg",
                            color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(capacityLabel),
                        SizedBox(width: sizes.GetWidth() * 1),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: sizes.GetWidth() * 3,
                          height: sizes.GetWidth() * 3,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(statusLabel),
                        SizedBox(width: sizes.GetWidth() * 1),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/Chair.svg",
                            color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(capacityLabel),
                      ],
                    ),
                    SizedBox(width: sizes.GetWidth() * 10),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/_location.svg",
                            color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(locationLabel),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    Text(
                      "Table Features",
                      style: TextStyle(
                          color: theme.GetColor("textPrimary"),
                          fontSize: sizes.GetWidth() * 5.8,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: featureItems.map((feature) {
                      final title = feature['title'] ?? '';
                      final iconKey = feature['icon'] ?? '';
                      String iconPath;
                      switch (iconKey) {
                        case 'window':
                          iconPath = "assets/icon/Window.svg";
                          break;
                        case 'quiet_area':
                          iconPath = "assets/icon/QuietArea.svg";
                          break;
                        case 'non_smoking':
                          iconPath = "assets/icon/NonSmoking.svg";
                          break;
                        default:
                          iconPath = "assets/icon/QuietArea.svg";
                      }
                      return Padding(
                        padding: EdgeInsets.only(right: sizes.GetWidth() * 1),
                        child: CustomSelectionCard(
                          title: title,
                          svg: iconPath,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    InkWell(
                      child: SvgPicture.asset(
                        isChosen
                            ? "assets/icon/BOXCHECK_OFF.svg"
                            : "assets/icon/BOXCHECK_ON.svg",
                        color: isChosen
                            ? theme.GetColor("textSecondary")
                            : theme.GetColor("primary"),
                      ),
                      onTap: () {
                        notifier.changePage_();
                        // يمكن إضافة منطق إرسال table_id إلى Provider الحجز
                      },
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    Text(
                      cta?['label'] ?? "اختر هذه الطاولة",
                      style: TextStyle(color: theme.GetColor("primary")),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomSelectionCard extends StatelessWidget {
  final String title;
  final String svg;
  const CustomSelectionCard({
    Key? key,
    this.title = "Near Window",
    this.svg = "assets/icon/QuietArea.svg",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();

    return Container(
      width: sizes.GetWidth() * 22,
      height: sizes.GetWidth() * 22,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB09040), width: 1.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svg,
            color: theme.GetColor("textPrimary"),
            width: sizes.GetWidth() * 8,
          ),
          SizedBox(height: sizes.GetHeight() * 0.5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.GetColor("textPrimary"),
              fontSize: sizes.GetHeight() * 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}