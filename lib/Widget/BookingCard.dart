import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Utils/Sizes.dart';
import '../Utils/TextLanguage.dart';
import '../Utils/Them.dart';
import 'ShowLoading.dart';
import 'WidgetButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
class BookingCard extends StatelessWidget {
  final int? id;
  final String mainImage;
  final String? bookingNumber;
  final String? price;
  final String? paymentMethod;
  final String? restaurantName;
  final String? restaurantLocation;
  final String restaurantLogo;
  final String? date;
  final String? time;
  final bool footer;
  final String textOnTap;
  final VoidCallback onTap;
  final VoidCallback onTap_;
  const BookingCard({
    super.key,
    this.id,
    required this.mainImage,
    this.bookingNumber,
    this.price,
    this.paymentMethod,
    this.restaurantName,
    this.restaurantLocation,
    required this.restaurantLogo,
    this.date,
    this.time,
    this.footer = true,
    required this.textOnTap,
    required this.onTap,
    required this.onTap_,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5EB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _image(context),
              SizedBox(width: Sizes(context).GetWidth()*2),
              _info(context),
            ],
          ),
          _buttons(context,id!),
          if(footer)SizedBox(height: Sizes(context).GetHeight()*2),
          if(footer)_footer(context),
        ],
      ),
    );
  }

  // 📷 Image
  Widget _image(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child:  CachedNetworkImage(
        imageUrl:mainImage,
        width: Sizes(context).GetWidth()*30,
        height: Sizes(context).GetHeight()*14,
        fit: BoxFit.cover,
        placeholder: (context, url) =>  Center(
          child:showLoading(),
        ),
        errorListener: (dynamic exception) {
        },
        errorWidget: (context, url, error) {
          return Container(
            width: Sizes(context).GetWidth()*30,
            height: Sizes(context).GetHeight()*14,
            color: const Color(0xFFEEEEEE),
            child: const Icon(
              Icons.image_not_supported,
              size: 40,
              color: Colors.grey,
            ),
          );
        },
      ),

    );
  }

  // ℹ️ Booking Info
  Widget _info(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          bookingNumber!.isNotEmpty?_InfoRow(
            icon1: "assets/icon/PromoTag.svg",
            text: '${TextLanguage().GetWord("رقم الحجز")} ${bookingNumber}',
          ):const SizedBox.shrink(),
          SizedBox(height: Sizes(context).GetHeight()*1),
          if(price!.isNotEmpty && paymentMethod!.isNotEmpty)...[
            _InfoRow(
              icon1: "assets/icon/LikePrice.svg",
              icon3: "assets/icon/SAR.svg",
              text: '${TextLanguage().GetWord('يدفع')} ${price}',
              subText:paymentMethod!,
            ),
            SizedBox(height: Sizes(context).GetHeight()*1),
          ],
          if(restaurantName!.isNotEmpty && restaurantLocation!.isNotEmpty)...[
             _InfoRow(
              icon2: restaurantLogo,
              text: restaurantName!,
              subText:restaurantLocation!,
             ),
            SizedBox(height: Sizes(context).GetHeight()*1),
          ],
          Row(
            children: [
              SvgPicture.asset("assets/icon/SiteData.svg",color:Themes().GetColor("textSecondary"),height:Sizes(context).GetHeight()*1.5,),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(date??"",style:TextStyle(color:Themes().GetColor("textSecondary"))),
              SizedBox(width: Sizes(context).GetWidth()*5),
              SvgPicture.asset("assets/icon/time.svg",color:Themes().GetColor("textSecondary")),
              SizedBox(width: Sizes(context).GetWidth()*1),
              Text(time??"",style:TextStyle(color:Themes().GetColor("textSecondary"))),
            ],
          )
        ],
      ),
    );
  }

  // 🔘 Buttons
  Widget _buttons(BuildContext context,int id) {
    return Row(
      children: [
        Expanded(
            child: WidgetButton(
              buttonSize:Sizes(context).GetHeight()*1.9,
              context: context,
              isCircular: true,
              buttonText: TextLanguage().GetWord('تفاصيل الحجز'),
              onPressed:onTap_,
              textColor:Themes().GetColor("textPrimary"),
              borderColor:Themes().GetColor("textPrimary"),
              backgroundColor:const Color(0xFFFAF5EB),
            )
        ),
        SizedBox(width: Sizes(context).GetWidth()*2),
        Expanded(
          child: WidgetButton(
            buttonSize:Sizes(context).GetHeight()*1.9,
            isCircular: true,
            context: context,
            buttonText:textOnTap,
            onPressed:onTap,
            textColor:Themes().GetColor("textPrimary"),
            backgroundColor:Themes().GetColor("primaryA"),
          ),
        ),
      ],
    );
  }

  // ⭐ Footer
  Widget _footer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:  [
        SvgPicture.asset("assets/icon/Honoring.svg"),
        SizedBox(width: Sizes(context).GetWidth()*1),
        Text(
          TextLanguage().GetWord("اكسب نقاط ولاء مقابل تقييمك"),
          style: TextStyle(fontSize: 13),
        ),
      ],
    );
  }
}


// 🔹 Reusable Row
class _InfoRow extends StatelessWidget {
  final String icon1;
  final String icon2;
  final String icon3;
  final String text;
  final String subText;

  const _InfoRow({
    this.icon1 = '',
    this.icon2 = '',
    this.icon3 = '',
    required this.text,
    this.subText = '',
  });

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ─── Icon 1 (SVG) ───
        if (icon1.isNotEmpty)
          SvgPicture.asset(
            icon1,
            width: sizes.GetHeight() * 2,
            height: sizes.GetHeight() * 2,
            color: theme.GetColor("textPrimary"),
          ),

        // ─── Icon 2 (Logo دائري) ───
        if (icon2.isNotEmpty)
          CircularButton(
            size: sizes.GetHeight() * 3,
            onTap: () {},
            backgroundColor: theme.GetColor("secondary500"),
            borderColor: theme.GetColor("primary"),
            borderWidth: 0.5,
            child: Image.asset(icon2),
          ),

        SizedBox(width: sizes.GetWidth() * 2),

        // ─── النصوص ───
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── text + icon3 في نفس السطر ───
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: theme.GetColor("textPrimary"),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (icon3.isNotEmpty) ...[
                    SizedBox(width: sizes.GetWidth() * 1),
                    SvgPicture.asset(
                      icon3,
                      height: sizes.GetHeight() * 1.5,
                      color: theme.GetColor("textPrimary"),
                    ),
                  ],
                ],
              ),

              // ─── subText في سطر منفصل ───
              if (subText.isNotEmpty) ...[
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.GetColor("textSecondary"),
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}