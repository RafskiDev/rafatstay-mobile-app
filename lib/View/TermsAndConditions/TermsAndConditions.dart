import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:rafatstay/Utils/Them.dart';
import '../../Utils/Sizes.dart';
import '../../Widget/WidgetAppBar.dart';
import 'TermsAndConditions_riverpod.dart';
class TermsAndConditions extends ConsumerWidget {
  TermsAndConditions({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(TermsAndConditions_riverpod);
    final sizes=Sizes(context);
    Themes theme = Themes();
    TextLanguage textLanguage = TextLanguage();
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      appBar:buildCustomAppBar(showBackButton:false,context,textLanguage.GetWord('الشروط والأحكام')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: sizes.GetWidth()*5),
        child:SingleChildScrollView(
          child:Column(
            children: [
              InfoCard(
                title:textLanguage.GetWord("التعريفات"),
                description: textLanguage.GetWord("رافات ستاي هي منصة إلكترونية مملوكة ومطورة من قبل RSK، وهي تطبيق قيد تسجيل براءة اختراع يتيح للمستخدمين حجز الفنادق والمطاعم والفعاليات وغيرها من الخدمات المتوفرة على المنصة. يشير مصطلح \"المستخدم\" إلى أي شخص يستخدم المنصة أو أي من خدماتها."),
              ),
              InfoCard(
                title: textLanguage.GetWord("قبول الشروط"),
                description: textLanguage.GetWord("باستخدام منصة رافات ستاي، يوافق المستخدم بشكل كامل على جميع الشروط والأحكام المذكورة هنا. في حال عدم الموافقة، يُمنع المستخدم من استخدام المنصة أو أي من خدماتها."),
              ),
              InfoCard(
                title: textLanguage.GetWord("الحساب والمعلومات الشخصية"),
                description: textLanguage.GetWord("يجب على المستخدمين إنشاء حساب صالح وتقديم معلومات دقيقة وكاملة. يتحمل المستخدم مسؤولية الحفاظ على سرية كلمة المرور وجميع الأنشطة التي تتم من خلال الحساب. تلتزم المنصة بحماية البيانات الشخصية وفقًا لسياسة الخصوصية الخاصة بها."),
              ),
              InfoCard(
                title: textLanguage.GetWord("الحجوزات والمدفوعات"),
                description: textLanguage.GetWord("تخضع جميع الحجوزات لتوفر الأماكن في الجهات المشاركة. يتم تأكيد الحجز فقط بعد إتمام عملية الدفع بنجاح. تحتفظ المنصة بالحق في تعديل أو إلغاء الحجوزات بسبب ظروف خارجة عن إرادتها مع إشعار المستخدم فورًا."),
              ),
              InfoCard(
                title: textLanguage.GetWord("سياسة الإلغاء واسترداد المبلغ"),
                description: textLanguage.GetWord("في حال قام المستخدم بإلغاء الحجز، سيتم خصم 35٪ من المبلغ المدفوع كرسوم إلغاء، وسيتم رد المبلغ المتبقي وفقًا لطرق الدفع المتاحة. قد تؤدي الإلغاءات المتكررة أو عدم الحضور إلى تقييد الحساب أو إيقافه نهائيًا."),
              ),
              InfoCard(
                title: textLanguage.GetWord("السلوك في الأماكن"),
                description: textLanguage.GetWord("يجب على المستخدمين التصرف باحترام داخل جميع الأماكن المشاركة. أي سلوك مسيء أو غير لائق قد يؤدي إلى الإيقاف الدائم دون إشعار مسبق."),
              ),
              InfoCard(
                title: textLanguage.GetWord("حقوق المنصة"),
                description: textLanguage.GetWord("جميع حقوق الملكية الفكرية المتعلقة بالمنصة بما في ذلك البرامج والتصاميم والمحتوى وواجهة المستخدم محمية قانونيًا وقيد تسجيل براءة اختراع. لا يجوز نسخ أو استخدام أي جزء من المنصة دون إذن خطي مسبق."),
              ),
              InfoCard(
                title: textLanguage.GetWord("إخلاء المسؤولية"),
                description: textLanguage.GetWord("تعتمد المنصة على المعلومات المقدمة من الجهات المشاركة ولا تتحمل مسؤولية الأخطاء أو التغييرات غير المتوقعة. أي أضرار ناتجة عن سوء استخدام المنصة تقع على عاتق المستخدم وحده."),
              ),
              InfoCard(
                title: textLanguage.GetWord("تعديل الشروط"),
                description: textLanguage.GetWord("تحتفظ رافات ستاي بالحق في تعديل هذه الشروط والأحكام في أي وقت. تصبح جميع التغييرات سارية المفعول فور نشرها داخل المنصة."),
              ),
               SizedBox(height:Sizes(context).GetHeight()*5),
              ]
          )
        )
      )
    );
  }
}
class InfoCard extends StatelessWidget {
  final String title;
  final String description;

  const InfoCard({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min, // "Hug contents" تعني
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.circle, size: Sizes(context).GetHeight() * 1.8, color:Themes().GetColor("textPrimary")),
              SizedBox(width: Sizes(context).GetWidth() * 2),
              Expanded(
                child: Text(
                  title,
                  style:TextStyle(
                    fontWeight:FontWeight.bold,
                    color:Themes().GetColor("textPrimary"),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Sizes(context).GetHeight()*2),
          Text(
            description,
            style:TextStyle(
              color:Themes().GetColor("textPrimary"),
            ),
          ),
        ],
      ),
    );
  }
}