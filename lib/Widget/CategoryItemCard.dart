import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
class CategoryItemCard extends StatelessWidget {
  final String imagePath;       // الصورة الرئيسية
  final double width;           // عرض الحاوية
  final double height;          // ارتفاع الحاوية
  final String? name;           // الاسم أسفل الصورة
  final String? nameImagePath;  // الصورة داخل اسم العنصر
  final bool circularNameImage; // هل تكون الصورة داخل الاسم دائرية
  final int? paddings;
  final VoidCallback onTap;
  const CategoryItemCard({
    Key? key,
    required this.imagePath,
    required this.width,
    required this.height,
    this.name,
    this.nameImagePath,
    this.circularNameImage = true,
    this.paddings,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Themes(); // افترض أن لديك كلاس Themes
    final sizes = Sizes(context);
    return InkWell(
      onTap:onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: width,
              height: height,
              child: CircleAvatar(
                backgroundImage: AssetImage(imagePath),
              )
          ),
          if (name != null) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal:sizes.GetWidth()*0.5),
              margin: EdgeInsets.only(right:sizes.GetWidth()*1),
              height:sizes.GetHeight()*3.5,
              decoration: BoxDecoration(
                color:Color(0xFFDFC486),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (nameImagePath != null) ...[
                    Container(
                      width: 25,
                      height:25,
                      padding: EdgeInsets.all(paddings?.toDouble() ?? 0),
                      decoration: BoxDecoration(
                        color:theme.GetColor("secondaryPrimary"),
                        borderRadius: BorderRadius.circular(circularNameImage ? 12.5 : 0),
                      ),
                      child:Image.asset(
                        nameImagePath!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                  Flexible(
                    child: Text(
                      name!,
                      style: TextStyle(
                        color:theme.GetColor("textPrimary"),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}