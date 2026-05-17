import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/Them.dart';
import '../../Widget/GradientText.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'HistoryDescription_rverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'Widget/InfoRowItem.dart';
import 'Widget/MealItem.dart';
import 'Widget/ParkingInfoCard.dart';
import 'Widget/StaffReviewCard.dart';
import 'Widget/TableInfoBar.dart';
class HistoryDescription extends ConsumerStatefulWidget {
  const HistoryDescription({super.key});

  @override
  ConsumerState<HistoryDescription> createState() => _HistoryDescriptionState();
}

class _HistoryDescriptionState extends ConsumerState<HistoryDescription> {
  @override
  Widget build(BuildContext context) {
    ref.watch(HistoryDescription_rverpod.notifier);
    return  Scaffold(
      appBar:buildCustomAppBar(context,"History"),
      backgroundColor: Themes().GetColor("background"),
      body:SingleChildScrollView(
        child: Container(
          padding:EdgeInsets.symmetric(horizontal:Sizes(context).GetWidth()*5),
          child: Column(
            children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/bookingDeactivate.svg",height:Sizes(context).GetHeight()*2,),
                        SizedBox(width:Sizes(context).GetWidth()*1),
                        GradientText(
                          widget:Text(TextLanguage().GetWord("تفاصيل الحجز")),
                        ),
                      ],
                    ),
                    Text("300",style:TextStyle(color:Themes().GetColor("textSecondary"))),
                  ],
                ),
                SizedBox(height:Sizes(context).GetHeight()*2),
                Row(
                  children: [
                    Row(
                      children: [
                        GradientText(
                          widget: SvgPicture.asset(
                          "assets/icon/MealDetails.svg",
                          height: Sizes(context).GetHeight() * 2,
                        ),
                       ),
                        SizedBox(width:Sizes(context).GetWidth()*1),
                        GradientText(
                          widget: Text(TextLanguage().GetWord('جميع الوجبات')),
                        ),
                        SizedBox(width:Sizes(context).GetWidth()*1),
                        GradientText(
                          widget: SvgPicture.asset(
                            "assets/icon/dollar.svg",
                            height: Sizes(context).GetHeight() * 2,
                          ),
                        ),
                        SizedBox(width:Sizes(context).GetWidth()*1),
                        GradientText(
                          widget: Text("300"),
                        ),
                        SizedBox(width:Sizes(context).GetWidth()*1),
                        GradientText(
                          widget: SvgPicture.asset(
                            "assets/icon/SAR.svg",
                            height: Sizes(context).GetHeight() * 1.2,
                          ),
                        ),
                      ],
                    ),
                 ],
               ),
               SizedBox(height:Sizes(context).GetHeight()*2),
              MealsList(
                meals: [
                  {'name': 'Meat Dishes',  'price': 1000, 'mealsCount': 4},
                  {'name': 'Orange Juice', 'price': 1000, 'mealsCount': 4},
                  {'name': 'Green Salads', 'price': 150,  'mealsCount': 3},
                  {'name': 'Mayonnaise',   'price': 150,  'mealsCount': 3},
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Row(
                children: [
                  SvgPicture.asset("assets/icon/CookingMethod.svg"),
                  SizedBox(width:Sizes(context).GetWidth()*1),
                  GradientText(widget: Text("Cooking details")),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              InfoRowList(
                items: [
                  {
                    'icon': 'assets/icon/CookingMethod.svg',
                    'label': 'Cooking Method',
                    'value': 'Steamed',
                  },
                  {
                    'icon': 'assets/icon/DonenessLevel.svg',
                    'label': 'Doneness Level',
                    'value': 'Medium Rare',
                  },
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              TableInfoBar(
                tableNumber: 5,
                price: 50,
                location: 'Indoor',
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              ParkingInfoCard(
                price: 150,
                hours: 3,
                location: 'Indoor',
                plateNumber: 'ABC 1234',
                carColor: 'black',
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Row(
                children: [
                  Text(TextLanguage().GetWord("تقييم المطعم"),style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ref.read(HistoryDescription_rverpod.notifier).restaurant.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SquareButton(
                        width: (r['label'] as String).length * 5.5 + 60,
                        height: Sizes(context).GetHeight()*5,
                        backgroundColor:Themes().GetColor("backgroundOffWhite"),
                        borderColor:Themes().GetColor("borderLight"),
                        borderWidth: 1,
                        borderRadius: 50,
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
                            SizedBox(width: Sizes(context).GetWidth()*1),
                            SvgPicture.asset("assets/icon/Star.svg",height:Sizes(context).GetHeight()*2),
                            SizedBox(width: Sizes(context).GetWidth()*1),
                            Text('${r['score']}/${r['max'] ?? 5}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color:Themes().GetColor("textSecondary"))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Row(
                children: [
                  Text(TextLanguage().GetWord("تقييم الخدمة"),style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ref.read(HistoryDescription_rverpod.notifier).service.map((r) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SquareButton(
                        width: (r['label'] as String).length * 5.5 + 60,
                        height: Sizes(context).GetHeight()*5,
                        backgroundColor:Themes().GetColor("backgroundOffWhite"),
                        borderColor:Themes().GetColor("borderLight"),
                        borderWidth: 1,
                        borderRadius: 50,
                        onTap: () {},
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(r['label'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF2C2C2C))),
                            SizedBox(width: Sizes(context).GetWidth()*1),
                            SvgPicture.asset("assets/icon/Star.svg",height:Sizes(context).GetHeight()*2),
                            SizedBox(width: Sizes(context).GetWidth()*1),
                            Text('${r['score']}/${r['max'] ?? 5}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color:Themes().GetColor("textSecondary"))),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Row(
                children: [
                  Text(TextLanguage().GetWord("تقييم الموظفين"),style:TextStyle(fontWeight:FontWeight.bold,color:Themes().GetColor("textPrimary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              StaffReviewCard(
                name: 'Ahmed Omar',
                role: 'Waiter',
                imageUrl: 'assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png',
                ratings: [
                  {'label': 'Attitude','score': 5, 'max': 5},
                  {'label': 'Attention to Detail','score': 3, 'max': 5},
                  {'label': 'Professionalism','score': 4, 'max': 5},
                ],
                reviewText:
                "This is one of the best food ordering apps I've ever used! "
                    "The interface is simple, the menu is clear, ordering takes only "
                    "a few steps, and the notifications are accurate. I truly felt like "
                    "the app was designed to make life easier, not more complicated.",
                tipAmount: 5,
                onTip: () {
                  // handle tip
                },
              ),
              SizedBox(height:Sizes(context).GetHeight()*7),
              ],
          )
        )
      ),
    );
  }
}
