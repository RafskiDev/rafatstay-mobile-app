import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import 'BottomBar_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBar extends ConsumerStatefulWidget {
  final int initialIndex;
  BottomBar({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  ConsumerState<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends ConsumerState<BottomBar> {
  @override
  void initState() {
    super.initState();
    // تعيين الصفحة الأولية مرة واحدة فقط
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(BottomBar_riverpod.notifier).changePage(widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(BottomBar_riverpod);
    final pages = ref.read(BottomBar_riverpod.notifier).pages;
    final sizes = Sizes(context);
    final textLanguage = TextLanguage();
    final theme = Themes();

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.GetColor("background"),
      body: pages[currentIndex],
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          sizes.GetWidth() * 2,
          sizes.GetHeight() * 0.5,
          sizes.GetWidth() * 2,
          sizes.GetHeight() * 0.5 + MediaQuery.of(context).padding.bottom,
        ),
        child: Container(
          height: sizes.GetHeight() * 8,
          padding: EdgeInsets.symmetric(
            horizontal: sizes.GetWidth() * 2,
            vertical: sizes.GetHeight() * 0.5,
          ),
          decoration: BoxDecoration(
            color: theme.GetColor("background"),
            border: Border.all(
              color: theme.GetColor("primary"),
              width: sizes.GetWidth() * 0.2,
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              navItem(ref, "assets/icon/HomeDeactivate.svg",
                  "assets/icon/HomeActive.svg",
                  textLanguage.GetWord("الرئيسية"), 0, currentIndex,
                  theme.GetColor("primary"), context),
              navItem(ref, "assets/icon/ServicesDeactivate.svg",
                  "assets/icon/ServicesActive.svg",
                  textLanguage.GetWord("الخدمات"), 1, currentIndex,
                  theme.GetColor("primary"), context),
              navItem(ref, "assets/icon/InterestedDeactivate.svg",
                  "assets/icon/InterestedActive.svg",
                  textLanguage.GetWord("مفضل"), 2, currentIndex,
                  theme.GetColor("primary"), context),
              navItem(ref, "assets/icon/bookingDeactivate.svg",
                  "assets/icon/bookingActive.svg",
                  textLanguage.GetWord("الحجز"), 3, currentIndex,
                  theme.GetColor("primary"), context),
              navItem(ref, "assets/icon/accountDeactivate.svg",
                  "assets/icon/accountActive.svg",
                  textLanguage.GetWord("الحساب"), 4, currentIndex,
                  theme.GetColor("primary"), context),
            ],
          ),
        ),
      ),
    );
  }

  Widget navItem(
      WidgetRef ref,
      String iconOutlined,
      String iconFilled,
      String text,
      int index,
      int currentIndex,
      Color activeColor,
      BuildContext context) {
    final isSelected = currentIndex == index;
    final sizes = Sizes(context);
    return InkWell(
      onTap: () => ref.read(BottomBar_riverpod.notifier).changePage(index),
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding:
        EdgeInsets.symmetric(horizontal: isSelected ? 16 : 8, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              isSelected ? iconFilled : iconOutlined,
              height: sizes.GetHeight() * 2.8,
            ),
            if (isSelected) ...[
              SizedBox(width: sizes.GetWidth() * 1.4),
              Text(
                text,
                style:
                TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
              ),
            ]
          ],
        ),
      ),
    );
  }
}