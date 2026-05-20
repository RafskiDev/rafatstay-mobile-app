import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../Utils/Them.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import '../Utils/ToastMessage.dart';
import 'LoadingService.dart';
final box = GetStorage();
String baseUrl="https://api.rafatstay.com/api/";
final showImage = "https://api.rafatstay.com/storage/";
String roles=box.read("user")["roles"][0]["name"];
Future<String?> get token async {
  final storage = GetStorage();
  return storage.read("token");
}
bool isGuest() {
  final user = box.read("user");
  final email = user?["email"]?.toString() ?? "";
  return email.startsWith("guest_") && email.endsWith("@rafatstay.com");
}
bool _checkNotGuest(BuildContext context) {
  if (isGuest()) {
    ToastMessages(
      context,
      "سجّل حساباً كاملاً للوصول لهذه الميزة",
      Colors.orange,
      Colors.white,
    );
    return false;
  }
  return true;
}

class ApiService {

  final uuid = Uuid();
  Future<dynamic> get(String endpoint, Map<String, dynamic>? data, BuildContext context,{bool showLoader = true}) async {
    LoadingService.show();
    final url = Uri.parse('$baseUrl$endpoint').replace(queryParameters: data);
    try {
      final myToken = await token;
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json', // 🟢 مهم جداً
          'Authorization':'Bearer $myToken',
        },
      );
      //print(myToken);

      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
       // print(responseData);
        return responseData;
      }
    } catch (e) {
      print(e);
    }  finally {
     LoadingService.hide(); // 🟢 بدون ref
    }
  }

  // طلب POST
  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic>? data,
      BuildContext context) async {
    final url = Uri.parse('$baseUrl$endpoint');
    if("auth/logout"!=endpoint){
      if (!_checkNotGuest(context)) return {"success": false};
    }
    final headers = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

   final authToken = await token;
   headers["Authorization"] = "Bearer $authToken";
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );
      return json.decode(response.body);
    } catch (e) {
      throw Exception("Network error");
    }
  }

  // طلب PUT (تحديث بيانات)
  Future<Map<String, dynamic>> update(
      String endpoint,
      Map<String, dynamic> data,
      BuildContext context,
      ) async {
    if (!_checkNotGuest(context)) return {"success": false};
    final url = Uri.parse('$baseUrl$endpoint');
    final myToken = await token;
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization':'Bearer $myToken',
        },
        body: jsonEncode(data),
      );

      // طباعة الاستجابة قبل تحويلها للتأكد
      print("PUT $endpoint response: ${response.body}");
      // محاولة تحويل الاستجابة لـ JSON
      final responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        return responseData;
      } else {
        return responseData;
      }
    } catch (e) {
      print("PUT request failed: $e");
      throw Exception("Network error or invalid JSON");
    }
  }


  Future<Map<String, dynamic>> delete(String endpoint, BuildContext context, Map<String, dynamic>? data) async {
    if (!_checkNotGuest(context)) return {"success": false};
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    final myToken = await token;
    headers["Authorization"] = "Bearer $myToken";

    try {
      final response = await http.delete(
        url,
        headers: headers,
        body: data != null ? json.encode(data) : null, // ← أضف هذا
      );
      final responseData = json.decode(response.body);
      return responseData as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Network error or invalid JSON");
    }
  }
  Future<Map<String, dynamic>> patch(String endpoint, Map<String, dynamic>? data, BuildContext context) async {
    if (!_checkNotGuest(context)) return {"success": false};
    final url = Uri.parse('$baseUrl$endpoint');

    final headers = <String, String>{
      "Accept": "application/json",
      "Content-Type": "application/json",
    };

    final myToken = await token;
    headers["Authorization"] = "Bearer $myToken";

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: data != null ? json.encode(data) : null,
      );
      final responseData = json.decode(response.body);
      return responseData as Map<String, dynamic>;
    } catch (e) {
      throw Exception("Network error or invalid JSON");
    }
  }

  Future<Map<String, dynamic>?> uploadFile(
      String endpoint,
      File file,
      BuildContext context, {
        String fieldName = "avatar",
        String method = "POST",
        Map<String, String>? fields, // ← أضف هذا
        String? mimeType,
      }) async {
    if (!_checkNotGuest(context)) return {"success": false};
    final url = Uri.parse('$baseUrl$endpoint');
    final myToken = await token;

    try {
      final request = http.MultipartRequest(method, url);
      request.headers['Authorization'] = 'Bearer $myToken';
      request.headers['Accept'] = 'application/json';
      if (fields != null) request.fields.addAll(fields); // ← أضف هذا
     /// request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      if (mimeType != null) {
        final parts = mimeType.split('/');
        request.files.add(await http.MultipartFile.fromPath(
          fieldName,
          file.path,
          contentType: http.MediaType(parts[0], parts[1]),
        ));
      } else {
        request.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      }
      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);
      return json.decode(response.body);
    } catch (e) {
      print("uploadFile error: $e");
      return null;
    }
  }
  // 🟢 إظهار Loading
  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          color: Themes().GetColor("primary"),
        ),
      ),
    );
  }

  // 🟢 إخفاء Loading
  void _hideLoading(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }
}