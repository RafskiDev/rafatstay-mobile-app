import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/DateTimeHelper.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/TextLanguage.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/WidgetButton.dart';
import '../../EventBooking/EventBooking.dart';
import '../../Payment/Payment.dart';
import '../Home_riverpod.dart';
class Events extends ConsumerWidget {
  final List<dynamic> events;
  const Events({super.key, required this.events});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes = Sizes(context);
    final textLanguage = TextLanguage();
    final theme = Themes();
    return Visibility(
      visible: ref
          .read(Home_riverpod.notifier)
          .selectedIndex ==
          0 &&
          events.isNotEmpty,
      child: Container(
        width: double.infinity,
        height: sizes.GetHeight() * 47,
        decoration: BoxDecoration(
          color: theme.GetColor("background"),
          border: Border.all(
            color: theme.GetColor("primary"),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withOpacity(0.25),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                  sizes.GetWidth() * 2.5,
                  vertical:
                  sizes.GetHeight() * 2),
              child: Row(
                children: [
                  Text(
                    textLanguage.GetWord(
                        "لا تفوتوا الفعاليات"),
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount:events.take(3).length,
                itemBuilder: (context, index) {
                  final item = events[index];
                  final String date = DateTimeHelper.extractDate(item["ends_at"]);
                  final String time = "${DateTimeHelper.extractTime(item["starts_at"])}";
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                        sizes.GetWidth() *
                            2.2,
                        vertical:
                        sizes.GetHeight() *
                            1),
                    child: CustomCard(
                      ref: ref,
                      event: item,
                      //item["image"]
                      imagePath:
                          "assets/images/1c07e950ad312fdaaef1bdd4e1882d79f25c9233.png",
                      title:item["title"],
                      date:date,
                      time:"${time.split(" ")[1]} "+time.split(" ")[2],
                      location:item["location"]??"",
                      price:item["price"]??"",
                      showButton: true,
                      buttonText:
                      textLanguage.GetWord(
                          "احجز الآن"),
                      width:
                      sizes.GetWidth() * 43,
                      height:
                      sizes.GetHeight() * 45,
                      iconTitle:
                      "assets/icon/tent.svg",
                      iconDate:
                      "assets/icon/date.svg",
                      iconTime:
                      "assets/icon/time.svg",
                      iconLocation:
                      "assets/icon/location.svg",
                      iconPrice:
                      "assets/icon/LikePrice.svg",
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final String imagePath;
  final String title;
  final String date;
  final String time;
  final String location;
  final String price;
  final bool showButton;
  final String buttonText;
  final double width;
  final double height;
  final String iconTitle;
  final String iconDate;
  final String iconTime;
  final String iconLocation;
  final String iconPrice;
  final WidgetRef ref;
  const CustomCard({
    Key? key,
    required this.event,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.price,
    this.showButton = true,
    this.buttonText = "احجز الآن",
    required this.width,
    required this.height,
    required this.iconTitle,
    required this.iconDate,
    required this.iconTime,
    required this.iconLocation,
    required this.iconPrice,
    required this.ref,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Themes theme = Themes();
    Sizes sizes = Sizes(context);
    TextLanguage language = TextLanguage();

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(12),
        color: theme.GetColor("primaryS"),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
            child: imagePath.startsWith("assets/")
                ? Image.asset(
              imagePath,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
            )
                : Image.network(
              imagePath,
              width: double.infinity,
              height: 150,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Image.asset(
                "assets/images/1c07e950ad312fdaaef1bdd4e1882d79f25c9233.png",
                width: double.infinity,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.5),
            child:Row(
              children: [
                SizedBox(width: sizes.GetWidth() * 1),
                SvgPicture.asset(iconTitle, height: 14),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(1.5),
            child: Row(
              children: [
                Row(
                  children: [
                    SizedBox(width: sizes.GetWidth() * 1),
                    SvgPicture.asset(iconDate, height: 14),
                    SizedBox(width: sizes.GetWidth() * 1),
                    Text(date, style: const TextStyle(fontSize: 12)),
                  ],
                ),
                SizedBox(width: sizes.GetWidth() * 2),
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(iconTime, height: 14),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          time,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.5),
            child: Row(
              children: [
                SizedBox(width: sizes.GetWidth() * 1),
                SvgPicture.asset(iconLocation, height: 14),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(location, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(1.5),
            child: Row(
              children: [
                SizedBox(width: sizes.GetWidth() * 1),
                SvgPicture.asset(iconPrice,
                    color: theme.GetColor("secondaryPrimary")),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(price,
                    style: TextStyle(
                        color: theme.GetColor("secondaryPrimary"))),
                SizedBox(width: sizes.GetWidth() * 1),
                SvgPicture.asset("assets/icon/SAR.svg",
                    color: theme.GetColor("secondaryPrimary")),
              ],
            ),
          ),
          Spacer(),
          if (showButton)
            Align(
              alignment: Alignment.center,
              child: SquareButton(
                height: sizes.GetHeight() * 3.5,
                width: sizes.GetWidth() * 30,
                backgroundColor: theme.GetColor("textPrimary"),
                borderRadius: 30,
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => EventBooking(eventBooking:event),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      buttonText,
                      style: TextStyle(
                          fontSize: 12, color: theme.GetColor("white")),
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(
                            Directionality.of(context) == TextDirection.rtl
                                ? -1.0
                                : 1.0,
                            1.0),
                      child: SvgPicture.asset("assets/icon/arrow.svg",
                          color: theme.GetColor("white"), width: 14),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: sizes.GetHeight() * 1),
        ],
      ),
    );
  }
}
