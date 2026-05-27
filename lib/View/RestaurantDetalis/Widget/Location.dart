import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Maps/Maps.dart';
import '../RestaurantDetalis_riverpod.dart';
Widget Location(BuildContext context,WidgetRef ref){
  final restaurantDetalis = ref.read(RestaurantDetalis_riverpod.notifier);
  final theme = Themes();
  final sizes = Sizes(context);
  return restaurantDetalis.branches[0]["address_line"]!=null?Column(
    children: [
      Text(restaurantDetalis.branches[0]["description"]??"",style:TextStyle(color:theme.GetColor("primary"))),
      restaurantDetalis.branches[0]["description"]!=null?SizedBox(height: sizes.GetHeight() * 1):SizedBox.shrink(),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SvgPicture.asset(
            "assets/icon/locations.svg",
            height: sizes.GetHeight() * 2,
          ),
          SizedBox(width: sizes.GetWidth() * 1),
          Expanded(child: Text(restaurantDetalis.branches[0]["address_line"]??"")),
          InkWell(
            onTap: (){
              final branch = restaurantDetalis.branches[0];
              if(branch['latitude']!=null && branch['longitude']!=null){
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, a1, a2) => Maps(
                      restaurantLat: double.parse(branch['latitude'].toString()),
                      restaurantLng: double.parse(branch['longitude'].toString()),
                      data:[
                        {
                          "NavigationInfoCard": true,
                        },
                      ],
                    ),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
             },
             child: Image.asset(
              "assets/images/088df244f25620d4a1ee3315f70fdeb0ae71b153.png",
              height: sizes.GetHeight() * 6,
            ),
          ),
        ],
      ),
    ],
  ):Center();
}