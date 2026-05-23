import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Utils/Sizes.dart';
import '../../Widget/WidgetAppBar.dart';
class WebView3DViewer extends StatefulWidget {
  final String url;

  const WebView3DViewer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<WebView3DViewer> createState() => _WebView3DViewerState();
}

class _WebView3DViewerState extends State<WebView3DViewer> {
  late final WebViewController _webViewController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // ضروري لتشغيل الـ 3D والـ Gyroscope
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint("WebView Error: ${error.description}");
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     // appBar:buildCustomAppBar(context,"Full View Restaurant"),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // الـ WebView الذي يعرض صفحة الـ Three.js
          WebViewWidget(controller: _webViewController),
          Positioned(
            top:Sizes(context).GetHeight()*5,
            left: 0,
            right: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Sizes(context).GetWidth() * 4,
              ),
              child: GlassAppBar(
                onBack: () => Navigator.pop(context),
                onNotification: () {

                },
                titel:TextLanguage().GetWord("مطعم بإطلالة كاملة"),
              ),
            ),
          ),
          // شاشة الانتظار
          if (_isLoading)
            Container(
              color: Colors.black,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text(
                      "جاري تحضير التجربة الافتراضية ثلاثية الأبعاد...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}