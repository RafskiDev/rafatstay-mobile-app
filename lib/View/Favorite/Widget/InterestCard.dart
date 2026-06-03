import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/Sizes.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
class InterestCard extends StatelessWidget {
  final String logoUrl;
  final String businessName;
  final String branchName;
  final VoidCallback onTap;
  final double width;
  final double height;

  const InterestCard({
    super.key,
    required this.logoUrl,
    required this.businessName,
    required this.branchName,
    required this.onTap,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding:  EdgeInsets.symmetric(horizontal: Sizes(context).GetWidth() * 2.2, vertical: Sizes(context).GetHeight() * 1.5),
        decoration: BoxDecoration(
          color: Themes().GetColor("scaffoldBackground"),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: Sizes(context).GetHeight()*2.2,
              backgroundColor: const Color(0xFF70551A),
              backgroundImage: logoUrl.isNotEmpty ? NetworkImage(logoUrl) : null,
              child: logoUrl.isEmpty
                  ? const Icon(Icons.store, color: Colors.white, size: 22)
                  : null,
            ),
            SizedBox(width: Sizes(context).GetWidth() * 2),
            Expanded(
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  style: const TextStyle(color: Colors.black, fontSize: 18),
                  children: [
                    TextSpan(
                      text: "$businessName ",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: branchName,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. زر السهم الدائري الجانبي (الأكشن)
            Container(
              width: Sizes(context).GetWidth() * 8.5,
              height: Sizes(context).GetWidth() * 8.5,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFF3EBE1),
              ),
              child: Center(
                child:Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(
                    Directionality.of(context) == TextDirection.rtl ? 3.1416 : 0,
                  ),
                  child: SvgPicture.asset(
                    "assets/icon/arrow.svg",
                    width: Sizes(context).GetWidth() * 6,
                    height: Sizes(context).GetWidth() * 6,
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