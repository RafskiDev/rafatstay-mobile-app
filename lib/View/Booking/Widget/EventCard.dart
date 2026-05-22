import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../../Service/ApiService.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Widget/GradientText.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../Widget/ShowLoading.dart';
class EventCard extends StatelessWidget {
  final List<dynamic> eventsData;

  const EventCard({Key? key, required this.eventsData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (eventsData.isEmpty) return const SizedBox.shrink();

    final sizes = Sizes(context);
    final theme = Themes();

    return Column(
      children: [eventsData.last].map((event) {
        final String title = event["title"]?.toString() ?? "";
        final String locationLabel = event["location_label"]?.toString() ?? "";
        final String dateLabel = event["date_label"]?.toString() ?? "";
        final String timeLabel = event["time_label"]?.toString() ?? "";
        final String price = event["price"]?.toString() ?? "0";
        return Container(
          margin: EdgeInsets.only(bottom: sizes.GetHeight() * 2),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9F6EE),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child:CachedNetworkImage(
                  imageUrl:"$showImage${event["image_url"]??""}",
                  width: sizes.GetHeight() * 14,
                  height: sizes.GetHeight() * 14,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>  Center(
                    child:showLoading(),
                  ),
                  //ضفت هذا حتى لا يطبع الخطا
                  errorListener: (dynamic exception) {
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      width: sizes.GetHeight() * 14,
                      height: sizes.GetHeight() * 14,
                      color: const Color(0xFFEEEEEE),
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: sizes.GetWidth() * 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF2D3E4E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.GetColor("primary"),
                          ),
                          padding: const EdgeInsets.all(6),
                          child: SvgPicture.asset(
                            "assets/icon/sharing.svg",
                            color: theme.GetColor("white"),
                            width: sizes.GetWidth() * 4,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 1.5),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/TableDetails.svg", width: sizes.GetWidth() * 4),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text(locationLabel, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: sizes.GetHeight() * 1.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/Calendar.svg",color: Themes().GetColor("textPrimary"), width: sizes.GetWidth() * 4),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(dateLabel, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        Row(
                          children: [
                            SvgPicture.asset("assets/icon/tiems.svg", width: sizes.GetWidth() * 4),
                            SizedBox(width: sizes.GetWidth() * 1),
                            Text(timeLabel, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        GradientText(
                          widget: Row(
                            children: [
                              SvgPicture.asset("assets/icon/LikePrice.svg"),
                              SizedBox(width: sizes.GetWidth() * 1),
                              Text(price, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(width: sizes.GetWidth() * 1),
                              SvgPicture.asset("assets/icon/SAR.svg"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}