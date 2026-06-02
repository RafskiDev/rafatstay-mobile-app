import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../Service/ApiService.dart';
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
  final bool isChosen;

  const TableDetails({
    super.key,
    required this.branchId,
    required this.tableId,
    required this.startTime,
    required this.endTime,
    required this.partySize,
    this.isChosen = false,
  });

  @override
  ConsumerState<TableDetails> createState() => _TableDetailsState();
}

class _TableDetailsState extends ConsumerState<TableDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // استخراج التاريخ بأمان
      final parts = widget.startTime.split(' ');
      final String extractedDate = parts.isNotEmpty ? parts.first : '';

      final String fullTimeStart = parts.length > 1 ? parts.last : widget.startTime;
      final endParts = widget.endTime.split(' ');
      final String fullTimeEnd = endParts.length > 1 ? endParts.last : widget.endTime;

      // قص الثواني بأمان
      final String formattedStart = fullTimeStart.length >= 5
          ? fullTimeStart.substring(0, 5)
          : fullTimeStart;
      final String formattedEnd = fullTimeEnd.length >= 5
          ? fullTimeEnd.substring(0, 5)
          : fullTimeEnd;
      ref.read(TableDetails_riverpod.notifier).fetchTableDetails(
        context,
        widget.branchId,
        widget.tableId,
        date: extractedDate,
        startTime: formattedStart,
        endTime: formattedEnd,
        partySize: widget.partySize,
      );
      ref.read(TableDetails_riverpod.notifier).setChosen(widget.isChosen);
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

    final table = tableDetails?['table'] as Map<String, dynamic>?;
    final features = tableDetails?['features'] as Map<String, dynamic>?;
   // final cta = tableDetails?['cta'] as Map<String, dynamic>?;

    final price = table?['reservation_fee'] ?? 0;
    final statusCode = table?['status']?['code'] ?? 'unavailable';
    final statusLabel = notifier.getStatusLabel(statusCode);
    final statusColor = statusCode == 'available' ? Colors.green : Colors.red;
    final locationCode = table?['location_type'] ?? '';
    final locationLabel = notifier.getLocationLabel(locationCode);
    final capacityLabel = table?['capacity_label'] ?? '';
    final capacityNumber = RegExp(r'\d+').firstMatch(capacityLabel)?.group(0) ?? '';
   // final rawPhotoUrl = table?['photo_url']?.toString() ?? '';
    final gallery = (table?['gallery'] as List? ?? []);
    final List<Map<String, dynamic>> featureItems =
        (features?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: isLoading
          ? Center(child: showLoading())
          : SafeArea(
            child: Column(
                    children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  child: gallery.isEmpty
                      ? Container(
                    width: double.infinity,
                    height: sizes.GetHeight() * 35,
                    color: theme.GetColor("background"),
                    child: const Icon(
                      Icons.image_not_supported,
                      size: 60,
                      color: Colors.grey,
                    ),
                  )
                      : CarouselSlider(
                    items: gallery.map((url) {
                      return Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          width: double.infinity,
                          height: sizes.GetHeight() * 35,
                          color: theme.GetColor("background"),
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(
                      height: sizes.GetHeight() * 35,
                      viewportFraction: 1,
                      autoPlay: gallery.length > 1,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sizes.GetWidth() * 4),
                    child: GlassAppBar(
                      onBack: () => Navigator.pop(context, notifier.isTableChosen),
                      onNotification: () {},
                      titel:TextLanguage().GetWord("تفاصيل الطاولة"),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.GetHeight() * 2),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: sizes.GetWidth() * 4),
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
                              Text("$capacityNumber ${TextLanguage().GetWord("ضيف")}"),
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
                              Text("$capacityNumber ${TextLanguage().GetWord("ضيف")}"),
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
                            TextLanguage().GetWord("مميزات الطاولة"),
                            style: TextStyle(
                              color: theme.GetColor("textPrimary"),
                              fontSize: sizes.GetWidth() * 5.8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      if (featureItems.isNotEmpty)
                        Row(
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: notifier.staticFeatures.map((feature) {
                                  final iconKey = feature['icon'] ?? '';
                                  final title = notifier.getFeatureTitle(iconKey);
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
                                    padding: EdgeInsets.only(
                                        right: sizes.GetWidth() * 1),
                                    child: CustomSelectionCard(
                                      title: title,
                                      svg: iconPath,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: sizes.GetHeight() * 2),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => notifier.changePage_(),
                            child: SvgPicture.asset(
                              isChosen
                                  ? "assets/icon/BOXCHECK_ON.svg"
                                  : "assets/icon/BOXCHECK_OFF.svg",
                              color: isChosen
                                  ? theme.GetColor("primary")
                                  : theme.GetColor("textSecondary"),
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth() * 1),
                          Text(
                            TextLanguage().GetWord("اختر هذه الطاولة"),
                            style:
                            TextStyle(color: theme.GetColor("primary")),
                          ),
                        ],
                      ),
                      SizedBox(height: sizes.GetHeight() * 5),
                    ],
                  ),
                ),
              ),
            ),
                    ],
                  ),
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
      width: sizes.GetWidth() * 25,
      height: sizes.GetWidth() * 25,
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
            width: sizes.GetWidth() * 12,
          ),
          SizedBox(height: sizes.GetHeight() * 1),
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