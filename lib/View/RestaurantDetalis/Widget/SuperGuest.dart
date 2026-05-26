import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../Widget/ShowLoading.dart';
import '../RestaurantDetalis_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
Widget SuperGuest(BuildContext context,WidgetRef ref){
  final superGuests = ref.read(RestaurantDetalis_riverpod.notifier).superGuests;
  if (superGuests.isEmpty || !superGuests[0]["is_super_guest"]) return Container();
  final sizes = Sizes(context);
  final theme = Themes();
  return GridView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: sizes.GetWidth() * 1,
      childAspectRatio:  0.55,
    ),
    itemCount: superGuests.length,
    itemBuilder: (context, index) {

      return Container(
        width:sizes.GetWidth()*39,
        height:sizes.GetHeight()*22,
        decoration:BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child:Column(
          children: [
            Container(
              height: sizes.GetHeight() * 10,
              decoration: BoxDecoration(
                border: Border.all(
                  color:Themes().GetColor("secondary"),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child:CachedNetworkImage(
                  imageUrl:superGuests[index]["image"]??"",
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
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/profile_stars.svg",height:sizes.GetHeight()*2,color:theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(superGuests[index]["name"],style:TextStyle(color:theme.GetColor("primaryA"))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/Since.svg",height:sizes.GetHeight()*2,color:theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(superGuests[index]["member_since"],style:TextStyle(color:theme.GetColor("textPrimary"))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/Visits.svg",height:sizes.GetHeight()*2,color:theme.GetColor("primaryA")),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(superGuests[index]["visits_count"],style:TextStyle(color:theme.GetColor("textPrimary"))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/benefit.svg",height:sizes.GetHeight()*2),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(superGuests[index]["benefit"],style:TextStyle(color:theme.GetColor("textPrimary"))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(superGuests[index]["discount_percentage"],style:TextStyle(color:theme.GetColor("textPrimary"))),
              ],
            ),
          ],
        ),
      );
    },
  );
}