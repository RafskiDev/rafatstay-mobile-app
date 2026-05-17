import 'package:flutter_svg/svg.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
class VideoImageCard extends StatefulWidget {
  final String imagePath;
  final double width;
  final double height;
  const VideoImageCard({
    super.key,
    required this.imagePath,
    required this.width,
    required this.height,
  });
  @override
  State<VideoImageCard> createState() => _VideoImageCardState();
}

class _VideoImageCardState extends State<VideoImageCard> {
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    // أصغر ضلع نستخدمه للنِسب
    final double baseSize =
    widget.width < widget.height ? widget.width : widget.height;

    // Radius = 25%
    final double borderRadius = baseSize * 0.25;

    // حجم الدائرة = 35%
    final double circleSize = baseSize * 0.35;

    return Stack(
      alignment: Alignment.center,
      children: [
        /// ===== الصورة الأساسية مع Radius 25%
        ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.asset(
            widget.imagePath,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),
        ),

        /// ===== زر التشغيل الزجاجي فوق الصورة
        GestureDetector(
          onTap: () {
            setState(() {
              isPlaying = !isPlaying;
            });
          },
          child:ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: Sizes(context).GetHeight() * 9,
                height: Sizes(context).GetHeight() * 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.25), // شفافية زجاج
                  border: Border.all(
                    color: Colors.white.withOpacity(0.4),
                    width: 0.2,
                  ),
                ),
                alignment: Alignment.center,
                child:Container(
                  width: Sizes(context).GetHeight() * 6,
                  height: Sizes(context).GetHeight() * 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Themes().GetColor("backgroundOffWhite"),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    "assets/icon/play_arrows.svg",
                    height: Sizes(context).GetHeight() * 4, // أيقونة أصغر داخل الدائرة
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}