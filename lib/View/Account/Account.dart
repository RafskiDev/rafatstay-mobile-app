import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:rafatstay/View/language/language.dart';
import 'package:rafatstay/View/notifications/notifications.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Service/ApiService.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../AccountDetails/AccountDetails.dart';
import '../AllConversations/AllConversations.dart';
import '../History/History.dart';
import '../Login/Login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Loyalty/Loyalty.dart';
import '../TermsAndConditions/TermsAndConditions.dart';
import 'Account_riverpod.dart';
class Account extends ConsumerWidget {
  Account({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
     ref.watch(Account_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();

    final user = ref.read(Account_riverpod.notifier).storage.read("user");
     final avatarPath = user?["avatar"];
     final avatarUrl = avatarPath != null
         ? "$showImage$avatarPath"
         : null;
     print(avatarUrl);
    return Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(showBackButton:false,context,""),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
        child:SingleChildScrollView(
          child:Column(
            children: [
              InkWell(
                onTap:()=>ref.read(Account_riverpod.notifier).pickAndUploadAvatar(context),
                child: SizedBox(
                  width: sizes.GetWidth() * 30,
                  height: sizes.GetHeight() * 15,
                  child: ClipOval(
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: avatarUrl != null
                              ? Image.network(
                            avatarUrl.toString(),
                            fit: BoxFit.cover,

                            errorBuilder: (context, error, stackTrace) => Image.asset(
                              "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                              fit: BoxFit.cover,
                            ),
                          )
                              : Image.asset(
                            "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: sizes.GetHeight() * 4,
                            color: Colors.black.withOpacity(0.5),
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              "assets/icon/changeAvater.svg",
                              width: sizes.GetWidth()*3,
                              height: sizes.GetHeight()*3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Text(user["full_name"]??""),
              SizedBox(height:Sizes(context).GetHeight()*2),
              Row(
                children: [
                  Text(textLanguage.GetWord('حساب تعريفي'),style:TextStyle(fontSize:Sizes(context).GetHeight()*3,color:theme.GetColor("textSecondary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              RowInfo(
                imagePath:"assets/icon/AccountDetails.svg",
                text:textLanguage.GetWord("تفاصيل الحساب"),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AccountDetails(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/Histors.svg",
                text: textLanguage.GetWord("السجل"),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          History(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );

                }
              ),
              Row(
                children: [
                  Text(textLanguage.GetWord('عام'),style:TextStyle(fontSize:Sizes(context).GetHeight()*3,color:theme.GetColor("textSecondary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              RowInfo(
                imagePath:"assets/icon/notification.svg",
                text: textLanguage.GetWord("الإشعارات"),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          notifications(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/Allconversations.svg",
                text:textLanguage.GetWord("جميع المحادثات"),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          AllConversations(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              /*
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/LightMode.svg",
                text:textLanguage.GetWord('الوضع النهاري'),
                showThemes: true,
              ),
               */
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/language.svg",
                text: "${textLanguage.GetWord('اللغة')} (${ref.read(Account_riverpod.notifier).storage.read("user")["preferred_language"]??" English "})",
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          language(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/Loyalty.svg",
                text:textLanguage.GetWord('ولاء'),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                       Loyalty(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              Row(
                children: [
                  Text(textLanguage.GetWord('المساعدة والدعم'),style:TextStyle(fontSize:Sizes(context).GetHeight()*3,color:theme.GetColor("textSecondary"))),
                ],
              ),
              SizedBox(height:Sizes(context).GetHeight()*2),
              RowInfo(
                imagePath:"assets/icon/TermsAndConditions.svg",
                text:textLanguage.GetWord('الشروط والأحكام'),
                onTap:(){
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          TermsAndConditions(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/ContactCustomerService.svg",
                text: textLanguage.GetWord('اتصل بخدمة العملاء'),
              ),
              SizedBox(height: Sizes(context).GetHeight() * 1),
              RowInfo(
                imagePath:"assets/icon/LogOut.svg",
                text:  textLanguage.GetWord("تسجيل الخروج"),
                showDivider: false,
                color: theme.GetColor("error"),
                onTap:(){
                  WidgetCustomDialog(
                    context,
                    child: Container(
                      height:Sizes(context).GetHeight()*55,
                      width:double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset("assets/icon/LogOuts.svg",),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          Text(textLanguage.GetWord("هل أنت متأكد أنك تريد تسجيل الخروج؟")),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          WidgetButton(
                            isCircular: true,
                            context: context,
                            buttonText: "Cancel",
                            backgroundColor: Themes().GetColor("primaryA"),
                            textColor:  Themes().GetColor("textPrimary"),
                            onPressed: () {
                              Navigator.of(context).pop(); // إغلاق الدايلوج
                            },
                          ),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          WidgetButton(
                            isCircular: true,
                            context: context,
                            buttonText:textLanguage.GetWord("تسجيل الخروج"),
                            backgroundColor: Themes().GetColor("backgroundOffWhite"),
                            textColor:  Themes().GetColor("textPrimary"),
                            borderColor:  Themes().GetColor("textPrimary"),
                            borderWidth: 1,
                            onPressed: () {
                              ref.read(Account_riverpod.notifier).LogOut(context);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    barrierDismissible: true,
                    backgroundColor: Themes().GetColor("backgroundOffWhite"),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 3),
              RowInfo(
                imagePath:"assets/icon/DeleteAccount.svg",
                text:textLanguage.GetWord("حذف الحساب"),
                showDivider: false,
                color: theme.GetColor("error"),
                onTap:(){
                  WidgetCustomDialog(
                    context,
                    child: Container(
                      height:Sizes(context).GetHeight()*55,
                      width:double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SvgPicture.asset("assets/icon/DeleteAccount_.svg",),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          Text(textLanguage.GetWord("هل أنت متأكد أنك تريد حذف حسابك؟")),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          WidgetButton(
                            isCircular: true,
                            context: context,
                            buttonText: "Cancel",
                            backgroundColor: Themes().GetColor("primaryA"),
                            textColor:  Themes().GetColor("textPrimary"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          SizedBox(height: Sizes(context).GetHeight() * 2),
                          WidgetButton(
                            isCircular: true,
                            context: context,
                            buttonText:textLanguage.GetWord("حذف الحساب"),
                            backgroundColor: Themes().GetColor("backgroundOffWhite"),
                            textColor:  Themes().GetColor("textPrimary"),
                            borderColor:  Themes().GetColor("textPrimary"),
                            borderWidth: 1,
                            onPressed: () {
                              ref.read(Account_riverpod.notifier).DeleteAccount(context);
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                    barrierDismissible: true,
                    backgroundColor: Themes().GetColor("backgroundOffWhite"),
                  );
                },
              ),
              SizedBox(height: Sizes(context).GetHeight() * 3),
            ],
          ),
        ),
      )
    );
  }
}

class RowInfo extends StatelessWidget {
  final String imagePath;
  final String text;
  final Color? color;
  final bool showDivider;
  final bool showThemes;
  final VoidCallback? onTap;

  const RowInfo({
    super.key,
    required this.imagePath,
    required this.text,
    this.color,
    this.showDivider = true,
    this.showThemes = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(width: Sizes(context).GetWidth() * 4),
                  SvgPicture.asset(
                    imagePath,
                    height: Sizes(context).GetHeight() * 2.2,
                    color: color ?? Themes().GetColor("textPrimary"),
                  ),
                  SizedBox(width: Sizes(context).GetWidth() * 2),
                  Text(
                    text,
                    style:TextStyle(
                      color: color ?? Themes().GetColor("textPrimary"),
                      fontSize:Sizes(context).GetHeight() * 2,
                    ),
                  ),
                ],
              ),
              showThemes?ThemeSwitch():SizedBox(),
            ],
          ),
          showDivider? Divider(color:Themes().GetColor("white")):SizedBox(),
        ],
      ),
    );
  }
}

class ThemeSwitch extends StatefulWidget {
  const ThemeSwitch({super.key});

  @override
  State<ThemeSwitch> createState() => _ThemeSwitchState();
}

class _ThemeSwitchState extends State<ThemeSwitch> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isDark = !isDark;
        });
      },
      child: Padding(
        padding:  EdgeInsets.symmetric(horizontal:Sizes(context).GetWidth()*3),
        child: Stack(
          clipBehavior:Clip.none,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: Sizes(context).GetWidth()*19,
              height: Sizes(context).GetHeight()*3.5,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFF141005), width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: -2, // فوق الدائرة المتحركة
              left: isDark ? 45 : -5, // تتحرك مع الدائرة الكبيرة
              child: Container(
                width:  Sizes(context).GetWidth()*10,
                height:Sizes(context).GetHeight()*3.8,
                decoration: BoxDecoration(
                  color:Color(0xFF141005),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    isDark ? "assets/icon/LightMode.svg" : "assets/icon/outline.svg",
                    color: isDark ? Colors.yellow : Themes().GetColor("primaryA"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}