import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../RestaurantDetalis_riverpod.dart';
Widget Garage(BuildContext context, String title, String image,WidgetRef ref) {
  final Color secondaryColor = Themes().GetColor("secondary");
  final garage = ref.read(RestaurantDetalis_riverpod.notifier).garage;
  if (garage.isEmpty) return Container();
  return Container(
    width: double.infinity,
    height: Sizes(context).GetHeight() * 25,
    decoration: BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(25),
      border: Border.all(
        color: secondaryColor,
        width: 1,
      ),
    ),
    child: Row(
      children: [
        // القسم الأيسر: الصورة
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(23),
            bottomLeft: Radius.circular(23),
          ),
          child: Image.asset(
            image,
            width: MediaQuery.of(context).size.width * 0.35,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(width: Sizes(context).GetWidth() * 2),
        Expanded(
          child:Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // العنوان
              Text(
                title,
                style: TextStyle(
                  color: Themes().GetColor("textPrimary"),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                   buildIconText(context,"assets/icon/Status.svg", "Status: ${garage[0][["available"]] ?? false ? "Available" : "Not Available"}", secondaryColor),
                   SizedBox(width: Sizes(context).GetWidth() * 1),
                   buildIconText(context,"assets/icon/Spots.svg", "Spots: ${garage[0]["total_spots"] ?? 0}", secondaryColor),
                ],
              ),
              buildIconText(context,"assets/icon/Parking.svg", "Parking Type: ${garage[0]["parking_available"]}", secondaryColor),
              Row(
                children: [
                  buildIconText(context,"assets/icon/dollar.svg", "Price:${garage[0]["price"]??0}", secondaryColor),
                  SizedBox(width: Sizes(context).GetWidth() * 1),
                  buildIconText(
                    context,
                    "assets/icon/time.svg",
                    "Duration: ${garage[0]["open_time"] ?? "N/A"}",
                    secondaryColor,
                  ),
                ],
              ),
              buildIconText(context,"assets/icon/Reservations.svg", "Reservation: With table booking", secondaryColor),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget buildIconText(BuildContext context,String icon, String text, Color color) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
     SvgPicture.asset(icon,color:color,height:Sizes(context).GetHeight() * 2),
     SizedBox(width: Sizes(context).GetWidth() * 0.5),
      Flexible(
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}