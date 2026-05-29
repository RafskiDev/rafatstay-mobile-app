import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import 'Service/LocationService.dart';
import 'Utils/SvgPreloaderService.dart';
import 'View/SplashScreen/SplashScreen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'View/language/language_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.toString().contains('NetworkImageLoadException')) return;
    FlutterError.presentError(details);
  };
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await GoogleSignIn.instance.initialize(); // بدون أي ID
  await SvgPreloaderService.loadAll(['assets/icon/']);
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(language_riverpod);
    final languages = ['en','ar', 'ku', 'tr'];
    final language = languages[selectedIndex];
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      locale: language == 'ar' ? const Locale('ar') : const Locale('en'),
      home: const MyHomePage(title: ""),
      title: 'RafatStay',
      theme: ThemeData(
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        textSelectionTheme: const TextSelectionThemeData(
          selectionHandleColor: Color(0xFFC19632),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> svgPaths = [];
  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    ///
    LanguageInit();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = GetStorage().read("token");
      if (token != null) {
        LocationService().init(context);
      }
    });
  }

  void LanguageInit() async {
    final storage = GetStorage();
    await storage.writeIfNull('Language', 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SplashScreen(),
    );
  }
}
