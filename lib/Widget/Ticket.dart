import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
class Ticket extends StatelessWidget {
  final int bookingNumber;
  final double payAmount;
  final String checkInDate;
  final String checkInTime;
  final int childrenCount;
  final String tableNumber;
  final int party_size;
  final double? width;
  final double? height;
  const Ticket({
    super.key,
    required this.bookingNumber,
    required this.payAmount,
    required this.checkInDate,
    required this.checkInTime,
    required this.childrenCount,
    required this.tableNumber,
    required this.party_size,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final themes = Themes();
    final textLanguage = TextLanguage();
    return Container(
      width: width,
      height: height,
      child: Column(
        children: [
          Stack(
            children: [
              // الصورة الأساسية
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  "assets/images/ticket.png",
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                ),
              ),
              // التدرج اللوني
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Themes().GetColor("primary").withOpacity(0.99),
                        Themes().GetColor("primary").withOpacity(0.9),
                      ],
                      stops: [0.05, 0.95],
                    ),
                  ),
                ),
              ),
              // المحتوى
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(sizes.GetWidth() * 1.5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // الشعار والأيقونة العلوية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            height: sizes.GetHeight() * 10,
                            "assets/images/rafatstay.svg",
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          Image.asset(
                            height: sizes.GetHeight() * 4,
                            "assets/images/2a5306d7a071efa3bdacf0083e5786fd48e2dfd9.png",
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: Directionality.of(context) == TextDirection.rtl
                            ? [
                          SvgPicture.asset(
                            "assets/icon/SAR.svg",
                            height: sizes.GetHeight() * 2,
                            color: themes.GetColor("secondary500"),
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          Flexible(
                            child: Text(
                              "${textLanguage.GetWord("رقم الحجز")} $bookingNumber ${textLanguage.GetWord("الدفع")} $payAmount",
                              style: TextStyle(
                                fontSize: sizes.GetHeight() * 2,
                                fontWeight: FontWeight.bold,
                                color: themes.GetColor("secondary500"),
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ]
                            : [
                          Flexible(
                            child: Text(
                              "${textLanguage.GetWord("رقم الحجز")} $bookingNumber ${textLanguage.GetWord("الدفع")} $payAmount",
                              style: TextStyle(
                                fontSize: sizes.GetHeight() * 2,
                                fontWeight: FontWeight.bold,
                                color: themes.GetColor("secondary500"),
                              ),
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                          SizedBox(width: sizes.GetWidth() * 2),
                          SvgPicture.asset(
                            "assets/icon/SAR.svg",
                            height: sizes.GetHeight() * 2,
                            color: themes.GetColor("secondary500"),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GradientCircleWithText(
                            size: sizes.GetWidth() * 14,
                            borderWidth: 1.5,
                            gradientColors: [
                              Color(0xFFC19632),
                              Color(0xFF082133),
                            ],
                            text: checkInDate,
                            svgPath: "assets/icon/SiteData.svg",
                            svgHeight: sizes.GetHeight() * 2.2,
                            svgColor: themes.GetColor("white"),
                          ),
                          GradientCircleWithText(
                            size: sizes.GetWidth() * 14,
                            borderWidth: 1.5,
                            gradientColors: [
                              Color(0xFFC19632),
                              Color(0xFF082133),
                            ],
                            text: checkInTime,
                            svgPath: "assets/icon/hour.svg",
                            svgHeight: sizes.GetHeight() * 2.2,
                            svgColor: themes.GetColor("white"),
                          ),
                          GradientCircleWithText(
                            size: sizes.GetWidth() * 14,
                            borderWidth: 1.5,
                            gradientColors: [
                              Color(0xFFC19632),
                              Color(0xFF082133),
                            ],
                            text: "$party_size",
                            svgPath: "assets/icon/user_plus.svg",
                            svgHeight: sizes.GetHeight() * 2,
                            svgColor: themes.GetColor("white"),
                          ),
                          GradientCircleWithText(
                            size: sizes.GetWidth() * 14,
                            borderWidth: 1.5,
                            gradientColors: [
                              Color(0xFFC19632),
                              Color(0xFF082133),
                            ],
                            text: "$childrenCount",
                            svgPath: "assets/icon/children.svg",
                            svgHeight: sizes.GetHeight() * 2.2,
                            svgColor: themes.GetColor("white"),
                          ),
                          GradientCircleWithText(
                            size: sizes.GetWidth() * 14,
                            borderWidth: 1.5,
                            gradientColors: [
                              Color(0xFFC19632),
                              Color(0xFF082133),
                            ],
                            text: "$tableNumber",
                            svgPath: "assets/icon/TableDetails.svg",
                            svgHeight: sizes.GetHeight() * 2.2,
                            svgColor: themes.GetColor("white"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== GradientCircleWithText Widget ====================
class GradientCircleWithText extends StatelessWidget {
  final double size;
  final double borderWidth;
  final List<Color> gradientColors;
  final String text;
  final TextStyle? textStyle;
  final String svgPath;
  final double svgHeight;
  final Color svgColor;

  const GradientCircleWithText({
    super.key,
    required this.size,
    this.borderWidth = 1.5,
    required this.gradientColors,
    required this.text,
    this.textStyle,
    required this.svgPath,
    required this.svgHeight,
    required this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomPaint(
          size: Size(size, size),
          painter: _GradientCirclePainter(
            strokeWidth: borderWidth,
            colors: gradientColors,
          ),
          child: SizedBox(
            width: size,
            height: size,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    svgPath,
                    height: svgHeight,
                    color: svgColor,
                  ),
                  SizedBox(height: size * 0.05),
                  Text(
                    text,
                    style: textStyle ??
                        TextStyle(
                          color: svgColor,
                          fontSize: size * 0.20,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ==================== Gradient Circle Painter ====================
class _GradientCirclePainter extends CustomPainter {
  final double strokeWidth;
  final List<Color> colors;

  _GradientCirclePainter({
    required this.strokeWidth,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: colors,
      ).createShader(rect);

    canvas.drawOval(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}