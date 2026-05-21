import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/WidgetButton.dart';
import '../Login/Login.dart';
import 'AppOverview_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
class AppOverview extends ConsumerWidget {
  final PageController _controller = PageController();
  final int _totalPages = 3;

  AppOverview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPage = ref.watch(pageProvider);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(child: SvgPicture.asset("assets/icon/language.svg", semanticsLabel: 'Dart Logo')),
                ],
              ),
              Container(
                height:sizes.GetHeight()*40,
                child:PageView.builder(
                  controller: _controller,
                  itemCount: _totalPages,
                  onPageChanged: (index) {
                    ref.read(pageProvider.notifier).setPage(index);
                  },
                  itemBuilder: (context, index) => Center(
                    child:Image.asset(
                      ref.read(pageProvider.notifier).image[currentPage],
                      fit: BoxFit.cover, // لتغطية المساحة بالكامل
                      width:sizes.GetWidth()*60,
                    ),
                  ),
                ),
              ),
              SmoothPageIndicator(
                controller: _controller,
                count: _totalPages,
                effect: CustomizableEffect(
                  activeDotDecoration: DotDecoration(
                    width: 50,          // أعرض نقطة نشطة
                    height: 10,
                    color:theme.GetColor("primary"), // لون النقطة النشطة
                    borderRadius: BorderRadius.circular(16),
                  ),
                  dotDecoration: DotDecoration(
                    width: 20,          // عرض النقطة العادية
                    height: 10,
                    color:theme.GetColor("secondary"), // لون النقاط العادية
                    borderRadius: BorderRadius.circular(16),
                  ),
                  spacing: 2,
                ),
              ),
              Text(
                ref.read(pageProvider.notifier).texts[currentPage]["title"] ?? "",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 18,
                  fontWeight: FontWeight.w400, // أو FontWeight.bold إذا تريد عريض
                  color:theme.GetColor("textPrimary"),
                ),
              ),
              Text(
                ref.read(pageProvider.notifier).texts[currentPage]["content"] ?? "",
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  fontWeight: FontWeight.w400, // أو FontWeight.bold إذا تريد عريض
                  color:theme.GetColor("textPrimary"),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: sizes.GetHeight()*5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircularButton(
                    size: sizes.GetHeight()*6.2,
                    onTap: (){
                      Navigator.pushAndRemoveUntil(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => const Login(),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                            (route) => false, // حذف كل الوجهات السابقة
                      );

                    },
                    child: Text(
                      textLanguage.GetWord("تخطي"),
                    ),
                  ),
                  SquareButton(
                    width: sizes.GetWidth()*50,
                    height: sizes.GetHeight()*6,
                    onTap: () {
                      int nextPage = currentPage + 1;

                      if (nextPage >= _totalPages) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation1, animation2) => Login(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                          ),
                              (route) => false,
                        );
                        return;
                      }

                      _controller.animateToPage(
                        nextPage,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );

                      ref.read(pageProvider.notifier).setPage(nextPage);
                    },
                    backgroundColor:theme.GetColor("primary"),
                    borderRadius: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(textLanguage.GetWord("انضم إلى التجربة"), style: TextStyle(color:theme.GetColor("secondary500"), fontSize: 15)),
                        Container(
                          width: sizes.GetWidth()*7,
                          height: sizes.GetHeight()*7,
                          decoration: BoxDecoration(
                            color:theme.GetColor("textPrimary"),  // اللون الماروني
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color:theme.GetColor("primary"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
