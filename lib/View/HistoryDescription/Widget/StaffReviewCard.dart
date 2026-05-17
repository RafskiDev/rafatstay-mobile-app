import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/Sizes.dart';

import '../../../Utils/Them.dart';

class StaffReviewCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final List<Map<String, dynamic>> ratings; // {'label': 'Attitude', 'score': 5, 'max': 5}
  final String reviewText;
  final double tipAmount;
  final VoidCallback? onTip;

  const StaffReviewCard({
    super.key,
    required this.name,
    required this.role,
    required this.imageUrl,
    required this.ratings,
    required this.reviewText,
    required this.tipAmount,
    this.onTip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:Themes().GetColor("backgroundOffWhite"),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 0.4,
            blurRadius: 0.8,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ClipOval(
                child: imageUrl.startsWith('http')
                    ? Image.network(imageUrl, width: 42, height: 42, fit: BoxFit.cover)
                    : Image.asset(imageUrl, width: 42, height: 42, fit: BoxFit.cover),
              ),
              SizedBox(width: Sizes(context).GetWidth()*2),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                    TextSpan(
                      text: ' ($role)',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF7A6A55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ratings.map((r) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _RatingChip(
                    label: r['label'],
                    score: r['score'],
                    max: r['max'] ?? 5,
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          // Review text
          Text(
            reviewText,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF4A3F30),
            ),
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          // Tip button
          GestureDetector(
            onTap: onTip,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color:Themes().GetColor("backgroundOffWhite"),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 0.4,
                    blurRadius: 0.8,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/icon/LikePrice.svg',
                    height: 18,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF4A3F30),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(width: Sizes(context).GetWidth()*2),
                  Text(
                    '${tipAmount % 1 == 0 ? tipAmount.toInt() : tipAmount}\$ Tips',
                    style:TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color:Themes().GetColor("secondaryPrimary"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingChip extends StatelessWidget {
  final String label;
  final num score;
  final num max;

  const _RatingChip({
    required this.label,
    required this.score,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color:Themes().GetColor("borderLight"), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF2C2C2C),
            ),
          ),
          SizedBox(width: Sizes(context).GetWidth()*1),
          SvgPicture.asset("assets/icon/Star.svg",height:Sizes(context).GetHeight()*2),
          SizedBox(width: Sizes(context).GetWidth()*1),
          Text(
            '$score/$max',
            style:TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color:Themes().GetColor("textSecondary"),
            ),
          ),
        ],
      ),
    );
  }
}