import 'package:flutter/material.dart';
import 'package:rafatstay/Utils/TextLanguage.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../Widget/WidgetAppBar.dart';

class PaymentWebView extends StatefulWidget {
  final String url;

  const PaymentWebView({super.key, required this.url});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            // 👇 هنا تگدر تراقب الرجوع بعد الدفع
            if (request.url.contains("payment/callback")) {
              if (request.url.contains("success")) {
                Navigator.pop(context, "success"); // نرسل كلمة نجاح
              } else {
                Navigator.pop(context, "failed"); // نرسل كلمة فشل
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:buildCustomAppBar(context,TextLanguage().GetWord("الدفع")),
      body: WebViewWidget(controller: controller),
    );
  }
}