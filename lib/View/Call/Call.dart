import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import '../../Widget/WidgetButton.dart';
import 'Call_riverpod.dart';
class Call extends ConsumerWidget {
  const Call({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    final seconds = ref.watch(Call_riverpod);
    final notifier = ref.read(Call_riverpod.notifier);
    ref.watch(Call_riverpod);
    return Scaffold(
    //  backgroundColor: Colors.transparent,
      body:Container(
          width:double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFC19632), // #C19632
                Color(0xFF082133), // #082133
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 2,vertical: sizes.GetHeight()*2),
          child:SafeArea(
            child: Column(
              children: [
                Row(
                  children: [
                    CircularButton(
                      size: Sizes(context).GetHeight() * 5,
                      backgroundColor: Themes().GetColor("white"),
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      onTap: () {
                        Navigator.pop(context,0);
                      },
                      child:  Center(
                        child: Padding(
                          padding: EdgeInsets.only(left:sizes.GetWidth()*2),
                          child: Icon(
                            Icons.arrow_back_ios,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CircularButton(
                  size: Sizes(context).GetHeight()*15,
                  backgroundColor: Themes().GetColor("iconActive"),
                  borderColor: Colors.transparent,
                  borderWidth: 0,
                  onTap: () {

                  },
                  child:Image.asset("assets/images/43f1461454074031540dcc9d964614c216044358.png",height:Sizes(context).GetHeight()*10),
                ),
                SizedBox(height:sizes.GetHeight()*2),
                Text("ALBAIK",style:TextStyle(fontWeight: FontWeight.w600,fontSize:Sizes(context).GetHeight()*3,color:Themes().GetColor("white"))),
                SizedBox(height:sizes.GetHeight()*3),
                Text(
                  notifier.formattedTime,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: Sizes(context).GetHeight() * 3,
                    color: Themes().GetColor("white"),
                  ),
                ),

                SizedBox(height:sizes.GetHeight()*20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularButton(
                      size: Sizes(context).GetHeight()*7,
                      backgroundColor: Themes().GetColor("white"),
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      onTap: () {
                        notifier.startTimer();
                      },
                      child:SvgPicture.asset("assets/icon/microphone.svg",height:Sizes(context).GetHeight()*3.3),
                    ),
                    SizedBox(width:sizes.GetWidth()*5,),
                    CircularButton(
                      size: Sizes(context).GetHeight()*7,
                      backgroundColor: Themes().GetColor("error"),
                      borderColor: Colors.transparent,
                      borderWidth: 0,
                      onTap: () {
                        notifier.stopTimer();
                        Navigator.pop(context,0);
                      },
                      child:SvgPicture.asset("assets/icon/EndTheCall.svg",color:Themes().GetColor("white"),height:Sizes(context).GetHeight()*3.3),
                    ),
                  ],
                ),

                ]
            ),
          )
      )

    );
  }
}
