import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import '../../../Utils/Sizes.dart';
import '../../../Utils/Them.dart';
import '../../../Widget/WidgetButton.dart';
import '../../EmployeeDetails/EmployeeDetails.dart';
Widget Employees(List myDataList,int branchId,BuildContext context){
  final sizes = Sizes(context);
  final theme = Themes();
  return GridView.builder(
    physics: NeverScrollableScrollPhysics(),
    shrinkWrap: true,
    padding: EdgeInsets.zero,
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: sizes.GetWidth() * 1,
      childAspectRatio:  0.78,
    ),
    itemCount: myDataList.length,
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
              decoration: BoxDecoration(
                border: Border.all(
                  color:Themes().GetColor("secondary"),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  myDataList[index]["image"]??"assets/images/403b9eb897e7034bc86436e1b7afed428f22b3a4.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(myDataList[index]["name"].toString(),style:TextStyle(color:theme.GetColor("primaryA"))),
            Row(
              children: [
                SvgPicture.asset("assets/icon/stars.svg",height:sizes.GetHeight()*2),
                SizedBox(width: sizes.GetWidth() * 1),
                Text(myDataList[index]["rating"].toString(),style:TextStyle(fontSize: sizes.GetHeight() * 1.4,color:theme.GetColor("textSecondary"))),
                SizedBox(width: sizes.GetWidth() * 1),
                Expanded( // أضف هذا
                  child: Text(
                    "(${myDataList[index]["reviews_count"]} ${TextLanguage().GetWord("التقييمات")})",
                    style: TextStyle(fontSize: sizes.GetHeight() * 1.4, color: theme.GetColor("textSecondary")),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: sizes.GetHeight() * 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(TextLanguage().GetWord("يتعلم أكثر"),style:TextStyle(color:theme.GetColor("textPrimary"))),
                SizedBox(width: sizes.GetWidth() * 1),
                CircularButton(
                  backgroundColor: Themes().GetColor("primaryA"),
                  size: sizes.GetHeight()*3,
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            EmployeeDetails(employeeDetails:[myDataList[index]], branchId: branchId,),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                  borderColor: theme.GetColor("primaryA"),
                  borderWidth: 2.0,
                  child: Center(
                    child: ClipOval(
                      child: SvgPicture.asset("assets/icon/arrow.svg",height:sizes.GetHeight()*2,color:theme.GetColor("white")),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}
