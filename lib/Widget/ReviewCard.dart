import 'package:flutter/material.dart';
import '../Service/ApiService.dart';
import '../Utils/Sizes.dart';
import '../Utils/Them.dart';
import 'ShowLoading.dart';
import 'VideoImageCard.dart';
import 'WidgetButton.dart';
import 'package:cached_network_image/cached_network_image.dart';
class ReviewCard extends StatelessWidget {
  final String name;
  final String date;
  final String? comment;
  final String? video;
  final String? imageOnly;
  final String image;
  final int rating;
  final Sizes sizes;
  final Themes theme;
  final VoidCallback? onAvatarTap;
  final List<dynamic> mediaItems;
  const ReviewCard({
    super.key,
    required this.name,
    required this.date,
    this.comment,
    this.imageOnly,
    this.video,
    required this.image,
    required this.rating,
    required this.sizes,
    required this.theme,
    this.onAvatarTap,
    this.mediaItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(sizes.GetWidth() * 3),
      decoration: BoxDecoration(
        border: Border.all(color: theme.GetColor("textPrimary")),
        borderRadius: BorderRadius.circular(sizes.GetWidth() * 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularButton(
                backgroundColor: theme.GetColor("primaryS"),
                borderColor: theme.GetColor("white"),
                size: sizes.GetHeight() * 7,
                onTap: onAvatarTap ?? () {},
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: "$showImage$image",
                    width: sizes.GetHeight() * 7,
                    height: sizes.GetHeight() * 7,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Image.asset(
                      "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                      fit: BoxFit.cover,
                    ),
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),

              SizedBox(width: sizes.GetWidth() * 3),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: sizes.GetHeight() * 2,
                    ),
                  ),
                  SizedBox(height: sizes.GetHeight() * 0.5),
                  Text(
                    date,
                    style: TextStyle(
                      color: const Color(0xFF90CAF9),
                      fontSize: sizes.GetHeight() * 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: sizes.GetHeight() * 2),

          /// ===== Rating
          Row(
            children: List.generate(
              5,
                  (index) => Icon(
                Icons.star,
                size: sizes.GetHeight() * 2.2,
                color: index < rating
                    ? Colors.amber
                    : Colors.grey.shade300,
              ),
            ),
          ),

          SizedBox(height: sizes.GetHeight() * 2),

          /// ===== Comment
         if (comment != null && comment!.trim().isNotEmpty)
          Text(
            comment!,
            style: TextStyle(
              fontSize: sizes.GetHeight() * 1.8,
              color: theme.GetColor("primary"),
              height: 1.4,
            ),
          ),
          if (video != null && video!.trim().isNotEmpty)
          VideoImageCard(
            imagePath:video!,
            width:double.infinity,
            height:Sizes(context).GetHeight()*25,
          ),
          if (imageOnly != null && imageOnly!.trim().isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: sizes.GetHeight() * 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Sizes(context).GetWidth() * 14),
                child: CachedNetworkImage(
                  imageUrl:imageOnly!,
                  width: double.infinity,
                  height: Sizes(context).GetHeight() * 25,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>  Center(
                    child:showLoading(),
                  ),
                  //ضفت هذا حتى لا يطبع الخطا
                  errorListener: (dynamic exception) {
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      width: double.infinity,
                      height: Sizes(context).GetHeight() * 25,
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

        ],
      ),
    );
  }
}
