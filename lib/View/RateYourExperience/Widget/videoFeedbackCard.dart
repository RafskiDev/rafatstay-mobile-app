import 'package:flutter/cupertino.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import 'package:flutter_svg/flutter_svg.dart';
Widget  videoFeedbackCard(BuildContext context,String text,String icon){
  final sizes=Sizes(context);
  Themes theme = Themes();
  return Container(
    width: Sizes(context).GetWidth() * 47,
    height: Sizes(context).GetHeight() * 25,
    decoration:BoxDecoration(
      color: theme.GetColor("backgroundOffWhite"),
      borderRadius: BorderRadius.circular(18),
      border:Border.all(color: theme.GetColor("textSecondary"),width:1),
    ),
    child:Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(child: Text(textAlign:TextAlign.center,text,style: TextStyle(fontSize:sizes.GetHeight()*1.7),)),
        SizedBox(height:sizes.GetHeight()*2,),
        SvgPicture.asset("assets/icon/photosWithThemeal.svg"),
      ],
    ),
  );
}