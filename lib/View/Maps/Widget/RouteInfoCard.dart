import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Widget/WidgetButton.dart';
class RouteInfoCard extends StatelessWidget {
  final int id;
  final String distance;
  final String duration;
  final String arrivalTime;
  final VoidCallback? onRouteTap;
  final VoidCallback? onCloseTap;

  const RouteInfoCard({
    super.key,
    required this.id,
    required this.distance,
    required this.duration,
    required this.arrivalTime,
    this.onRouteTap,
    this.onCloseTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Sizes(context).GetWidth() * 4,
        vertical: Sizes(context).GetHeight() * 2,
      ),
      decoration: BoxDecoration(
        color: Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Themes().GetColor("primary").withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // أيقونة الشخص
          SvgPicture.asset("assets/icon/directions_walk_rounded.svg"),

          SizedBox(height: Sizes(context).GetHeight() * 1.5),

          // Booking Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset("assets/icon/BookingNumber.svg"),
              SizedBox(width: Sizes(context).GetWidth() * 1.5),
              Text(
                "Booking Number ${id}",
                style: TextStyle(
                  color: Themes().GetColor("primary"),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          SizedBox(height: Sizes(context).GetHeight() * 1),

          // المسافة . وقت الوصول
          Text(
            "$distance . $arrivalTime",
            style: TextStyle(
              color: Themes().GetColor("textPrimary"),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: Sizes(context).GetHeight() * 2),

          // زر View Booking details
          SquareButton(
            width: Sizes(context).GetWidth() * 90,
            height: Sizes(context).GetHeight() * 6,
            onTap:onRouteTap!,
            backgroundColor: Themes().GetColor("primaryA"),
            borderRadius: 25,
            child: Text(
              "View Booking details",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}