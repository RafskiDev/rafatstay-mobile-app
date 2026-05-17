import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import 'package:rafatstay/View/language/language.dart';
import 'package:rafatstay/View/notifications/notifications.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import '../../Widget/WidgetCustomDialog.dart';
import '../../Widget/WidgetTextField.dart';
import '../AllConversations/AllConversations.dart';
import '../Login/Login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../Loyalty/Loyalty.dart';
import '../TermsAndConditions/TermsAndConditions.dart';
import 'AccountDetails_riverpod.dart';
class AccountDetails extends ConsumerWidget {
  AccountDetails({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
   ref.watch(AccountDetails_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
   final accountState = ref.watch(AccountDetails_riverpod);
   final isReadOnly = accountState['isReadOnly'] as List<bool>;
   final password = ref.read(AccountDetails_riverpod.notifier).storage.read("password");
   print(password);
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(showBackButton:false,context,textLanguage.GetWord("تفاصيل الحساب")),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*2),
      child:SingleChildScrollView(
        child:Column(
          children: [
            Center(
              child: ClipOval(
                child: Image.asset(
                  "assets/images/38a2a034cbe4ac063cad704f0bc1eb89da98ec7f.png",
                  width: Sizes(context).GetWidth()*30,
                  height: Sizes(context).GetHeight()*15,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height:Sizes(context).GetHeight()*10),
            WidgetTextField(
              Controller:ref.read(AccountDetails_riverpod.notifier).nameController,
              focusNode: ref.read(AccountDetails_riverpod.notifier).nameFocus,
              HintText: ref.read(AccountDetails_riverpod.notifier).storage.read("user")?["full_name"]??"",
              iconData: "assets/icon/accountDeactivate.svg",
              showEditIcon: isReadOnly[0],
              isReadOnly: isReadOnly[0],
              onEditTap: () {

                ref.read(AccountDetails_riverpod.notifier).toggleReadOnly(0);

              },
              Horizontal: 12,
              onFieldSubmitted: (value) {
                print("Password: $value");
              },
            ),
            SizedBox(height:Sizes(context).GetHeight()*2),
            WidgetTextField(
              Controller:ref.read(AccountDetails_riverpod.notifier).emailController,
              focusNode: ref.read(AccountDetails_riverpod.notifier).emailFocus,
              HintText:ref.read(AccountDetails_riverpod.notifier).storage.read("user")?["email"]??"",
              iconData: "assets/icon/Email.svg",
              showEditIcon: isReadOnly[1],
              isReadOnly: isReadOnly[1],
              onEditTap: () {

                ref.read(AccountDetails_riverpod.notifier).toggleReadOnly(1);

              },
              Horizontal: 12,
              onFieldSubmitted: (value) {
                print("Password: $value");
              },
            ),
            password!=null?SizedBox(height:Sizes(context).GetHeight()*2):SizedBox.shrink(),
            password!=null?WidgetTextField(
              Controller:ref.read(AccountDetails_riverpod.notifier).passwordController,
              focusNode: ref.read(AccountDetails_riverpod.notifier).passwordFocus,
              HintText:ref.read(AccountDetails_riverpod.notifier).storage.read("password")??"",
              iconData: "assets/icon/lock.svg",
              showEditIcon: isReadOnly[2],
              isReadOnly: isReadOnly[2],
              onEditTap: () {

                ref.read(AccountDetails_riverpod.notifier).toggleReadOnly(2);

              },
              Horizontal: 12,
              onFieldSubmitted: (value) {
                print("Password: $value");
              },
            ):SizedBox.shrink(),
            SizedBox(height:Sizes(context).GetHeight()*20),
            WidgetButton(
              width:sizes.GetWidth()*50,
              context: context,
              buttonText: "حفظ",
              onPressed: () {
                ref.read(AccountDetails_riverpod.notifier).userEdit(context);
              },
              backgroundColor: !isReadOnly[0] || !isReadOnly[1] || !isReadOnly[2] ? theme.GetColor("primary") : Themes().GetColor("primaryS"),
              textColor: Colors.white,
              buttonSize: 16,
              isCircular: true,
            ),
            ]
         )
       )
      ),
    );
  }
}
