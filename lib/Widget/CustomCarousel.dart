import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../Utils/Sizes.dart';
import '../Utils/TextLanguage.dart';
import '../Utils/Them.dart';
import 'CarouselIndicator.dart';
import 'WidgetButton.dart';

class CustomCarousel extends StatelessWidget {
  final List<dynamic> items; // يمكن أن يكون String (صورة) أو Map (gradient)
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final double indicatorHeight;
  final double indicatorSpacing;
  final VoidCallback onTap;
  final int currentIndex;
  final void Function(int) onPageChanged;

  const CustomCarousel({
    Key? key,
    required this.items,
    required this.currentIndex,
    required this.onPageChanged,
    this.height = 160,
    this.activeColor = Colors.blue,
    this.inactiveColor = const Color(0xFFD3E9F8),
    this.indicatorHeight = 8,
    this.indicatorSpacing = 4,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Themes();
    final sizes = Sizes(context);
   // print(items);
    return Column(
      children: [
        CarouselSlider(
          items: items.map((item) {
            if (item is String) {
              if(item.isNotEmpty){
                return ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    item,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                );
              }
            }
            // ✅ إذا كان Map يحتوي على ألوان للـ gradient
            else if (item is Map<String, dynamic>) {
              return CarouselTextImageItem(
                item: item,
                height: height,
                onTap: onTap,
              );
            }
            // في حالة نوع غير معروف
            return Container();
          }).toList(),
          options: CarouselOptions(
            height: height,
            viewportFraction: 1.0,
            autoPlay: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
        ),
        SizedBox(height: sizes.GetHeight()*1),
        CarouselIndicator(
          itemCount: items.length,
          currentIndex: currentIndex,
          activeColor: theme.GetColor("primary"),
          inactiveColor: Colors.grey.shade300,
        ),
      ],
    );
  }
}

class CarouselTextImageItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final double height;
  final VoidCallback onTap;


  const CarouselTextImageItem({
    super.key,
    required this.item,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();
    final language = TextLanguage();
    final Color leftColor = Color(0xFFA56C0B);
    final Color rightColor = Color(0xFFF4EBD7);
    final String? title = item['name']??item['title'];
    final String? subtitle = item['description'];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [leftColor, rightColor],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      overflow: TextOverflow.ellipsis,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if(subtitle != null)
                  Text(
                    subtitle,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12,overflow: TextOverflow.ellipsis),
                  ),
                Flexible(child:Container()),
                SquareButton(
                  height: sizes.GetHeight() * 3.5,
                  width: sizes.GetWidth() * 20,
                  backgroundColor: theme.GetColor("textPrimary"),
                  borderRadius:30,
                  onTap: onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        language.GetWord("اكتشف"),
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.GetColor("white"),
                        ),
                      ),
                      SizedBox(width: sizes.GetWidth() * 0.5),
                      Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..scale(
                            Directionality.of(context) == TextDirection.rtl
                                ? -1.0
                                : 1.0,
                            1.0,
                          ),
                        child: SvgPicture.asset(
                          "assets/icon/arrow.svg",
                          color: theme.GetColor("white"),
                          width: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if(item['image']!=null)
          Directionality(
            textDirection:
            language.storage.read("Language") == 0
                ? TextDirection.rtl
                : TextDirection.ltr,
            child: PositionedDirectional(
              start: sizes.GetWidth() * 0,
              top: sizes.GetHeight() * 4,
              child: Image.network(
                item['image']??"",
                height: height * 0.5,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  "assets/images/ChickenDish.png",
                  height: height * 0.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}