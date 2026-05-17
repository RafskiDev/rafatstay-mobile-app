import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../Utils/Sizes.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/Them.dart';
import '../../Widget/WidgetAppBar.dart';
import 'TableDetails_riverpod.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_svg/flutter_svg.dart';
class TableDetails extends ConsumerStatefulWidget {
  final int idTable;
  const TableDetails({super.key, required this.idTable});

  @override
  ConsumerState<TableDetails> createState() => _TableDetailsState();
}

class _TableDetailsState extends ConsumerState<TableDetails> {

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(TableDetails_riverpod.notifier).fetchTableDetails(context, widget.idTable);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(TableDetails_riverpod);
    final sizes = Sizes(context);
    final theme = Themes();
    final textLanguage = TextLanguage();
    final notifier = ref.watch(TableDetails_riverpod.notifier);
    return  Scaffold(
      backgroundColor: theme.GetColor("background"),
      body: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: CarouselSlider(
                  items: notifier.items.isEmpty
                      ? [
                    Container(
                      color: theme.GetColor("primaryS"),
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 50),
                      ),
                    )
                  ]
                      : notifier.items.map((item) {
                    final img = item["image"] ?? "";
                    return img.startsWith("http")
                        ? Image.network(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                        : Image.asset(
                      img,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  }).toList(),
                  options: CarouselOptions(
                    height: sizes.GetHeight() * 35,
                    viewportFraction: 1,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      ref
                          .read(TableDetails_riverpod.notifier)
                          .changePage(index);
                    },
                  ),
                ),
              ),
              Positioned(
                top: sizes.GetHeight() * 4,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: sizes.GetWidth() * 4),
                  child: GlassAppBar(
                    onBack: () => Navigator.pop(context),
                    onNotification: () {},
                    titel:"hi",
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: sizes.GetHeight() * 2),
          Container(
            padding:EdgeInsets.symmetric(horizontal: sizes.GetWidth() * 4),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/LikePrice.svg",color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("50"),
                        SizedBox(width: sizes.GetWidth() * 1),
                        SvgPicture.asset("assets/icon/SAR.svg",color: theme.GetColor("textPrimary")),
                      ],
                    ),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/TablePerson.svg",color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("500 Person"),
                        SizedBox(width: sizes.GetWidth() * 1),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: sizes.GetWidth() * 3,
                          height: sizes.GetWidth() * 3,
                          decoration: BoxDecoration(
                            color: 1==1 ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("Available"),
                        SizedBox(width: sizes.GetWidth() * 1),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/Chair.svg",color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("4 Guests"),
                      ],
                    ),
                    SizedBox(width: sizes.GetWidth() * 10),
                    Row(
                      children: [
                        SvgPicture.asset("assets/icon/_location.svg",color: theme.GetColor("textPrimary")),
                        SizedBox(width: sizes.GetWidth() * 1),
                        Text("4 Guests"),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    Text("Table Features",style:TextStyle(color: theme.GetColor("textPrimary"),fontSize: sizes.GetWidth() * 5.8,fontWeight: FontWeight.bold),),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    CustomSelectionCard(svg:"assets/icon/Window.svg"),
                    SizedBox(width: sizes.GetWidth() * 1.5),
                    CustomSelectionCard(title:"Quiet Area",svg:"assets/icon/QuietArea.svg"),
                    SizedBox(width: sizes.GetWidth() * 1.5),
                    CustomSelectionCard(title:"Non-Smoking",svg:"assets/icon/NonSmoking.svg"),
                  ],
                ),
                SizedBox(height: sizes.GetHeight() * 2),
                Row(
                  children: [
                    InkWell(child: SvgPicture.asset(notifier.isTableChosen?"assets/icon/BOXCHECK_OFF.svg":"assets/icon/BOXCHECK_ON.svg",color: notifier.isTableChosen?theme.GetColor("textSecondary"):theme.GetColor("primary")),
                      onTap: (){
                        notifier.changePage_();
                      },
                    ),
                    SizedBox(width: sizes.GetWidth() * 1),
                    Text("Choose the table for my reservation",style:TextStyle(color: theme.GetColor("primary"))),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }
}

class CustomSelectionCard extends StatelessWidget {
  final String title;
  final String svg;
  const CustomSelectionCard({
    Key? key,
    this.title = "Near Window",
    this.svg = "assets/icon/QuietArea.svg",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // تعريف متغيرات القياس لتسهيل القراءة
    final sizes = Sizes(context);
    final theme = Themes();

    return Container(
      // عرض 80px تقريباً (بناءً على شاشة عرضها 375-400)
      width: sizes.GetWidth() * 22,
      height: sizes.GetWidth() * 22,
      padding: const EdgeInsets.all(10), // Padding: 10px
      decoration: BoxDecoration(
        color: const Color(0xFFF4EFE6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB09040),
          width: 1.0,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            svg,
            color: theme.GetColor("textPrimary"),
            width: sizes.GetWidth() * 8,
          ),

          // Gap: 4px تقريباً
          SizedBox(height: sizes.GetHeight() * 0.5),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.GetColor("textPrimary"),
              fontSize: sizes.GetHeight() * 1.2,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}