import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import 'Booking_riverpod.dart';
import 'Widget/Cancelled.dart';
import 'Widget/Completed.dart';
import 'Widget/OnSite.dart';
import 'Widget/Upcoming.dart';
class Booking extends ConsumerWidget {
  Booking({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(Booking_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final selectedIndex = ref.watch(Booking_riverpod); // index المحدد
    final notifier = ref.read(Booking_riverpod.notifier);
    return Scaffold(
      appBar:buildCustomAppBar(context,"Booking",showBackButton:false),
      backgroundColor: theme.GetColor("background"),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 3),
                  height: sizes.GetHeight() * 6,
                  decoration: BoxDecoration(
                    color: theme.GetColor("primaryS"),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      ref.read(Booking_riverpod.notifier).tabs.length,
                          (index) => CustomBox(
                        text: ref.read(Booking_riverpod.notifier).tabs[index],
                        isSelected: selectedIndex == index,
                        onTap: () {
                          ref.read(Booking_riverpod.notifier).setIndex(index);
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: sizes.GetHeight() * 2),
               if(selectedIndex==0)Upcoming(),
                if(selectedIndex==1)OnSite(),
                if(selectedIndex==2)Completed(),
                if(selectedIndex==3)Cancelled(),
              ],

            ),
          ),
        ),
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onTap;

  const CustomBox({
    Key? key,
    required this.text,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizes = Sizes(context);
    final theme = Themes();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        width: sizes.GetWidth() * 20,
        height: sizes.GetHeight() * 4,
        padding: EdgeInsets.all(sizes.GetHeight() * 0.5),
        decoration: BoxDecoration(
          color: isSelected ? theme.GetColor("secondaryPrimary") : theme.GetColor("primaryS"),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(text,style:isSelected? TextStyle(color: theme.GetColor("white")):null),
      ),
    );
  }
}
