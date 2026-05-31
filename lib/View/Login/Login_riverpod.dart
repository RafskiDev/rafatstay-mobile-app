import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../Service/ApiService.dart';
import '../../Utils/TextLanguage.dart';
import '../../Utils/ToastMessage.dart';
import '../BottomBar/BottomBar.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsign;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
class PageNotifier extends Notifier<int> {
  final storage = GetStorage();
  bool isLoading = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailNode.dispose();
    passwordNode.dispose();
  }
  @override
  int build() {
    return 0;
  }

  Future<dynamic> login(BuildContext context) async {
    ref.notifyListeners();
    isLoading=true;
    ApiService api = ApiService();
    TextLanguage textLanguage = TextLanguage();

    final data = {
      "email":emailController.text,
      "password":passwordController.text,
    };
    try {
    final response = await api.post(
      "v1/auth/login",
      data,
      context,
    );
    if(response["success"]==true){
      storage.write("password", passwordController.text);
      storage.write("token", response["data"]["token"]);
      storage.write("user", response["data"]["user"]);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => BottomBar()),
            (route) => false,
      );
    }else{
      ToastMessages(context,textLanguage.GetWord("خطأ في المصداقية"),Colors.red,Colors.white);
    }

    return response;
    } finally {
      ref.notifyListeners();
      isLoading=false;
    }
  }


  final gsign.GoogleSignIn _googleSignIn = gsign.GoogleSignIn.instance;
  Future<void> signIn(BuildContext context) async {
    try {

      TextLanguage textLanguage = TextLanguage();
      await _googleSignIn.initialize(
        serverClientId: '548281138302-914ar606kuosn6bhg2vjeaj2hrn5qgah.apps.googleusercontent.com',
      );
      final account = await _googleSignIn.authenticate();

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if(idToken==null) return;
      final response = await ApiService().post(
        "v1/auth/social-login",
        {"provider": "google", "token": idToken},
        context,
      );
      if (response["success"] == true) {
        storage.write("token", response["data"]["token"]);
        storage.write("user", response["data"]["user"]);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
              (route) => false,
        );
      } else {
        ToastMessages(context, textLanguage.GetWord("خطأ في المصداقية"), Colors.red, Colors.white);
      }

    } on gsign.GoogleSignInException catch (e) {
      print('❌ Error: ${e}');
      if (e.code == gsign.GoogleSignInExceptionCode.canceled) {
        print('ℹ️ User cancelled - normal');
      }
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    try {
      TextLanguage textLanguage = TextLanguage();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final identityToken = credential.identityToken;

      if (identityToken == null) return;

      final response = await ApiService().post(
        "v1/auth/social-login",
        {
          "provider": "apple",
          "token": identityToken,
        },
        context,
      );

      if (response["success"] == true) {
        storage.write("token", response["data"]["token"]);
        storage.write("user", response["data"]["user"]);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => BottomBar()),
              (route) => false,
        );
      } else {
        ToastMessages(
          context,
          textLanguage.GetWord("خطأ في المصداقية"),
          Colors.red,
          Colors.white,
        );
      }
    } catch (e) {
      print("❌ Apple SignIn Error: $e");
    }
  }
  bool rememberMe = false;

  void toggleRememberMe() {
    rememberMe = !rememberMe;
    ref.notifyListeners();
  }
}

final pageProvider = NotifierProvider<PageNotifier, int>(PageNotifier.new);



/*
Variant: debugAndroidTest
Config: debug
Store: C:\Users\Abdul\.android\debug.keystore
Alias: AndroidDebugKey
MD5: 08:74:CA:50:44:38:93:66:93:2C:62:6F:B2:88:E8:6F
SHA1: 1A:E5:3D:DB:DE:7A:ED:BF:4F:8F:59:9C:92:3B:D6:83:67:A1:BB:75
SHA-256: 1B:6B:10:A4:DC:AF:FC:02:C5:37:7D:02:DE:AF:EB:46:3F:7A:76:FA:35:E0:DD:63:0C:EE:50:29:07:47:BB:E3
Valid until: Wednesday, September 16, 2054
 */
/*
  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId: "1027805952047-kh2ctcavjiv4ebg52lm7bdm0pk2h5feu.apps.googleusercontent.com",
      );
      final GoogleSignInAccount? account = await GoogleSignIn.instance.authenticate();
  //
      if (account == null) return;

      final GoogleSignInAuthentication auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        print("Token not found");
        return;
      }

      print("ID TOKEN: $idToken");
      // ← هنا ترسل idToken للـ API

    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      print("Google error: ${e.code}");
    } catch (e) {
      print("Unknown error: $e");
    }
  }

  */


