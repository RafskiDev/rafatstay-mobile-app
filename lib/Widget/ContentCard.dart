import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../Service/ApiService.dart';
import '../Utils/Sizes.dart';
import '../Utils/TextLanguage.dart';
import '../Utils/Them.dart';
import '../View/MealDetails/MealDetails.dart';
import 'ShowLoading.dart';
import 'WidgetButton.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
class ContentCard extends StatelessWidget {
  final bool liked;
  final VoidCallback onLikeTap;
  final bool showIcon;
  final String imagePath;
  final String title;
  final String subTitle;
  final String description;
  final String circleImagePath;
  final String buttonText;
  final VoidCallback onButtonTap;
  final double width;
  final double height;
  final Widget? additionalInfo;
  final Color?  borderColor;
  final int? menuItemId;

   ContentCard({
    super.key,
    required this.liked,
    required this.onLikeTap,
    required this.showIcon,
    required this.imagePath,
    required this.title,
     this.subTitle='',
    required this.description,
    required this.circleImagePath,
    required this.buttonText,
    required this.onButtonTap,
    required this.width,
    required this.height,
    this.additionalInfo, // اختياري
    this.borderColor,
    required this.menuItemId,
  });

  @override
  Widget build(BuildContext context) {
   // print(imagePath);
    final theme = Themes();
    final sizes = Sizes(context);
    final storage = GetStorage();
    final int language = storage.read("Language") ?? 1;
    final bool isEnglish = (language != 1);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                MealDetails(title:title,image:imagePath, menuItemId: menuItemId??0),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: theme.GetColor("scaffoldBackground"),
          border:Border.all(color:borderColor??Colors.transparent,width:0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        clipBehavior: Clip.hardEdge,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            /// الصورة + الأيقونة
            SizedBox(
              height: height * 0.45,
              child: Stack(
                children: [
                  //صوره العرض تبطع المطعم
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: CachedNetworkImage(
                      imageUrl:imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) =>  Center(
                        child:showLoading(),
                      ),
                      //ضفت هذا حتى لا يطبع الخطا
                      errorListener: (dynamic exception) {
                      },
                      errorWidget: (context, url, error) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
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
                  /*
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),

                   */
                  if (showIcon)
                    Positioned(
                      top: 8,
                      right: isEnglish ? 8 : null,
                      left: isEnglish ? null : 8,
                      child: GestureDetector(
                        onTap: onLikeTap,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: SvgPicture.asset(
                            liked
                                ? "assets/icon/like.svg"
                                : "assets/icon/unlike.svg",
                            height: 22,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            /// المحتوى
            Padding(
              padding: EdgeInsets.all(sizes.GetWidth() * 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min, // مهم هنا
                children: [
                  Row(
                    children: [
                      //هذي صوره لوكو تبع المطعم
                      CircularButton(
                        size:22,
                        onTap: () {},
                        backgroundColor:
                        theme.GetColor("secondaryPrimary"),
                        borderColor:theme.GetColor("secondaryPrimary"),
                        child: Image.asset(
                          circleImagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(width: sizes.GetWidth() * 2),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sizes.GetHeight() * 0.5),
                  if (subTitle.isNotEmpty)
                    Text(
                      subTitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                  ),
                  SizedBox(height: sizes.GetHeight() * 0.5),
                  description.isNotEmpty?SizedBox(
                    height:sizes.GetHeight() * 4.6,
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ):SizedBox.shrink(),
                  if (additionalInfo != null) additionalInfo!,
                  SizedBox(height: sizes.GetHeight() * 0.5),
                 // Spacer(),
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SquareButton(
                          width: width * 0.50,
                          height: sizes.GetHeight() * 3.5,
                          onTap: onButtonTap,
                          backgroundColor: theme.GetColor("primary"),
                          borderRadius: 15,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                buttonText,
                                style:
                                const TextStyle(fontSize: 11),
                              ),
                              SizedBox(
                                  width: sizes.GetWidth() * 1.2),
                              Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.rotationY(
                                  Directionality.of(context) == TextDirection.rtl ? 3.1416 : 0,
                                ),
                                child: SvgPicture.asset(
                                  "assets/icon/arrow.svg",
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

    );
  }
}

class MealCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Sizes sizes;
  final Themes theme;
  final VoidCallback? onTap;
  final VoidCallback? onTapDelete;
  final bool isSelected;
  final VoidCallback? onToggleSelect;
  final bool showCheckbox;
  const MealCard({
    super.key,
    required this.item,
    required this.sizes,
    required this.theme,
    this.onTap,
    this.onTapDelete,
    this.isSelected = false,
    this.onToggleSelect,
    this.showCheckbox = false,
  });

  @override
  Widget build(BuildContext context) {
    final textLanguage = TextLanguage();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(sizes.GetWidth() * 4),
        border: Border.all(color:theme.GetColor("white"), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(sizes.GetWidth() * 4),
                  topRight: Radius.circular(sizes.GetWidth() * 4),
                ),
                child: InkWell(
                  onTap:(){
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            MealDetails(title:item["title"],image:item["image"]??"", menuItemId:int.parse(item["id"].toString()) ,),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl:item["image"]??"",
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: sizes.GetHeight() * 14,
                    placeholder: (context, url) =>  Center(
                      child:showLoading(),
                    ),
                    //ضفت هذا حتى لا يطبع الخطا
                    errorListener: (dynamic exception) {
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        width: double.infinity,
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
              ),
              if(showCheckbox)
              Positioned(
                top: sizes.GetWidth() * 1,
                right: sizes.GetWidth() * 1,
                child: InkWell(
                  onTap: onToggleSelect,
                  child: SvgPicture.asset(
                    isSelected
                        ? "assets/icon/BOXCHECK_ON.svg"
                        : "assets/icon/BOXCHECK_OFF.svg",
                    height: sizes.GetHeight() * 3,
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(sizes.GetWidth() * 0.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Center(
                    child: Text(
                      item["title"]??"",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sizes.GetHeight() * 1.7,
                      ),
                    ),
                  ),
                  item["price"]!=null && item["isEvent"]==null?InfoRow(
                    icon: "assets/icon/dollar.svg",
                    text: "${textLanguage.GetWord("سعر")}: ${item["price"]}",
                    sizes: sizes,
                    icon_tow: 'assets/icon/SAR.svg',
                  ):Container(),
                  item["sold_count"]!=null?InfoRow(
                    color: theme.GetColor("primaryA"),
                    icon: "assets/icon/Badge.svg",
                    text: "${textLanguage.GetWord("مباع")} ${item["sold_count"]??""}",
                    sizes: sizes,
                  ):Container(),
                  Expanded(
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          "assets/icon/MealTime.svg",
                          width: sizes.GetHeight() * 1.6,
                          height: sizes.GetHeight() * 1.6,
                        ),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Flexible(
                          child: Text(
                            item["time"] != null
                                ? "${item["time"]} ${textLanguage.GetWord("دقائق")}"
                                : "0-0 ${textLanguage.GetWord("دقائق")}",
                            style: TextStyle(fontSize: sizes.GetHeight() * 1.5),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        SizedBox(width: sizes.GetWidth() * 1),
                        if (item["is_spicy"] == true)
                          SvgPicture.asset(
                            "assets/icon/HighTemperature.svg",
                            width: sizes.GetHeight() * 1.8,
                            height: sizes.GetHeight() * 1.8,
                          )
                        else if (item["is_spicy"] == false)
                          SvgPicture.asset(
                            "assets/icon/ColdTemperature.svg",
                            width: sizes.GetHeight() * 1.8,
                            height: sizes.GetHeight() * 1.8,
                          )
                        else
                          SizedBox.shrink(),
                      ],
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 1),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.GetColor("backgroundOffWhite"),
                      borderRadius: BorderRadius.circular(sizes.GetWidth() * 5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          onTap: onTapDelete,
                          child: SvgPicture.asset(
                            "assets/icon/DeleteBasket.svg",
                            height: sizes.GetHeight() * 2.8,
                          ),
                        ),
                        Text(
                          (item['count'] ?? 0).toString(),
                          style: TextStyle(
                            fontSize: sizes.GetHeight() * 2.7,
                            fontWeight: FontWeight.bold,
                            color: theme.GetColor("textSecondary"),
                          ),
                        ),
                        InkWell(
                          onTap:onTap,
                          child: Container(
                            width: sizes.GetHeight() * 3.3,
                            height: sizes.GetHeight() * 3.3,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:item['potsEmpty'] == true?
                              theme.GetColor("secondary500")
                                  :theme.GetColor("textSecondary"),
                            ),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              item['potsEmpty'] == true
                                  ? "assets/icon/pots.svg"
                                  : "assets/icon/potsEmpty.svg",
                              height: sizes.GetHeight() * 1.8,
                              // color: theme.GetColor("secondary500"),
                            ),
                          ),
                        )
                      ],
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

class InfoRow extends StatelessWidget {
  final String icon;
  final String? icon_tow;
  final String text;
  final Sizes sizes;
  final Color? color;

  const InfoRow({
    required this.icon,
     this.icon_tow,
    required this.text,
    required this.sizes,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Themes();
    return Row(
      children: [
        SvgPicture.asset(
          icon,
          width: sizes.GetHeight() * 1.6,
          height: sizes.GetHeight() * 1.6,
          color:color??theme.GetColor("textPrimary"),
        ),
        SizedBox(width: sizes.GetWidth() * 1),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: sizes.GetHeight() * 1.5),
          maxLines: 1,
        ),
        SizedBox(width: sizes.GetWidth() * 1),
        icon_tow!=null?SvgPicture.asset(
          icon_tow!,
          height: sizes.GetHeight() * 1.5,
          color:theme.GetColor("textPrimary"),
        ):Container(),
      ],
    );
  }
}